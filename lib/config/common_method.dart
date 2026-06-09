import 'dart:developer';

import 'package:health/health.dart';

Future<double> getDataForDay({required DateTime date, required HealthDataType healthType}) async {
  double total = 0;
  DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0);
  DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  try {
    List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
      types: [healthType],
      startTime: startOfDay,
      endTime: endOfDay,
    );

    if (healthData.isEmpty) return 0;

    for (HealthDataPoint healthDataPoint in healthData) {
      // Safely extract the numeric value depending on how your health plugin structure looks
      final value = healthDataPoint.value.toJson()['numericValue'];
      if (value != null) {
        total += double.parse(value.toString());
      }
    }
    return total;
  } catch (e) {
    log('Error fetching data for $date: $e');
    return 0;
  }
}

Future<Map<DateTime, double>> getDataForDaysBatch({
  required DateTime startDate,
  required DateTime endDate,
  required HealthDataType healthType,
}) async {
  final start = DateTime(startDate.year, startDate.month, startDate.day);
  final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

  final Map<DateTime, double> result = {};

  // Pre-fill all days with 0
  for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
    result[DateTime(d.year, d.month, d.day)] = 0;
  }

  try {
    final healthData = await Health().getHealthDataFromTypes(
      types: [healthType],
      startTime: start,
      endTime: end,
    );

    for (final point in healthData) {
      final day = DateTime(point.dateFrom.year, point.dateFrom.month, point.dateFrom.day);
      final value = double.tryParse(point.value.toJson()['numericValue'].toString()) ?? 0;
      result[day] = (result[day] ?? 0) + value;
    }
  } catch (e) {
    log('Error batch fetching $healthType: $e');
  }

  return result;
}