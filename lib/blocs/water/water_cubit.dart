import 'package:ahealth/models/WaterModel.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

part 'water_state.dart';

class WaterCubit extends Cubit<WaterState> {
  WaterCubit() : super(WaterLoadingState());

  Future<void> getWaterData() async {
    emit(WaterLoadingState());

    final endtime = DateTime.now();
    final fromtime = DateTime(endtime.year, endtime.month, endtime.day);
    // log("from ${fromtime.toIso8601String()} to ${endtime.toIso8601String()} ");
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
        startTime: fromtime,
        endTime: endtime,
      );
      if(healthData.isEmpty){
        emit(const WaterFailed(errorMessage: "NULL"));
      }else{
        // sort the data points by date
        healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
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
    final earlier = now.subtract(const Duration(minutes: 20));
    bool success = true;
    success &= await Health().writeHealthData(
        value: waterInLiter,
        type: HealthDataType.WATER,
        startTime: earlier,
        endTime: now);
    if(success){
      getWaterData();
    }else{
      emit(const WaterFailed(errorMessage: "Failed to add water"));
    }
  }
}
