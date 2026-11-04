import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:permission_handler/permission_handler.dart';

import '../../views/constants/strings.dart';

class NotificationService {
  NotificationService._private();
  static final NotificationService _instance = NotificationService._private();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const String _channelId = Strings.channelId;
  static const String _channelName = Strings.channelName;

  Future<void> initialize() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Tallinn'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Create Android channel
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await _ensureAndroidNotificationsEnabled(androidPlugin);
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.defaultImportance,
      );
      try {
        await androidPlugin.createNotificationChannel(channel);
      } catch (_) {}
    }

    // Request iOS permissions
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    try {
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (_) {}
  }

  int notificationIdForDate(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }

  /// Attempts to schedule a notification at [dateAtLocalTime].
  /// Returns the notification id if scheduled, or null if scheduling did not occur (e.g. permission denied).
  Future<int?> scheduleInjectionNotification(DateTime dateAtLocalTime) async {
    return scheduleNotification(
      dateAtLocalTime,
      Strings.notificationTitle,
      Strings.notificationBody,
      notificationIdForDate(dateAtLocalTime),
    );
  }

  Future<int?> scheduleNotification(
    DateTime dateAtLocalTime,
    String title,
    String body,
    int id,
  ) async {
    final scheduled = tz.TZDateTime.from(dateAtLocalTime, tz.local);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.max,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails();

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      if (!await _ensureAndroidNotificationsEnabled(androidPlugin)) {
        return null;
      }
    } else {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final req = await Permission.notification.request();
        if (!req.isGranted) {
          return null;
        }
      }
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.inexact,
    );

    return id;
  }

  Future<void> cancelNotificationById(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }
}

Future<bool> _ensureAndroidNotificationsEnabled(
  AndroidFlutterLocalNotificationsPlugin androidPlugin,
) async {
  var enabled = await androidPlugin.areNotificationsEnabled() ?? false;
  if (!enabled) {
    enabled = await androidPlugin.requestNotificationsPermission() ?? false;
  }
  return enabled;
}
