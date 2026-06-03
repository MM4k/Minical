import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/event.dart';

/// Thin, best-effort wrapper around local notifications. Every public method is
/// guarded so a failure never crashes the app (notifications are optional).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();
      try {
        final localZone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(localZone.identifier));
      } catch (_) {
        // Fall back to UTC if the local timezone can't be resolved.
      }

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const windows = WindowsInitializationSettings(
        appName: 'Minical',
        appUserModelId: 'com.minical.minical',
        guid: '4f1d2c8e-9a3b-4f6a-bd2e-7c5a1b3e9d10',
      );
      const settings =
          InitializationSettings(android: android, windows: windows);
      await _plugin.initialize(settings: settings);

      // Android 13+ runtime permission (no-op on other platforms).
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _ready = true;
    } catch (e) {
      debugPrint('NotificationService.init failed: $e');
    }
  }

  int _idFor(int eventId) => eventId & 0x7fffffff;

  NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
          'minical_events',
          'Event reminders',
          channelDescription: 'Reminders for calendar events',
          importance: Importance.high,
          priority: Priority.high,
        ),
        windows: WindowsNotificationDetails(),
      );

  /// (Re)schedules the next upcoming reminder for [event]. Cancels first so an
  /// edit never leaves a stale reminder behind.
  Future<void> scheduleForEvent(Event event) async {
    final id = event.id;
    if (!_ready || id == null) return;
    await cancelForEvent(id);

    final minutesBefore = event.notifyMinutesBefore;
    if (minutesBefore == null) return;

    final now = DateTime.now();
    // The reminder fires `minutesBefore` before an occurrence; search from the
    // earliest occurrence whose reminder could still be in the future.
    var occurrence =
        event.firstStartOnOrAfter(now.subtract(Duration(minutes: minutesBefore)));
    while (occurrence != null) {
      final reminderTime = occurrence.subtract(Duration(minutes: minutesBefore));
      if (reminderTime.isAfter(now)) break;
      occurrence =
          event.firstStartOnOrAfter(occurrence.add(const Duration(minutes: 1)));
    }
    if (occurrence == null) return;

    final reminderTime = occurrence.subtract(Duration(minutes: minutesBefore));
    try {
      await _plugin.zonedSchedule(
        id: _idFor(id),
        title: event.title,
        scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
        notificationDetails: _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('NotificationService.scheduleForEvent failed: $e');
    }
  }

  Future<void> cancelForEvent(int eventId) async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: _idFor(eventId));
    } catch (_) {}
  }
}
