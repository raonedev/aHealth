import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

/// Notification IDs
/// Water reminders: 100–199
/// Meal reminders:  200 (breakfast), 201 (lunch), 202 (dinner)
class HealthNotificationService {
  static final HealthNotificationService _instance =
      HealthNotificationService._internal();

  factory HealthNotificationService() => _instance;
  HealthNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ─── Init ───────────────────────────────────────────────────────────────────

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

  // ─── Water Reminders ────────────────────────────────────────────────────────

  /// Schedule water reminders every [frequencyHours] hours
  /// between [startTime] and [endTime] (TimeOfDay), daily.
  ///
  /// Example: startTime=08:00, endTime=22:00, frequencyHours=2
  /// → notifications at 08:00, 10:00, 12:00, 14:00, 16:00, 18:00, 20:00, 22:00
  Future<void> scheduleWaterReminders({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    int frequencyHours = 2,
  }) async {
    await cancelWaterReminders();

    final now = tz.TZDateTime.now(tz.local);
    int idOffset = 100;

    TimeOfDay cursor = startTime;

    while (!_isAfter(cursor, endTime)) {
      final scheduled = _nextOccurrence(now, cursor);

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

      debugPrint('[HealthNotif] Water scheduled at $cursor (id=$idOffset)');

      cursor = _addHours(cursor, frequencyHours);
      idOffset++;

      if (idOffset >= 200) break; // safety — max 100 water slots
    }
  }

  Future<void> cancelWaterReminders() async {
    for (int id = 100; id < 200; id++) {
      await _plugin.cancel(id: id);
    }
  }

  // ─── Meal Reminders ─────────────────────────────────────────────────────────

  /// Schedule daily meal log reminders.
  /// Pass null to skip that meal.
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

      final scheduled = _nextOccurrence(now, time);

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

  // ─── Cancel All ─────────────────────────────────────────────────────────────

  Future<void> cancelAll() => _plugin.cancelAll();

  // ─── Debug ──────────────────────────────────────────────────────────────────

  Future<List<PendingNotificationRequest>> getPending() =>
      _plugin.pendingNotificationRequests();

  // ─── Notification Details ───────────────────────────────────────────────────

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

  // ─── Helpers ────────────────────────────────────────────────────────────────

  /// Returns the next TZDateTime for the given TimeOfDay (today or tomorrow).
  tz.TZDateTime _nextOccurrence(tz.TZDateTime now, TimeOfDay time) {
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Adds [hours] to a TimeOfDay (wraps past midnight).
  TimeOfDay _addHours(TimeOfDay t, int hours) {
    final total = t.hour + hours;
    return TimeOfDay(hour: total % 24, minute: t.minute);
  }

  /// Returns true if [a] is strictly after [b] in wall-clock time.
  bool _isAfter(TimeOfDay a, TimeOfDay b) =>
      a.hour > b.hour || (a.hour == b.hour && a.minute > b.minute);
}
