import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

import '../../../config/common_method.dart';
import 'step_day_data.dart';

part 'step_chart_state.dart';

class StepChartCubit extends Cubit<StepChartState> {
  StepChartCubit() : super(StepChartsLoading());

  Future<StepDayData> getStepDataForDay(DateTime day) async {
    final startTime = DateTime(day.year, day.month, day.day);
    final endTime =
        DateTime(day.year, day.month, day.day, 23, 59, 59, 999);
    final healthData = await Health().getHealthDataFromTypes(
      types: [HealthDataType.STEPS],
      startTime: startTime,
      endTime: endTime,
    );

    final records = healthData.map((point) {
      final value = point.value.toJson()['numericValue'];
      if (value == null) {
        throw FormatException('Step data is missing its numeric value.');
      }

      return StepDayRecord(
        time: point.dateFrom,
        steps: double.parse(value.toString()),
      );
    });

    return StepDayData.fromRecords(day: day, records: records);
  }

  Future<void> getDataFromNow({bool forceRefresh = false}) async {
    if (!forceRefresh && state is StepChartsSuccess) {
      log('Week data is already loaded. Skipping execution.');
      return;
    }

    emit(StepChartsLoading());

    bool hasPermission =
        await Health().hasPermissions([HealthDataType.STEPS]) ?? false;
    if (!hasPermission) {
      hasPermission = await Health().requestAuthorization(
        [HealthDataType.STEPS],
        permissions: [HealthDataAccess.READ],
      );
    }

    if (!hasPermission) {
      log('Permissions denied by user.');
      emit(StepChartsFailed(errorMessage: "Permission Denied"));
      return;
    }

    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 6));
    final monthStart = now.subtract(const Duration(days: 29));

    // Fetch entire 30-day range in one call
    final batch = await getDataForDaysBatch(
      startDate: monthStart,
      endDate: now,
      healthType: HealthDataType.STEPS,
    );

    final dataWeek = List.generate(7, (i) {
      final d = weekStart.add(Duration(days: i));
      return batch[DateTime(d.year, d.month, d.day)] ?? 0;
    });

    emit(StepChartsSuccess(
      weekStartDate: weekStart,
      weekData: dataWeek,
      monthData: [],
      monthLoaded: false,
    ));

    final dataMonth = List.generate(30, (i) {
      final d = monthStart.add(Duration(days: i));
      return batch[DateTime(d.year, d.month, d.day)] ?? 0;
    });

    emit(StepChartsSuccess(
      weekStartDate: weekStart,
      weekData: dataWeek,
      monthData: dataMonth,
      monthLoaded: true,
    ));
  }
}
