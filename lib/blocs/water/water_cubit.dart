import 'dart:developer';

import 'package:ahealth/models/WaterModel.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

part 'water_state.dart';

class WaterCubit extends Cubit<WaterState> {
  WaterCubit() : super(WaterLoadingState());

  Future<void> getWaterData() async {
    emit(WaterLoadingState());

    final endTime = DateTime.now();
    final fromTime = DateTime(endTime.year, endTime.month, endTime.day);
    // log("from ${fromTime.toIso8601String()} to ${endTime.toIso8601String()} ");
    bool waterPermission = await Health().hasPermissions([HealthDataType.WATER]) ?? false;
    if (!waterPermission) {
      waterPermission = await Health().requestAuthorization(
        [HealthDataType.WATER],
        permissions: [HealthDataAccess.READ_WRITE],
      );
    }

    try {
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [HealthDataType.WATER],
        startTime: fromTime,
        endTime: endTime,
      );
      if(healthData.isEmpty){
        emit(const WaterFailed(errorMessage: "NULL"));
      }else{
        // sort the data points by date
        healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        log("no. of water :${healthData.length}");
        List<WaterModel> sleepModel0=[];


        for(HealthDataPoint healthDataPoint in healthData){
          WaterModel stepModel = WaterModel.fromJson(healthDataPoint.toJson());
          sleepModel0.add(stepModel);
        }
        emit(WaterSuccessState(waterModel: sleepModel0));
      }
    } catch (e) {
      emit(WaterFailed(errorMessage: e.toString()));
    }
  }

  Future<void> addWater({required double waterInLiter})async{
    final now = DateTime.now();
    final earlier = now.subtract(const Duration(seconds: 30));
    bool success = true;
    success &= await Health().writeHealthData(
        value: waterInLiter,
        type: HealthDataType.WATER,
        startTime: earlier,
        endTime: now,
    );
    if(success){
      getWaterData();
    }else{
      emit(const WaterFailed(errorMessage: "Failed to add water"));
    }
  }

  Future<void> decreaseLastWaterData() async{

    emit(WaterLoadingState());

    bool waterPermission = await Health().hasPermissions([HealthDataType.WATER]) ?? false;
    if (!waterPermission) {
      waterPermission = await Health().requestAuthorization(
        [HealthDataType.WATER],
        permissions: [HealthDataAccess.READ_WRITE],
      );
    }

    final endTime = DateTime.now();
    final fromTime = DateTime(endTime.year, endTime.month, endTime.day);
    try{
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [HealthDataType.WATER],
        startTime: fromTime,
        endTime: endTime,
      );
      if(healthData.isEmpty){
        emit(const WaterFailed(errorMessage: "Empty"));
      }else {
        // sort the data points by date
        healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        log("no. of water :${healthData.length}");
        // bool success = true;
        log("From : ${healthData[0].dateFrom}, To: ${healthData[0].dateTo}");
        bool success = await Health().delete(
          type: HealthDataType.WATER,
          startTime: healthData[0].dateFrom,
          endTime: healthData[0].dateTo,
        );
        log("Success value $success");
        if(success){
          getWaterData();
        }else{
          emit(const WaterFailed(errorMessage: "can't remove water data"));
        }
      }
    }catch (e){
      emit(WaterFailed(errorMessage: e.toString()));
    }


  }
}
