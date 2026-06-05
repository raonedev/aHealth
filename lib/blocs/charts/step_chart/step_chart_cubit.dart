import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

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
      emit(StepChartsFailed(
          errorMessage: "Permission Denied")); 
      return;
    }

    final now = DateTime.now();

    // FIX #1: Correcting Week Data Range (Subtracting 6 days means: 6 days ago -> Today)
    List<double> dataWeek = [];
    for (var i = 0; i < 7; i++) {
      double total = await getDataForDay(
        date: now.subtract(
            Duration(days: 6 - i)), 
        healthType: HealthDataType.STEPS,
      );
      dataWeek.add(total);
    }

    emit(StepChartsSuccess(
      weekData: dataWeek,
      monthData: [],
      monthLoaded: false,
    ));

    // FIX #1: Correcting Month Data Range (Subtracting 29 days means: 29 days ago -> Today)
    List<double> dataMonth = [];
    for (var i = 0; i < 30; i++) {
      double total = await getDataForDay(
        date: now.subtract(
            Duration(days: 29 - i)), // When i=29, days subtracted = 0 (Today)
        healthType: HealthDataType.STEPS,
      );
      dataMonth.add(total);
    }

    emit(StepChartsSuccess(
      weekData: dataWeek,
      monthData: dataMonth,
      monthLoaded: true,
    ));
  }
}
