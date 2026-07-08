import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/common_method.dart';

part 'step_chart_state.dart';

class StepChartCubit extends Cubit<StepChartState> {
  StepChartCubit() : super(StepChartsLoading());

  Future<void> getDataFromNow() async {
    if (state is StepChartsSuccess) {
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
    final prefs = await SharedPreferences.getInstance();
    final trackingEnabled = prefs.getBool('step_tracking_enabled') ?? false;

    // Fetch entire 30-day range in one call
    final batch = await getDataForDaysBatch(
      startDate: monthStart,
      endDate: now,
      healthType: HealthDataType.STEPS,
      filterByApp: trackingEnabled,
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
