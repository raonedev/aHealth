import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class HealthNotificationService {
  static final HealthNotificationService _instance =
      HealthNotificationService._internal();

  factory HealthNotificationService() => _instance;
  HealthNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    await _plugin.initialize(
      settings: InitializationSettings(android: android, iOS: darwin),
      onDidReceiveNotificationResponse: _onTapped,
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _onTapped(NotificationResponse response) {
    debugPrint(
        '[HealthNotif] Tapped id=${response.id} payload=${response.payload}');
  }

  Future<void> scheduleWaterReminders({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    int frequencyHours = 2,
  }) async {
    await cancelWaterReminders();

    final now = tz.TZDateTime.now(tz.local);
    int idOffset = 100;
    TimeOfDay cursor = startTime;

    while (_toMinutes(cursor) <= _toMinutes(endTime)) {
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        cursor.hour,
        cursor.minute,
      );
      if (scheduled.isBefore(now.add(const Duration(seconds: 5)))) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id: idOffset,
        title: '💧 Hydration Reminder',
        body: 'Time to drink water! Stay hydrated.',
        scheduledDate: scheduled,
        notificationDetails: _waterDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'water',
      );

      debugPrint(
          '[HealthNotif] Water scheduled at ${cursor.hour}:${cursor.minute.toString().padLeft(2, '0')} (id=$idOffset)');

      cursor = _addHours(cursor, frequencyHours);
      idOffset++;
      if (idOffset >= 200) break;
    }
  }

  Future<void> cancelWaterReminders() async {
    for (int id = 100; id < 200; id++) {
      await _plugin.cancel(id: id);
    }
  }

  Future<void> scheduleMealReminders({
    TimeOfDay? breakfastTime = const TimeOfDay(hour: 8, minute: 0),
    TimeOfDay? lunchTime = const TimeOfDay(hour: 13, minute: 0),
    TimeOfDay? dinnerTime = const TimeOfDay(hour: 19, minute: 30),
  }) async {
    await cancelMealReminders();

    final meals = {
      200: (
        breakfastTime,
        '🍳 Breakfast Time',
        'Log your breakfast to track your day!'
      ),
      201: (lunchTime, '🥗 Lunch Time', 'Don\'t forget to log your lunch!'),
      202: (
        dinnerTime,
        '🍽️ Dinner Time',
        'Log your dinner to complete today\'s intake!'
      ),
    };

    final now = tz.TZDateTime.now(tz.local);

    for (final entry in meals.entries) {
      final id = entry.key;
      final (time, title, body) = entry.value;
      if (time == null) continue;

      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (scheduled.isBefore(now.add(const Duration(seconds: 5)))) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduled,
        notificationDetails: _mealDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'meal',
      );

      debugPrint('[HealthNotif] Meal reminder scheduled at $time (id=$id)');
    }
  }

  Future<void> cancelMealReminders() async {
    await _plugin.cancel(id: 200);
    await _plugin.cancel(id: 201);
    await _plugin.cancel(id: 202);
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<List<PendingNotificationRequest>> getPending() =>
      _plugin.pendingNotificationRequests();

  NotificationDetails _waterDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminder_channel',
          'Water Reminders',
          channelDescription: 'Hydration reminders throughout the day',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      );

  NotificationDetails _mealDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_reminder_channel',
          'Meal Reminders',
          channelDescription: 'Reminders to log meals',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  TimeOfDay _addHours(TimeOfDay t, int hours) {
    return TimeOfDay(hour: t.hour + hours, minute: t.minute);
  }

  Future<void> scheduleOneTimeNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String payload = '',
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now.add(const Duration(seconds: 5)))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: _waterDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    debugPrint(
        '[HealthNotif] One-time scheduled at ${time.hour}:${time.minute.toString().padLeft(2, '0')} (id=$id)');
  }
}
