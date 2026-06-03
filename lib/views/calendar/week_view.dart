import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/category_controller.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/event.dart';
import '../../utils/time_format.dart';
import 'nav_button.dart';

const double _hourHeight = 48;
const double _gutterWidth = 48;
const double _navWidth = 40;
const double _minEventHeight = 18;

/// One week as an hour-by-hour timetable (Sunday-first). Events are positioned
/// by their start time and sized by duration; tapping an empty slot creates a
/// new event at that day and hour.
class WeekView extends StatefulWidget {
  const WeekView({
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

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    // Start scrolled to ~7 AM so the morning is visible without scrolling.
    _scroll = ScrollController(initialScrollOffset: 7 * _hourHeight);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();

    final leading = widget.anchor.weekday % 7; // Sun=0 .. Sat=6
    final weekStart = DateTime(
      widget.anchor.year,
      widget.anchor.month,
      widget.anchor.day,
    ).subtract(Duration(days: leading));

    final events = context.watch<EventController>();
    final categories = context.watch<CategoryController>();
    Color colorOf(int? id) {
      final c = categories.byId(id);
      return c != null ? Color(c.color) : theme.colorScheme.primary;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final use24h = context.watch<SettingsController>().settings.use24hTime;
    final weekdayFormat = DateFormat.E(localeName);
    final timeFormat = timeFormatOf(localeName, use24h: use24h);
    final hourFormat = hourLabelFormatOf(localeName, use24h: use24h);
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Column(
      children: [
        // Sticky header row: prev arrow + the 7 day headers + next arrow.
        Row(
          children: [
            CalendarNavButton(
              icon: Icons.chevron_left,
              width: _gutterWidth,
              onPressed: widget.onPrev,
            ),
            for (final date in days)
              Expanded(
                child: _DayHeader(
                  weekday: weekdayFormat.format(date),
                  day: date.day,
                  isToday: _sameDay(date, today),
                ),
              ),
            CalendarNavButton(
              icon: Icons.chevron_right,
              width: _navWidth,
              onPressed: widget.onNext,
            ),
          ],
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            child: SizedBox(
              height: 24 * _hourHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HourGutter(hourFormat: hourFormat),
                  for (final date in days)
                    Expanded(
                      child: _DayColumn(
                        date: date,
                        occurrences: events.occurrencesForDay(date),
                        colorOf: colorOf,
                        timeFormat: timeFormat,
                        onNewEvent: widget.onNewEvent,
                        onEditEvent: widget.onEditEvent,
                      ),
                    ),
                  const SizedBox(width: _navWidth),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.weekday,
    required this.day,
    required this.isToday,
  });

  final String weekday;
  final int day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: isToday ? scheme.primaryContainer : null,
      child: Column(
        children: [
          Text(
            weekday,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            '$day',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? scheme.onPrimaryContainer : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _HourGutter extends StatelessWidget {
  const _HourGutter({required this.hourFormat});

  final DateFormat hourFormat;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .labelSmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return SizedBox(
      width: _gutterWidth,
      child: Column(
        children: List.generate(24, (h) {
          return SizedBox(
            height: _hourHeight,
            child: Padding(
              padding: const EdgeInsets.only(right: 4, top: 2),
              child: Align(
                alignment: Alignment.topRight,
                child: Text(hourFormat.format(DateTime(2000, 1, 1, h)),
                    style: style),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.date,
    required this.occurrences,
    required this.colorOf,
    required this.timeFormat,
    required this.onNewEvent,
    required this.onEditEvent,
  });

  final DateTime date;
  final List<EventOccurrence> occurrences;
  final Color Function(int? categoryId) colorOf;
  final DateFormat timeFormat;
  final void Function(DateTime date, int? hour) onNewEvent;
  final ValueChanged<Event> onEditEvent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placed = _placeEvents(occurrences);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          children: [
            // Hourly gridlines.
            Column(
              children: List.generate(24, (h) {
                return Container(
                  height: _hourHeight,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                      left: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                    ),
                  ),
                );
              }),
            ),
            // Tap an empty slot to create an event at that hour.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  final hour =
                      (details.localPosition.dy / _hourHeight).floor().clamp(0, 23);
                  onNewEvent(DateTime(date.year, date.month, date.day), hour);
                },
              ),
            ),
            // Event blocks.
            for (final p in placed)
              _positionedEvent(context, p, width),
          ],
        );
      },
    );
  }

  Widget _positionedEvent(BuildContext context, _Placed p, double width) {
    final start = p.occurrence.start;
    final startMinutes = start.hour * 60 + start.minute;
    final top = startMinutes / 60 * _hourHeight;
    final rawHeight = p.occurrence.event.durationMinutes / 60 * _hourHeight;
    final maxHeight = 24 * _hourHeight - top;
    final height = rawHeight.clamp(_minEventHeight, maxHeight);

    final laneWidth = width / p.laneCount;
    final left = p.lane * laneWidth;
    final color = colorOf(p.occurrence.event.categoryId);
    final onColor = color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Positioned(
      top: top,
      left: left,
      width: laneWidth - 1,
      height: height,
      child: GestureDetector(
        onTap: () => onEditEvent(p.occurrence.event),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${timeFormat.format(start)}  ${p.occurrence.event.title}',
            maxLines: height > _hourHeight ? 3 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, height: 1.1, color: onColor),
          ),
        ),
      ),
    );
  }
}

class _Placed {
  final EventOccurrence occurrence;
  final int lane;
  final int laneCount;
  const _Placed(this.occurrence, this.lane, this.laneCount);
}

/// Greedy interval partitioning: overlapping events are split into side-by-side
/// lanes; non-overlapping events each get the full column width.
List<_Placed> _placeEvents(List<EventOccurrence> occurrences) {
  final sorted = [...occurrences]..sort((a, b) => a.start.compareTo(b.start));
  final result = <_Placed>[];
  var i = 0;
  while (i < sorted.length) {
    final cluster = <EventOccurrence>[sorted[i]];
    var clusterEnd = sorted[i].end;
    var j = i + 1;
    while (j < sorted.length && sorted[j].start.isBefore(clusterEnd)) {
      cluster.add(sorted[j]);
      if (sorted[j].end.isAfter(clusterEnd)) clusterEnd = sorted[j].end;
      j++;
    }
    final laneEnds = <DateTime>[];
    final laneOf = <int>[];
    for (final occ in cluster) {
      var lane = -1;
      for (var k = 0; k < laneEnds.length; k++) {
        if (!laneEnds[k].isAfter(occ.start)) {
          lane = k;
          break;
        }
      }
      if (lane == -1) {
        lane = laneEnds.length;
        laneEnds.add(occ.end);
      } else {
        laneEnds[lane] = occ.end;
      }
      laneOf.add(lane);
    }
    final laneCount = laneEnds.length;
    for (var c = 0; c < cluster.length; c++) {
      result.add(_Placed(cluster[c], laneOf[c], laneCount));
    }
    i = j;
  }
  return result;
}
