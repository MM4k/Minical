import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/category_controller.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/event.dart';
import '../../utils/time_format.dart';
import 'day_cell.dart';
import 'nav_button.dart';

const double _navWidth = 40;

/// Whole month on a single screen (Sunday-first). Only the weeks the month
/// spans are rendered. The weekday row carries the prev/next arrows in its
/// corners; each day shows its events' start time + title.
class MonthView extends StatelessWidget {
  const MonthView({
    super.key,
    required this.anchor,
    required this.onEditEvent,
    required this.onNewEvent,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime anchor;
  final ValueChanged<Event> onEditEvent;
  final void Function(DateTime date, int? hour) onNewEvent;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();

    final firstOfMonth = DateTime(anchor.year, anchor.month, 1);
    final leading = firstOfMonth.weekday % 7; // Sun=0 .. Sat=6
    final gridStart = firstOfMonth.subtract(Duration(days: leading));
    final daysInMonth = DateTime(anchor.year, anchor.month + 1, 0).day;
    final weekCount = ((leading + daysInMonth) / 7).ceil();

    final events = context.watch<EventController>();
    final categories = context.watch<CategoryController>();
    final use24h = context.watch<SettingsController>().settings.use24hTime;
    final timeFormat = timeFormatOf(localeName, use24h: use24h);
    Color colorOf(int? id) {
      final c = categories.byId(id);
      return c != null ? Color(c.color) : theme.colorScheme.primary;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final weekdayLabels = List.generate(
      7,
      (i) => DateFormat.E(localeName).format(gridStart.add(Duration(days: i))),
    );

    return Column(
      children: [
        Row(
          children: [
            CalendarNavButton(
              icon: Icons.chevron_left,
              width: _navWidth,
              onPressed: onPrev,
            ),
            for (final label in weekdayLabels)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
            CalendarNavButton(
              icon: Icons.chevron_right,
              width: _navWidth,
              onPressed: onNext,
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _navWidth),
            child: Column(
              children: List.generate(weekCount, (week) {
                return Expanded(
                  child: Row(
                    children: List.generate(7, (dow) {
                      final date =
                          gridStart.add(Duration(days: week * 7 + dow));
                      final dayKey = DateTime(date.year, date.month, date.day);
                      return Expanded(
                        child: CalendarDayCell(
                          date: date,
                          occurrences: events.occurrencesForDay(date),
                          isToday: _sameDay(date, today),
                          inMonth: date.month == anchor.month,
                          timeFormat: timeFormat,
                          colorOf: colorOf,
                          onNewEvent: () => onNewEvent(dayKey, null),
                          onEditEvent: onEditEvent,
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
