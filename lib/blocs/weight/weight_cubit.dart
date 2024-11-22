import '../../models/weightmodel.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

part 'weight_state.dart';

class WeightCubit extends Cubit<WeightState> {
  WeightCubit() : super(WeightLoading());

  Future<void> getWeightData() async {
    emit(WeightLoading());

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day-30);
    bool stepsPermission = await Health().hasPermissions([HealthDataType.WEIGHT]) ?? false;
    if (!stepsPermission) {
      stepsPermission = await Health().requestAuthorization(
        [HealthDataType.WEIGHT],
        permissions: [HealthDataAccess.READ_WRITE],
      );
    }

    try {
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: midnight,
        endTime: now,
      );
      if(healthData.isEmpty){
        emit(const WeightFailed(errorMessage: "NULL"));
      }else{
        // sort the data points by date
        healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        List<WeightModel> weightModel0=[];
        for(HealthDataPoint healthDataPoint in healthData){
          WeightModel stepModel = WeightModel.fromJson(healthDataPoint.toJson());
          weightModel0.add(stepModel);
        }
        emit(WeightSuccess(weightModel: weightModel0));
      }
    } catch (e) {
      emit(WeightFailed(errorMessage: e.toString()));
    }
  }

  Future<bool> addWeight({required double wrightInKg})async{
    final now = DateTime.now();
    final earlier = now.subtract(const Duration(minutes: 1));
    bool success = true;
    success &= await Health().writeHealthData(
        value: wrightInKg,
        type: HealthDataType.WEIGHT,
        startTime: earlier,
        endTime: now);
    if(success){
      getWeightData();
    }else{
      emit(const WeightFailed(errorMessage: "Failed to add weight"));
    }
    return success;
  }

}
