// import 'dart:developer';

import 'package:ahealth/models/SleepModel.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

part 'sleep_state.dart';

class SleepCubit extends Cubit<SleepState> {
  SleepCubit() : super(SleepLoadingState());


  Future<void> getSleepData() async {
    emit(SleepLoadingState());

    final endtime = DateTime.now();
    final fromtime = DateTime(endtime.year, endtime.month, endtime.day-1);
    // log("from ${fromtime.toIso8601String()} to ${endtime.toIso8601String()} ");
    bool stepsPermission = await Health().hasPermissions([HealthDataType.SLEEP_SESSION]) ?? false;
    if (!stepsPermission) {
      stepsPermission = await Health().requestAuthorization(
        [HealthDataType.SLEEP_SESSION],
        permissions: [HealthDataAccess.READ_WRITE],
      );
    }

    try {
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_SESSION],
        startTime: fromtime,
        endTime: endtime,
      );
      if(healthData.isEmpty){
        emit(const SleepFailedState(errorMessage: "0"));
      }else{
        // sort the data points by date
        healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        List<SleepModel> sleepModel0=[];
        for(HealthDataPoint healthDataPoint in healthData){
          SleepModel stepModel = SleepModel.fromJson(healthDataPoint.toJson());
          sleepModel0.add(stepModel);
        }
        emit(SleepSuccessState(sleepModel: sleepModel0));
      }
    } catch (e) {
      emit(SleepFailedState(errorMessage: e.toString()));
    }
  }

  Future<void> addSleep({required DateTime startingTime,required DateTime endTime})async{
    bool success = true;
    success &= await Health().writeHealthData(
        value: 0.0,
        type: HealthDataType.SLEEP_SESSION,
        startTime: startingTime,
        endTime: endTime,
    );
    if(success){
      getSleepData();
    }else{
      emit(const SleepFailedState(errorMessage: "failed to add data"));
    }
  }
}
