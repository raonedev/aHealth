
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

  Future<int> getTodayStep() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      bool stepsPermission =
          await Health().hasPermissions([HealthDataType.STEPS]) ?? false;
      if (!stepsPermission) {
        stepsPermission = await Health().requestAuthorization(
          [HealthDataType.STEPS],
          permissions: [HealthDataAccess.READ_WRITE],
        );
      }
      final data = await Health().getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: midnight,
        endTime: now,
      );

      return data.fold<int>(
          0,
          (sum, e) =>
              sum + (e.value as NumericHealthValue).numericValue.toInt());
    } catch (e) {
      return 0;
    }
  }
}
