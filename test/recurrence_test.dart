import 'package:flutter_test/flutter_test.dart';
import 'package:minical/models/event.dart';
import 'package:minical/models/recurrence.dart';

void main() {
  group('occurrencesBetween', () {
    test('non-recurring event appears only on its own day', () {
      final event = Event(
        title: 'one-off',
        start: DateTime(2026, 6, 3, 9),
        durationMinutes: 60,
      );
      expect(
        event.occurrencesBetween(DateTime(2026, 6, 1), DateTime(2026, 7, 1)),
        [DateTime(2026, 6, 3, 9)],
      );
      expect(
        event.occurrencesBetween(DateTime(2026, 7, 1), DateTime(2026, 8, 1)),
        isEmpty,
      );
    });

    test('daily expands across the whole window', () {
      final event = Event(
        title: 'daily',
        start: DateTime(2026, 6, 3, 9),
        durationMinutes: 30,
        recurrence: Recurrence.daily,
      );
      // Jun 3 .. Jun 30 inclusive = 28 occurrences.
      expect(
        event.occurrencesBetween(DateTime(2026, 6, 1), DateTime(2026, 7, 1)).length,
        28,
      );
    });

    test('weekly steps by 7 days', () {
      final event = Event(
        title: 'weekly',
        start: DateTime(2026, 6, 3, 9),
        durationMinutes: 30,
        recurrence: Recurrence.weekly,
      );
      expect(
        event.occurrencesBetween(DateTime(2026, 6, 1), DateTime(2026, 7, 1)),
        [
          DateTime(2026, 6, 3, 9),
          DateTime(2026, 6, 10, 9),
          DateTime(2026, 6, 17, 9),
          DateTime(2026, 6, 24, 9),
        ],
      );
    });

    test('monthly clamps to the last valid day, then restores', () {
      final event = Event(
        title: 'monthly',
        start: DateTime(2026, 1, 31, 10),
        durationMinutes: 60,
        recurrence: Recurrence.monthly,
      );
      // 2026 is not a leap year -> Feb 28.
      expect(
        event.occurrencesBetween(DateTime(2026, 2, 1), DateTime(2026, 3, 1)),
        [DateTime(2026, 2, 28, 10)],
      );
      // March has 31 days -> the original day is restored.
      expect(
        event.occurrencesBetween(DateTime(2026, 3, 1), DateTime(2026, 4, 1)),
        [DateTime(2026, 3, 31, 10)],
      );
    });

    test('yearly clamps Feb 29 on non-leap years', () {
      final event = Event(
        title: 'yearly',
        start: DateTime(2024, 2, 29, 8),
        durationMinutes: 60,
        recurrence: Recurrence.yearly,
      );
      expect(
        event.occurrencesBetween(DateTime(2025, 1, 1), DateTime(2026, 1, 1)),
        [DateTime(2025, 2, 28, 8)],
      );
      // 2028 is a leap year -> Feb 29 is back.
      expect(
        event.occurrencesBetween(DateTime(2028, 1, 1), DateTime(2029, 1, 1)),
        [DateTime(2028, 2, 29, 8)],
      );
    });

    test('recurrenceUntil is inclusive of its day', () {
      final event = Event(
        title: 'bounded',
        start: DateTime(2026, 6, 3, 9),
        durationMinutes: 30,
        recurrence: Recurrence.daily,
        recurrenceUntil: DateTime(2026, 6, 10),
      );
      // Jun 3 .. Jun 10 inclusive = 8 occurrences.
      expect(
        event.occurrencesBetween(DateTime(2026, 6, 1), DateTime(2026, 7, 1)).length,
        8,
      );
    });
  });

  group('firstStartOnOrAfter', () {
    test('returns the next weekly occurrence', () {
      final event = Event(
        title: 'weekly',
        start: DateTime(2026, 6, 3, 9),
        durationMinutes: 30,
        recurrence: Recurrence.weekly,
      );
      expect(
        event.firstStartOnOrAfter(DateTime(2026, 6, 4)),
        DateTime(2026, 6, 10, 9),
      );
      // Exactly on a start counts.
      expect(
        event.firstStartOnOrAfter(DateTime(2026, 6, 3, 9)),
        DateTime(2026, 6, 3, 9),
      );
    });

    test('non-recurring event returns null once its start has passed', () {
      final event = Event(
        title: 'one-off',
        start: DateTime(2026, 6, 3, 9),
        durationMinutes: 30,
      );
      expect(event.firstStartOnOrAfter(DateTime(2026, 6, 1)), DateTime(2026, 6, 3, 9));
      expect(event.firstStartOnOrAfter(DateTime(2026, 6, 4)), isNull);
    });
  });
}
