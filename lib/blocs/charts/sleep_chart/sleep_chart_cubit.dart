import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

import '../../../config/common_method.dart';

part 'sleep_chart_state.dart';

class SleepChartCubit extends Cubit<SleepChartState> {
  SleepChartCubit() : super(SleepChartsLoading());

  Future<void> getWeekDataFromNow()async{
    if (state is SleepChartsWeekSuccess) {
      log('Week data is already loaded. Skipping execution.');
      return;
    }

    emit(SleepChartsLoading());
    List<double> data = [];
    for (var i = 0; i < 7; i++) {
      double total = await getDataForDay(
        date: DateTime.now().subtract(const Duration(days: 7)).add(Duration(days: i)),
        healthType: HealthDataType.SLEEP_SESSION,
      );
      data.add(total);
    }
    emit(SleepChartsWeekSuccess(data: data));
  }

  Future<void> getMonthDataFromNow()async{
    if (state is SleepChartsMonthSuccess) {
      log('Month data is already loaded. Skipping execution.');
      return;
    }

    emit(SleepChartsLoading());
    List<double> data = [];
    for (var i = 0; i < 30; i++) {
      double total = await getDataForDay(
        date: DateTime.now().subtract(const Duration(days: 30)).add(Duration(days: i)),
        healthType: HealthDataType.SLEEP_SESSION,
      );
      data.add(total);
    }
    emit(SleepChartsMonthSuccess(data: data));
  }
}
