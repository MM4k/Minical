import 'recurrence.dart';

/// A calendar event. A single stored [Event] may expand into many occurrences
/// over time when it has a [recurrence] other than [Recurrence.none].
class Event {
  final int? id;
  final String title;
  final int? categoryId;

  /// Start of the first occurrence (local time).
  final DateTime start;
  final int durationMinutes;

  final Recurrence recurrence;

  /// Inclusive last calendar date the event may repeat on. `null` = forever.
  final DateTime? recurrenceUntil;

  /// Minutes before the start to fire a reminder. `null` = no reminder.
  final int? notifyMinutesBefore;

  const Event({
    this.id,
    required this.title,
    this.categoryId,
    required this.start,
    required this.durationMinutes,
    this.recurrence = Recurrence.none,
    this.recurrenceUntil,
    this.notifyMinutesBefore,
  });

  DateTime get end => start.add(Duration(minutes: durationMinutes));

  Event copyWith({
    int? id,
    String? title,
    int? categoryId,
    bool clearCategory = false,
    DateTime? start,
    int? durationMinutes,
    Recurrence? recurrence,
    DateTime? recurrenceUntil,
    bool clearRecurrenceUntil = false,
    int? notifyMinutesBefore,
    bool clearNotify = false,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      start: start ?? this.start,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      recurrence: recurrence ?? this.recurrence,
      recurrenceUntil:
          clearRecurrenceUntil ? null : (recurrenceUntil ?? this.recurrenceUntil),
      notifyMinutesBefore:
          clearNotify ? null : (notifyMinutesBefore ?? this.notifyMinutesBefore),
    );
  }

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'category_id': categoryId,
        'start': start.millisecondsSinceEpoch,
        'duration_minutes': durationMinutes,
        'recurrence': recurrence.name,
        'recurrence_until': recurrenceUntil?.millisecondsSinceEpoch,
        'notify_minutes_before': notifyMinutesBefore,
      };

  factory Event.fromMap(Map<String, Object?> map) => Event(
        id: map['id'] as int?,
        title: map['title'] as String,
        categoryId: map['category_id'] as int?,
        start: DateTime.fromMillisecondsSinceEpoch(map['start'] as int),
        durationMinutes: map['duration_minutes'] as int,
        recurrence: recurrenceFromDb(map['recurrence'] as String),
        recurrenceUntil: map['recurrence_until'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['recurrence_until'] as int),
        notifyMinutesBefore: map['notify_minutes_before'] as int?,
      );

  // ---------------------------------------------------------------------------
  // Recurrence expansion (pure logic, covered by test/recurrence_test.dart).
  // ---------------------------------------------------------------------------

  /// Builds the start of the i-th occurrence (i == 0 is the original event).
  DateTime _occurrenceAt(int i) {
    switch (recurrence) {
      case Recurrence.none:
        return start;
      case Recurrence.daily:
        return DateTime(
            start.year, start.month, start.day + i, start.hour, start.minute);
      case Recurrence.weekly:
        return DateTime(start.year, start.month, start.day + 7 * i, start.hour,
            start.minute);
      case Recurrence.monthly:
        return _clamped(
            start.year, start.month + i, start.day, start.hour, start.minute);
      case Recurrence.yearly:
        return _clamped(
            start.year + i, start.month, start.day, start.hour, start.minute);
    }
  }

  /// Builds a date clamping the day to the last valid day of the target month
  /// (e.g. Jan 31 + 1 month -> Feb 28/29; Feb 29 + 1 year -> Feb 28).
  static DateTime _clamped(int year, int month, int day, int hour, int minute) {
    final normYear = year + ((month - 1) ~/ 12);
    final normMonth = ((month - 1) % 12) + 1;
    final lastDay = DateTime(normYear, normMonth + 1, 0).day;
    final clampedDay = day > lastDay ? lastDay : day;
    return DateTime(normYear, normMonth, clampedDay, hour, minute);
  }

  /// A safe lower bound for the occurrence index whose start is >= [from],
  /// so expansion never scans from the distant past. Never overshoots.
  int _lowerBoundIndex(DateTime from) {
    if (from.isBefore(start)) return 0;
    switch (recurrence) {
      case Recurrence.none:
        return 0;
      case Recurrence.daily:
        return from.difference(start).inDays - 1;
      case Recurrence.weekly:
        return from.difference(start).inDays ~/ 7 - 1;
      case Recurrence.monthly:
        return (from.year - start.year) * 12 + (from.month - start.month) - 1;
      case Recurrence.yearly:
        return from.year - start.year - 1;
    }
  }

  DateTime? get _untilEndOfDay => recurrenceUntil == null
      ? null
      : DateTime(recurrenceUntil!.year, recurrenceUntil!.month,
          recurrenceUntil!.day, 23, 59, 59, 999);

  /// Start times of occurrences with start in `[rangeStart, rangeEnd)`.
  List<DateTime> occurrencesBetween(DateTime rangeStart, DateTime rangeEnd) {
    final result = <DateTime>[];
    if (recurrence == Recurrence.none) {
      if (!start.isBefore(rangeStart) && start.isBefore(rangeEnd)) {
        result.add(start);
      }
      return result;
    }
    final until = _untilEndOfDay;
    var i = _lowerBoundIndex(rangeStart);
    if (i < 0) i = 0;
    var guard = 0;
    while (guard++ < 200000) {
      final occ = _occurrenceAt(i);
      if (!occ.isBefore(rangeEnd)) break;
      if (until != null && occ.isAfter(until)) break;
      if (!occ.isBefore(rangeStart)) result.add(occ);
      i++;
    }
    return result;
  }

  /// First occurrence start at or after [from], honoring [recurrenceUntil].
  DateTime? firstStartOnOrAfter(DateTime from) {
    if (recurrence == Recurrence.none) {
      return start.isBefore(from) ? null : start;
    }
    final until = _untilEndOfDay;
    var i = _lowerBoundIndex(from);
    if (i < 0) i = 0;
    var guard = 0;
    while (guard++ < 200000) {
      final occ = _occurrenceAt(i);
      if (until != null && occ.isAfter(until)) return null;
      if (!occ.isBefore(from)) return occ;
      i++;
    }
    return null;
  }
}

/// A concrete occurrence of an [Event] on the calendar (its expanded start).
class EventOccurrence {
  final Event event;
  final DateTime start;
  const EventOccurrence({required this.event, required this.start});

  DateTime get end => start.add(Duration(minutes: event.durationMinutes));
}
