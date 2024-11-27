import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

import '../../../config/common_method.dart';

part 'step_chart_state.dart';

class StepChartCubit extends Cubit<StepChartState> {
  StepChartCubit() : super(StepChartsLoading());

  Future<void> getWeekDataFromNow()async{
    if (state is StepChartsWeekSuccess) {
      log('Week data is already loaded. Skipping execution.');
      return;
    }

    emit(StepChartsLoading());
    List<double> data = [];
    for (var i = 0; i < 7; i++) {
      double total = await getDataForDay(
        date: DateTime.now().subtract(const Duration(days: 7)).add(Duration(days: i)),
        healthType: HealthDataType.STEPS,
      );
      data.add(total);
    }
    emit(StepChartsWeekSuccess(data: data));
  }

  Future<void> getMonthDataFromNow()async{
    if (state is StepChartsMonthSuccess) {
      log('Month data is already loaded. Skipping execution.');
      return;
    }

    emit(StepChartsLoading());
    List<double> data = [];
    for (var i = 0; i < 30; i++) {
      double total = await getDataForDay(
        date: DateTime.now().subtract(const Duration(days: 30)).add(Duration(days: i)),
        healthType: HealthDataType.STEPS,
      );
      data.add(total);
    }
    emit(StepChartsMonthSuccess(data: data));
  }
}
