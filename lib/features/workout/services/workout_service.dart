import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/services.dart' show rootBundle;
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constants.dart';
import '../models/workout_models.dart';

class WorkoutService {
  static final WorkoutService _instance = WorkoutService._internal();
  factory WorkoutService() => _instance;
  WorkoutService._internal();

  static const String _kWeeklyPlanKey = 'workout_weekly_plan_v1';
  static const String _kLogsKey = 'workout_logs_v1';

  List<Exercise>? _cachedExercises;
  Map<String, dynamic>? _cachedMeta;

  // Load exercises from assets/exercise.json
  Future<List<Exercise>> getExercises() async {
    if (_cachedExercises != null) return _cachedExercises!;
    try {
      final jsonStr = await rootBundle.loadString('assets/exercise.json');
      final List list = jsonDecode(jsonStr);
      _cachedExercises = list.map((e) => Exercise.fromJson(e)).toList();
      return _cachedExercises!;
    } catch (e, s) {
      dev.log('Error loading exercises', error: e, stackTrace: s);
      return [];
    }
  }

  // Load facets / meta from assets/meta.json
  Future<Map<String, dynamic>> getMeta() async {
    if (_cachedMeta != null) return _cachedMeta!;
    try {
      final jsonStr = await rootBundle.loadString('assets/meta.json');
      _cachedMeta = jsonDecode(jsonStr);
      return _cachedMeta!;
    } catch (e) {
      return {};
    }
  }

  // Plan: Get planned exercises for a specific weekday (1 = Mon, 7 = Sun)
  Future<List<PlannedExercise>> getPlanForDay(int dayOfWeek) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('${_kWeeklyPlanKey}_day_$dayOfWeek');
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List list = jsonDecode(jsonStr);
      return list.map((e) => PlannedExercise.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // Plan: Save planned exercises for a specific weekday
  Future<void> savePlanForDay(int dayOfWeek, List<PlannedExercise> exercises) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(exercises.map((e) => e.toJson()).toList());
    await prefs.setString('${_kWeeklyPlanKey}_day_$dayOfWeek', jsonStr);
  }

  // Plan: Add an exercise to day's plan
  Future<void> addExerciseToPlan(int dayOfWeek, PlannedExercise exercise) async {
    final current = await getPlanForDay(dayOfWeek);
    current.add(exercise);
    await savePlanForDay(dayOfWeek, current);
  }

  // Plan: Remove an exercise from day's plan
  Future<void> removeExerciseFromPlan(int dayOfWeek, String plannedId) async {
    final current = await getPlanForDay(dayOfWeek);
    current.removeWhere((e) => e.id == plannedId);
    await savePlanForDay(dayOfWeek, current);
  }

