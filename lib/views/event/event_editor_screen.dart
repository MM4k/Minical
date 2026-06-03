import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/category_controller.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../models/event.dart';
import '../../models/recurrence.dart';
import '../../utils/time_format.dart';

/// Create or edit a single event.
class EventEditorScreen extends StatefulWidget {
  const EventEditorScreen({
    super.key,
    this.existing,
    this.initialDate,
    this.initialHour,
  });

  final Event? existing;
  final DateTime? initialDate;

  /// Pre-selected hour (0-23) when creating from a week-view time slot.
  final int? initialHour;

  @override
  State<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends State<EventEditorScreen> {
  static const _durations = [15, 30, 45, 60, 90, 120, 180, 240];
  static const _reminders = <int?>[null, 0, 5, 10, 15, 30, 60];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;

  int? _categoryId;
  late DateTime _date;
  late TimeOfDay _time;
  late int _duration;
  late Recurrence _recurrence;
  DateTime? _repeatUntil;
  int? _notifyMinutesBefore;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _titleController = TextEditingController(text: existing.title);
      _categoryId = existing.categoryId;
      _date = DateTime(existing.start.year, existing.start.month, existing.start.day);
      _time = TimeOfDay(hour: existing.start.hour, minute: existing.start.minute);
      _duration = existing.durationMinutes;
      _recurrence = existing.recurrence;
      _repeatUntil = existing.recurrenceUntil;
      _notifyMinutesBefore = existing.notifyMinutesBefore;
    } else {
      _titleController = TextEditingController();
      final base = widget.initialDate ?? DateTime.now();
      _date = DateTime(base.year, base.month, base.day);
      _time = TimeOfDay(hour: widget.initialHour ?? TimeOfDay.now().hour, minute: 0);
      _duration = 60;
      _recurrence = Recurrence.none;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _pickRepeatUntil() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _repeatUntil ?? _date,
      firstDate: _date,
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _repeatUntil = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final start =
        DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final controller = context.read<EventController>();

    final event = (widget.existing ??
            Event(title: '', start: start, durationMinutes: _duration))
        .copyWith(
      title: _titleController.text.trim(),
      start: start,
      durationMinutes: _duration,
      recurrence: _recurrence,
      categoryId: _categoryId,
      clearCategory: _categoryId == null,
      recurrenceUntil: _recurrence == Recurrence.none ? null : _repeatUntil,
      clearRecurrenceUntil: _recurrence == Recurrence.none || _repeatUntil == null,
      notifyMinutesBefore: _notifyMinutesBefore,
      clearNotify: _notifyMinutesBefore == null,
    );

    if (_isEditing) {
      await controller.update(event);
    } else {
      await controller.add(event);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.deleteEventTitle),
        content: Text(l.deleteEventMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<EventController>().remove(widget.existing!);
    if (mounted) Navigator.of(context).pop();
  }

  String _recurrenceLabel(AppLocalizations l, Recurrence r) => switch (r) {
        Recurrence.none => l.repeatNever,
        Recurrence.daily => l.repeatDaily,
        Recurrence.weekly => l.repeatWeekly,
        Recurrence.monthly => l.repeatMonthly,
        Recurrence.yearly => l.repeatYearly,
      };

  String _reminderLabel(AppLocalizations l, int? minutes) {
    if (minutes == null) return l.reminderNone;
    if (minutes == 0) return l.reminderAtTime;
    return l.reminderMinutesBefore(minutes);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat.yMMMMEEEEd(localeName);
    final use24h = context.watch<SettingsController>().settings.use24hTime;
    final timeFormat = timeFormatOf(localeName, use24h: use24h);
    final categories = context.watch<CategoryController>().categories;

    final categoryIds = categories.map((c) => c.id).toList();
    final categoryValue =
        (_categoryId != null && categoryIds.contains(_categoryId)) ? _categoryId : null;

    final durationOptions = ({..._durations, _duration}.toList()..sort());
    final reminderOptions =
        _reminders.contains(_notifyMinutesBefore) ? _reminders : [..._reminders, _notifyMinutesBefore];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.editEvent : l.newEvent),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: l.delete,
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
          IconButton(
            tooltip: l.save,
            onPressed: _save,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l.eventTitle,
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? l.titleRequired : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: categoryValue,
              decoration: InputDecoration(
                labelText: l.category,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem<int?>(value: null, child: Text(l.noCategory)),
                for (final c in categories)
                  DropdownMenuItem<int?>(
                    value: c.id,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(c.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
                  ),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(l.date),
              trailing: Text(dateFormat.format(_date)),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined),
              title: Text(l.startTime),
              trailing: Text(timeFormat.format(
                DateTime(_date.year, _date.month, _date.day, _time.hour,
                    _time.minute),
              )),
              onTap: _pickTime,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _duration,
              decoration: InputDecoration(
                labelText: l.duration,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final d in durationOptions)
                  DropdownMenuItem<int>(
                    value: d,
                    child: Text(l.durationMinutes(d)),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _duration = value ?? _duration),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Recurrence>(
              initialValue: _recurrence,
              decoration: InputDecoration(
                labelText: l.repeat,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final r in Recurrence.values)
                  DropdownMenuItem<Recurrence>(
                    value: r,
                    child: Text(_recurrenceLabel(l, r)),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _recurrence = value ?? Recurrence.none),
            ),
            if (_recurrence != Recurrence.none)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_repeat_outlined),
                title: Text(l.repeatUntil),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_repeatUntil == null
                        ? l.repeatForever
                        : DateFormat.yMMMd(localeName).format(_repeatUntil!)),
                    if (_repeatUntil != null)
                      IconButton(
                        tooltip: l.clear,
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _repeatUntil = null),
                      ),
                  ],
                ),
                onTap: _pickRepeatUntil,
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _notifyMinutesBefore,
              decoration: InputDecoration(
                labelText: l.reminder,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final m in reminderOptions)
                  DropdownMenuItem<int?>(
                    value: m,
                    child: Text(_reminderLabel(l, m)),
                  ),
              ],
              onChanged: (value) => setState(() => _notifyMinutesBefore = value),
            ),
          ],
        ),
      ),
    );
  }
}
