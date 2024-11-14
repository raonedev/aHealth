import '../../models/HeightModel.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

part 'height_state.dart';

class HeightCubit extends Cubit<HeightState> {
  HeightCubit() : super(HeightLoading());

  Future<void> getHeight()async{
    emit(HeightLoading());
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month-1, now.day);
    bool stepsPermission = await Health().hasPermissions([HealthDataType.HEIGHT]) ?? false;
    if (!stepsPermission) {
      stepsPermission = await Health().requestAuthorization(
        [HealthDataType.HEIGHT],
        permissions: [HealthDataAccess.READ_WRITE],
      );
    }

    try {
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [HealthDataType.HEIGHT],
        startTime: midnight,
        endTime: now,
      );
      if(healthData.isEmpty){
        emit(const HeightFailed(errorMessage: "NULL"));
      }else{
        // sort the data points by date
        healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        List<HeightModel> heightModel0=[];
        for(HealthDataPoint healthDataPoint in healthData){
          HeightModel stepModel = HeightModel.fromJson(healthDataPoint.toJson());
          heightModel0.add(stepModel);
        }
        emit(HeightSuccess(heightModel: heightModel0));
      }
    } catch (e) {
      emit(HeightFailed(errorMessage: e.toString()));
    }
  }

  Future<bool> addHeight({required double heightInMeter})async{
    final now = DateTime.now();
    final earlier = now.subtract(const Duration(minutes: 1));
    bool success = true;
    success &= await Health().writeHealthData(
        value: heightInMeter,
        type: HealthDataType.HEIGHT,
        startTime: earlier,
        endTime: now);
    if(success){
      getHeight();
    }else{
      emit(const HeightFailed(errorMessage: "Failed to add Height"));
    }
    return success;
  }
}