  // Plan: Clear all planned exercises for a single day
  Future<void> clearPlanForDay(int dayOfWeek) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_kWeeklyPlanKey}_day_$dayOfWeek');
  }

  // Plan: Clear planned exercises for the entire week
  Future<void> clearWeeklyPlan() async {
    final prefs = await SharedPreferences.getInstance();
    for (int day = 1; day <= 7; day++) {
      await prefs.remove('${_kWeeklyPlanKey}_day_$day');
    }
  }

  // Logs: Get all logged workouts (newest first)
  Future<List<WorkoutLog>> getWorkoutLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kLogsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List list = jsonDecode(jsonStr);
      final logs = list.map((e) => WorkoutLog.fromJson(e)).toList();
      logs.sort((a, b) => b.date.compareTo(a.date));
      return logs;
    } catch (_) {
      return [];
    }
  }

  // Health Connect: Check WORKOUT permission
  Future<bool> hasHealthPermission() async {
    try {
      final has = await Health().hasPermissions([HealthDataType.WORKOUT]);
      return has ?? false;
    } catch (_) {
      return false;
    }
  }

  // Health Connect: Request WORKOUT permission
  Future<bool> requestHealthPermission() async {
    try {
      final granted = await Health().requestAuthorization(
        [HealthDataType.WORKOUT],
        permissions: [HealthDataAccess.READ_WRITE],
      );
      return granted;
    } catch (e) {
      dev.log('Error requesting workout permission', error: e);
      return false;
    }
  }

  // Log Workout Session: saves locally and syncs to Health Connect
  Future<WorkoutLog> logWorkout({
    required String exerciseName,
    required String bodyPart,
    required int sets,
    required int reps,
    required double weightKg,
    required int durationMinutes,
    required int caloriesBurned,
    DateTime? date,
    bool syncHealthConnect = true,
  }) async {
    final logDate = date ?? DateTime.now();
    final startTime = logDate.subtract(Duration(minutes: durationMinutes));
    bool synced = false;

    if (syncHealthConnect) {
      try {
        final hasPerm = await hasHealthPermission();
        if (!hasPerm) {
          await requestHealthPermission();
        }
        synced = await Health().writeWorkoutData(
          activityType: HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING,
          start: startTime,
          end: logDate,
          totalEnergyBurned: caloriesBurned,
          totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
          title: exerciseName,
        );
      } catch (e) {
        dev.log('Error writing workout to Health Connect', error: e);
        synced = false;
      }
    }

    final newLog = WorkoutLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exerciseName: exerciseName,
      bodyPart: bodyPart,
      date: logDate,
      durationMinutes: durationMinutes,
      caloriesBurned: caloriesBurned,
      setsCompleted: sets,
      reps: reps,
      weightKg: weightKg,
      syncedHealthConnect: synced,
    );

    // Save locally
    final prefs = await SharedPreferences.getInstance();
    final logs = await getWorkoutLogs();
    logs.insert(0, newLog);
    await prefs.setString(_kLogsKey, jsonEncode(logs.map((e) => e.toJson()).toList()));

    return newLog;
  }

  // Check if first-time workout survey/onboarding is done
  Future<bool> isWorkoutOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefKeys.workoutOnboardingCompleted) ?? false;
  }

  // Mark first-time workout survey as completed
  Future<void> setWorkoutOnboardingCompleted({
    bool completed = true,
    String? goal,
    String? level,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKeys.workoutOnboardingCompleted, completed);
    if (goal != null) await prefs.setString(PrefKeys.workoutGoal, goal);
    if (level != null) await prefs.setString(PrefKeys.workoutLevel, level);
  }

  // Apply default recommended exercise plan from assets/general_plan.json
  Future<bool> applyRecommendedPlan(String goal, String level) async {
    try {
      final jsonStr = await rootBundle.loadString('assets/general_plan.json');
      final Map<String, dynamic> allPlans = jsonDecode(jsonStr);
      final levelPlan = allPlans[goal]?[level] as Map<String, dynamic>?;
      if (levelPlan == null) return false;

      final exercises = await getExercises();
      final exerciseMap = {for (final e in exercises) e.id: e};

      const dayKeys = [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ];

      for (int i = 0; i < dayKeys.length; i++) {
        final dayName = dayKeys[i];
        final dayOfWeek = i + 1; // 1 = Mon ... 7 = Sun
        final List ids = (levelPlan[dayName] as List?) ?? [];
        final plannedList = <PlannedExercise>[];

        for (int j = 0; j < ids.length; j++) {
          final id = ids[j].toString();
          final ex = exerciseMap[id];
          if (ex != null) {
            plannedList.add(
              PlannedExercise(
                id: '${DateTime.now().millisecondsSinceEpoch}_${dayOfWeek}_$j',
                exerciseId: ex.id,
                exerciseName: ex.name,
                bodyPart: ex.bodyPart,
                sets: 3,
                reps: 10,
                weightKg: 0.0,
                restSeconds: 60,
              ),
            );
          }
        }
        await savePlanForDay(dayOfWeek, plannedList);
      }
      return true;
    } catch (e, s) {
      dev.log('Error applying recommended plan', error: e, stackTrace: s);
      return false;
    }
  }

  // Delete a logged workout session
  Future<void> deleteWorkoutLog(String logId) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await getWorkoutLogs();
    logs.removeWhere((l) => l.id == logId);
    await prefs.setString(_kLogsKey, jsonEncode(logs.map((e) => e.toJson()).toList()));
  }

  // Update a logged workout session
  Future<void> updateWorkoutLog(WorkoutLog updatedLog) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await getWorkoutLogs();
    final index = logs.indexWhere((l) => l.id == updatedLog.id);
    if (index != -1) {
      logs[index] = updatedLog;
      await prefs.setString(_kLogsKey, jsonEncode(logs.map((e) => e.toJson()).toList()));
    }
  }
}
