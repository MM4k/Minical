import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/event.dart';

/// A single day inside the month grid. Shows the day number plus as many event
/// titles as fit in the available height (the rest collapse into "+N").
///
/// Tapping an event opens it for editing; tapping empty space creates a new
/// event on this day. The cell never overflows: the number of visible chips is
/// derived from the height the layout actually gives it.
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.date,
    required this.occurrences,
    required this.isToday,
    required this.inMonth,
    required this.timeFormat,
    required this.colorOf,
    required this.onNewEvent,
    required this.onEditEvent,
  });

  final DateTime date;
  final List<EventOccurrence> occurrences;
  final bool isToday;
  final bool inMonth;

  /// When non-null, each title is prefixed with its start time.
  final DateFormat? timeFormat;
  final Color Function(int? categoryId) colorOf;
  final VoidCallback onNewEvent;
  final ValueChanged<Event> onEditEvent;

  static const double _numberHeight = 20;
  static const double _chipHeight = 18; // 16 chip + 2 spacing

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onNewEvent,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.all(3),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final available = constraints.maxHeight - _numberHeight;
            final capacity = available > 0 ? (available / _chipHeight).floor() : 0;
            final total = occurrences.length;

            int visible;
            var overflow = 0;
            if (total <= capacity) {
              visible = total;
            } else if (capacity <= 0) {
              visible = 0;
              overflow = total;
            } else {
              visible = capacity - 1; // reserve a row for the "+N" label
              overflow = total - visible;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _dayNumber(scheme),
                for (var i = 0; i < visible; i++) _eventChip(occurrences[i]),
                if (overflow > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 2, top: 1),
                    child: Text(
                      '+$overflow',
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _dayNumber(ColorScheme scheme) {
    final color = isToday
        ? scheme.onPrimary
        : inMonth
            ? scheme.onSurface
            : scheme.onSurface.withValues(alpha: 0.35);
    final text = Text(
      '${date.day}',
      style: TextStyle(
        fontSize: 12,
        height: 1,
        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        color: color,
      ),
    );
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        height: _numberHeight,
        child: isToday
            ? Container(
                width: 20,
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                child: text,
              )
            : Padding(padding: const EdgeInsets.only(left: 2), child: text),
      ),
    );
  }

  Widget _eventChip(EventOccurrence occ) {
    final color = colorOf(occ.event.categoryId);
    final label = timeFormat != null
        ? '${timeFormat!.format(occ.start)}  ${occ.event.title}'
        : occ.event.title;
    final onColor = color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: GestureDetector(
        onTap: () => onEditEvent(occ.event),
        child: Container(
          height: 16,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, height: 1, color: onColor),
          ),
        ),
      ),
    );
  }
}
