import 'package:flutter/foundation.dart';

import '../data/event_repository.dart';
import '../data/notification_service.dart';
import '../models/event.dart';

/// Holds events and exposes CRUD plus the occurrence queries the calendar uses.
/// Reminder (re)scheduling is kept in sync with every change.
class EventController extends ChangeNotifier {
  EventController(this._repo, this._notifications);

  final EventRepository _repo;
  final NotificationService _notifications;
  List<Event> _events = [];

  List<Event> get events => List.unmodifiable(_events);

  Future<void> load() async {
    _events = await _repo.getAll();
    notifyListeners();
    for (final e in _events) {
      await _notifications.scheduleForEvent(e);
    }
  }

  Future<void> add(Event event) async {
    await _repo.insert(event);
    await load();
  }

  Future<void> update(Event event) async {
    await _repo.update(event);
    await load();
  }

  Future<void> remove(Event event) async {
    final id = event.id;
    if (id != null) {
      await _repo.delete(id);
      await _notifications.cancelForEvent(id);
    }
    await load();
  }

  /// Occurrences that start on [day], sorted by time.
  List<EventOccurrence> occurrencesForDay(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final list = <EventOccurrence>[];
    for (final event in _events) {
      for (final occ in event.occurrencesBetween(dayStart, dayEnd)) {
        list.add(EventOccurrence(event: event, start: occ));
      }
    }
    list.sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  /// The set of dates (midnight) that have at least one occurrence in the
  /// `[rangeStart, rangeEnd)` window — used to draw the dots in the month grid.
  Set<DateTime> daysWithEventsBetween(DateTime rangeStart, DateTime rangeEnd) {
    final days = <DateTime>{};
    for (final event in _events) {
      for (final occ in event.occurrencesBetween(rangeStart, rangeEnd)) {
        days.add(DateTime(occ.year, occ.month, occ.day));
      }
    }
    return days;
  }
}
