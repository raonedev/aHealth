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
    type: Platform.isIOS ? HealthDataType.SLEEP_ASLEEP : HealthDataType.SLEEP_SESSION,
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
      permissions: sleepTypes.map((_) => HealthDataAccess.READ_WRITE).toList(),
    );
  }

  try {
    bool success = true;
    for (final type in sleepTypes) {
      success &= await Health().delete(
        type: type,
        startTime: fromTime,
        endTime: endTime,
      );
    }
    if (success) {
      getSleepData();
    } else {
      emit(const SleepFailedState(errorMessage: "cant able to delete sleep data"));
    }
  } catch (e) {
    emit(SleepFailedState(errorMessage: e.toString()));
  }
}

}


int calculateSleepScore(List<SleepModel> data) {
  if (data.isEmpty) return 0;

  if (Platform.isAndroid) {
    final minutes = data[0].value?.numericValue ?? 0;
    return _durationScore(minutes / 60).round();
  }

  double asleep = 0, deep = 0, rem = 0, awake = 0;
  for (final d in data) {
    final mins = (d.value?.numericValue ?? 0).toDouble();
    switch (d.type) {
      case 'SLEEP_ASLEEP':
      case 'SLEEP_LIGHT':
        asleep += mins;
        break;
      case 'SLEEP_DEEP':
        deep += mins;
        asleep += mins;
        break;
      case 'SLEEP_REM':
        rem += mins;
        asleep += mins;
        break;
      case 'SLEEP_AWAKE':
        awake += mins;
        break;
    }
  }

  if (asleep <= 0) return 0;

  final durationScore = _durationScore(asleep / 60);
  final efficiencyScore = (100 - (awake / (asleep + awake) * 100)).clamp(0, 100);
  final deepPct = deep / asleep;
  final remPct = rem / asleep;
  final stageScore = (100 -
          (deepPct - 0.15).abs() * 200 -
          (remPct - 0.20).abs() * 200)
      .clamp(0, 100);

  return (durationScore * 0.5 + efficiencyScore * 0.25 + stageScore * 0.25).round();
}

double _durationScore(double hours) {
  if (hours >= 7 && hours <= 9) return 100;
  if (hours < 7) return (hours / 7 * 100).clamp(0, 100);
  return (100 - (hours - 9) * 15).clamp(0, 100);
}


