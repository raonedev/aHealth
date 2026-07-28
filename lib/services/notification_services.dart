import 'package:ahealth/app_routes.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:health/health.dart';

// Add this OUTSIDE the class, at the bottom of the file (or top, either works)
import 'dart:math';

@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse response) async {
  if (response.actionId == 'log_water_glass') {
    await Health().configure();

    final now = DateTime.now();
    final earlier = now.subtract(const Duration(seconds: 30));

    await Health().writeHealthData(
      value: 0.25,
      type: HealthDataType.WATER,
      startTime: earlier,
      endTime: now,
    );

    // Re-init timezone + a fresh plugin instance, since this isolate
    // has none of the state from main()/HealthNotificationService.
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    final bgPlugin = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await bgPlugin.initialize(
      settings: const InitializationSettings(android: androidInit),
    );

    final midnight = DateTime(now.year, now.month, now.day);
    final steps = await Health().getTotalStepsInInterval(midnight, now);

    final randomMinutes = 5 + Random().nextInt(6); // 5,6,7,8,9,10
    final scheduled =
        tz.TZDateTime.now(tz.local).add(Duration(minutes: randomMinutes));

    await bgPlugin.zonedSchedule(
      id: 301,
      title: '🚶 Steps Update',
      body: steps != null
          ? 'You\'ve taken $steps steps so far today!'
          : 'Couldn\'t read your step count right now.',
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'steps_summary_channel',
          'Step Count Summary',
          channelDescription: 'Shows your current step count',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'steps',
    );
  }
}

class HealthNotificationService {
  static final HealthNotificationService _instance =
      HealthNotificationService._internal();

  factory HealthNotificationService() => _instance;
  HealthNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _logWaterActionId = 'log_water_glass';
  static const String _logMealActionId = 'log_meal';
  static const double _glassSizeLiters = 0.25;

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final darwin = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          'water_category',
          actions: [
            DarwinNotificationAction.plain(
              _logWaterActionId,
              'Log 1 Glass',
              options: {DarwinNotificationActionOption.foreground},
            ),
          ],
        ),
        DarwinNotificationCategory(
          'meal_category',
          actions: [
            DarwinNotificationAction.plain(
              _logMealActionId,
              'Log Meal',
              options: {DarwinNotificationActionOption.foreground},
            ),
          ],
        ),
      ],
    );

    await _plugin.initialize(
      settings: InitializationSettings(android: android, iOS: darwin),
      onDidReceiveNotificationResponse: _onTapped,
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
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
        '[HealthNotif] Tapped id=${response.id} actionId=${response.actionId} payload=${response.payload}');

    if (response.actionId == _logWaterActionId) {
      _logGlassToHealth();
    } else if (response.actionId == _logMealActionId ||
        response.payload == 'meal') {
      AppRoutes.router.go('/shell/nutrition');
    }
  }

  Future<void> _logGlassToHealth() async {
    final now = DateTime.now();
    final earlier = now.subtract(const Duration(seconds: 30));

    final success = await Health().writeHealthData(
      value: _glassSizeLiters,
      type: HealthDataType.WATER,
      startTime: earlier,
      endTime: now,
    );

    debugPrint(success
        ? '[HealthNotif] Logged $_glassSizeLiters L to Health Connect'
        : '[HealthNotif] Failed to log water to Health Connect');
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
          actions: [
            AndroidNotificationAction(
              'log_water_glass',
              'Log 1 Glass',
              showsUserInterface: false,
            ),
          ],
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
          categoryIdentifier: 'water_category',
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
          actions: [
            AndroidNotificationAction(
              'log_meal',
              'Log Meal',
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          categoryIdentifier: 'meal_category',
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