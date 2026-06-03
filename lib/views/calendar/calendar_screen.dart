import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/event.dart';
import '../event/event_editor_screen.dart';
import '../settings/side_panel.dart';
import 'calendar_view_mode.dart';
import 'month_view.dart';
import 'week_view.dart';

/// The main screen: calendar on the left, a fixed options panel on the right.
/// There is no top app bar — navigation arrows live on the calendar's weekday
/// row and the period/today/view controls live at the top of the side panel.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarViewMode _mode = CalendarViewMode.month;
  late DateTime _anchor;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _anchor = DateTime(now.year, now.month, now.day);
  }

  void _navigate(int delta) {
    setState(() {
      _anchor = _mode == CalendarViewMode.month
          ? DateTime(_anchor.year, _anchor.month + delta, _anchor.day)
          : _anchor.add(Duration(days: 7 * delta));
    });
  }

  void _goToday() {
    final now = DateTime.now();
    setState(() => _anchor = DateTime(now.year, now.month, now.day));
  }

  void _newEvent(DateTime date, int? hour) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => EventEditorScreen(initialDate: date, initialHour: hour),
    ));
  }

  void _editEvent(Event event) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => EventEditorScreen(existing: event),
    ));
  }

  String _periodLabel(String localeName) {
    if (_mode == CalendarViewMode.month) {
      return toBeginningOfSentenceCase(
        DateFormat.yMMMM(localeName).format(_anchor),
        localeName,
      );
    }
    final leading = _anchor.weekday % 7;
    final start = _anchor.subtract(Duration(days: leading));
    final end = start.add(const Duration(days: 6));
    final format = DateFormat.MMMd(localeName);
    return '${format.format(start)} – ${format.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();

    final calendar = _mode == CalendarViewMode.month
        ? MonthView(
            anchor: _anchor,
            onEditEvent: _editEvent,
            onNewEvent: _newEvent,
            onPrev: () => _navigate(-1),
            onNext: () => _navigate(1),
          )
        : WeekView(
            anchor: _anchor,
            onEditEvent: _editEvent,
            onNewEvent: _newEvent,
            onPrev: () => _navigate(-1),
            onNext: () => _navigate(1),
          );

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: SafeArea(
              right: false,
              child: Stack(
                children: [
                  Positioned.fill(child: calendar),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton(
                      tooltip: l.addEvent,
                      onPressed: () {
                        final now = DateTime.now();
                        _newEvent(
                            DateTime(now.year, now.month, now.day), null);
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SidePanel(
            periodLabel: _periodLabel(localeName),
            mode: _mode,
            onModeChanged: (mode) => setState(() => _mode = mode),
            onToday: _goToday,
          ),
        ],
      ),
    );
  }
}
