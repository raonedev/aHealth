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