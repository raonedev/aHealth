import '../../models/StepModel.dart';
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
    bool stepsPermission = await Health().hasPermissions([HealthDataType.STEPS]) ?? false;
    if (!stepsPermission) {
      stepsPermission = await Health().requestAuthorization(
        [HealthDataType.STEPS],
        permissions: [HealthDataAccess.READ_WRITE],
      );
    }

    try {
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: midnight,
        endTime: now,
      );

      if(healthData.isEmpty){
        emit(const StepFailed(errorMessage: "NULL"));
      }else{
        // sort the data points by date
        healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        List<StepModel> stepModel0=[];
        for(HealthDataPoint healthDataPoint in healthData){
          StepModel stepModel = StepModel.fromJson(healthDataPoint.toJson());
          stepModel0.add(stepModel);
        }
        emit(StepSuccessState(stepModel: stepModel0));
      }
    } catch (e) {
      emit(StepFailed(errorMessage: e.toString()));
    }
  }


}
