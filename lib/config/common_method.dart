import 'package:health/health.dart';

Future<double> getDataForDay({required DateTime date,required HealthDataType healthType}) async {
  double total = 0;
  // Start of the day (00:00)
  DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0);

  // End of the day (24:00, which is equivalent to the start of the next day)
  DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  bool healthTypePermission = await Health().hasPermissions([healthType]) ?? false;
  if (!healthTypePermission) {
    healthTypePermission = await Health().requestAuthorization(
      [healthType],
      permissions: [HealthDataAccess.READ],
    );
  }

  try {
    List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
      types: [healthType],
      startTime: startOfDay,
      endTime: endOfDay,
    );

    if (healthData.isEmpty) {
      return 0;
    } else {
      healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
      for (HealthDataPoint healthDataPoint in healthData) {
        total += healthDataPoint.value.toJson()['numericValue'] ?? 0;
      }
      return total;
    }
  } catch (e) {
    return 0;
  }
}