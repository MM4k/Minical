/// How an event repeats over time.
enum Recurrence { none, daily, weekly, monthly, yearly }

/// Parses the value stored in the database back into a [Recurrence].
Recurrence recurrenceFromDb(String value) => Recurrence.values.firstWhere(
      (r) => r.name == value,
      orElse: () => Recurrence.none,
    );
