// import 'dart:developer';

import 'dart:developer' as dev;
import 'dart:io';

import 'package:ahealth/models/sleep_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

part 'sleep_state.dart';

class SleepCubit extends Cubit<SleepState> {
  SleepCubit() : super(SleepLoadingState());

  Future<void> getSleepData() async {
  emit(SleepLoadingState());

  try {
    final endTime = DateTime.now();
    final fromTime = DateTime(endTime.year, endTime.month, endTime.day - 1);

    final sleepTypes = Platform.isIOS
        ? [
            HealthDataType.SLEEP_ASLEEP,
            HealthDataType.SLEEP_AWAKE,
            HealthDataType.SLEEP_IN_BED,
            HealthDataType.SLEEP_LIGHT,
            HealthDataType.SLEEP_DEEP,
            HealthDataType.SLEEP_REM,
          ]
        : [HealthDataType.SLEEP_SESSION];

    bool sleepPermission = await Health().hasPermissions(sleepTypes) ?? false;
    if (!sleepPermission) {
      sleepPermission = await Health().requestAuthorization(
        sleepTypes,
        permissions: sleepTypes.map((_) => HealthDataAccess.READ).toList(),
      );
    }

    List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
      types: sleepTypes,
      startTime: fromTime,
      endTime: endTime,
    );

    if (healthData.isEmpty) {
      emit(const SleepFailedState(errorMessage: "0"));
    } else {
      healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
      List<SleepModel> sleepModel0 = [];
      for (HealthDataPoint healthDataPoint in healthData) {
        SleepModel stepModel = SleepModel.fromJson(healthDataPoint.toJson());
        sleepModel0.add(stepModel);
      }
      emit(SleepSuccessState(sleepModel: sleepModel0));
    }
  } catch (e, s) {
    dev.log("Exception SleepFailedState", error: e, stackTrace: s);
    emit(SleepFailedState(errorMessage: e.toString()));
  }
}

  Future<void> addSleep(
      {required DateTime startingTime, required DateTime endTime}) async {
    bool success = true;
    success &= await Health().writeHealthData(
      value: 0.0,
      type: HealthDataType.SLEEP_SESSION,
      startTime: startingTime,
      endTime: endTime,
    );
    if (success) {
      getSleepData();
    } else {
      emit(const SleepFailedState(errorMessage: "failed to add data"));
    }
  }

  Future<void> deleteToadySleepData() async {
    emit(SleepLoadingState());

    final endTime = DateTime.now();
    final fromTime = DateTime(endTime.year, endTime.month, endTime.day - 1);
    bool stepsPermission =
        await Health().hasPermissions([HealthDataType.SLEEP_SESSION]) ?? false;
    if (!stepsPermission) {
      stepsPermission = await Health().requestAuthorization(
        [HealthDataType.SLEEP_SESSION],
        permissions: [HealthDataAccess.READ_WRITE],
      );
    }

    try {
      bool success = true;
      success &= await Health().delete(
        type: HealthDataType.SLEEP_SESSION,
        startTime: fromTime,
        endTime: endTime,
      );
      if (success) {
        getSleepData();
      } else {
        emit(const SleepFailedState(
            errorMessage: "cant able to delete sleep data"));
      }
    } catch (e) {
      emit(SleepFailedState(errorMessage: e.toString()));
    }
  }
}
