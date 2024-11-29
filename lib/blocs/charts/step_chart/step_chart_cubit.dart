import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

import '../../../config/common_method.dart';

part 'step_chart_state.dart';

class StepChartCubit extends Cubit<StepChartState> {
  StepChartCubit() : super(StepChartsLoading());

  Future<void> getDataFromNow()async{
    if (state is StepChartsSuccess) {
      log('Week data is already loaded. Skipping execution.');
      return;
    }

    emit(StepChartsLoading());
    List<double> dataWeek = [];
    for (var i = 0; i < 7; i++) {
      double total = await getDataForDay(
        date: DateTime.now().subtract(const Duration(days: 7)).add(Duration(days: i)),
        healthType: HealthDataType.STEPS,
      );
      dataWeek.add(total);
    }

    emit(StepChartsSuccess(
      weekData: dataWeek,
      monthData: [],
    ));

    //get month data
    List<double> dataMonth = [];
    for (var i = 0; i < 30; i++) {
      double total = await getDataForDay(
        date: DateTime.now().subtract(const Duration(days: 30)).add(Duration(days: i)),
        healthType: HealthDataType.STEPS,
      );
      dataMonth.add(total);
    }

    emit(StepChartsSuccess(
      weekData: dataWeek,
      monthData: dataMonth,
    ));
  }

}
