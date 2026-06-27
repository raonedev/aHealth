import 'package:shared_preferences/shared_preferences.dart';

import '../../models/step_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

part 'step_state.dart';

class StepsCubit extends Cubit<StepsState> {
  StepsCubit() : super(StepLoadingState());

  Future<void> getStepData() async {
    emit(StepLoadingState());
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    bool stepsPermission =
        await Health().hasPermissions([HealthDataType.STEPS]) ?? false;
    if (!stepsPermission) {
      stepsPermission = await Health().requestAuthorization(
        [HealthDataType.STEPS],
        permissions: [HealthDataAccess.READ],
      );
    }
    try {
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: midnight,
        endTime: now,
      );
      final prefs = await SharedPreferences.getInstance();
      final trackingEnabled = prefs.getBool('step_tracking_enabled') ?? false;
      if (trackingEnabled) {
        healthData = healthData
            .where((e) => e.sourceName == "dev.raone.ahealth")
            .toList();
      }
      if (healthData.isEmpty) {
        emit(const StepFailed(errorMessage: "NULL"));
      } else {
        healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        List<StepModel> stepModel0 = [];
        for (HealthDataPoint healthDataPoint in healthData) {
          StepModel stepModel = StepModel.fromJson(healthDataPoint.toJson());
          stepModel0.add(stepModel);
        }
        emit(StepSuccessState(stepModel: stepModel0));
      }
    } catch (e) {
      emit(StepFailed(errorMessage: e.toString()));
    }
  }

  // Future<int> getTodayStep() async {
  //   try {
  //     final now = DateTime.now();
  //     final midnight = DateTime(now.year, now.month, now.day);
  //     bool stepsPermission =
  //         await Health().hasPermissions([HealthDataType.STEPS]) ?? false;
  //     if (!stepsPermission) {
  //       stepsPermission = await Health().requestAuthorization(
  //         [HealthDataType.STEPS],
  //         permissions: [HealthDataAccess.READ],
  //       );
  //     }
  //     final data = await Health().getHealthDataFromTypes(
  //       types: [HealthDataType.STEPS],
  //       startTime: midnight,
  //       endTime: now,
  //     );
  //     final prefs = await SharedPreferences.getInstance();
  //     final trackingEnabled = prefs.getBool('step_tracking_enabled') ?? false;
  //     final filtered = trackingEnabled
  //         ? data.where((e) => e.sourceName == "dev.raone.ahealth").toList()
  //         : data;
  //     return filtered.fold<int>(
  //         0,
  //         (sum, e) =>
  //             sum + (e.value as NumericHealthValue).numericValue.toInt());
  //   } catch (e) {
  //     return 0;
  //   }
  // }
}
