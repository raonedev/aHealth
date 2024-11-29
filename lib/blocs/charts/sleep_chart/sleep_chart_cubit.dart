import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

import '../../../config/common_method.dart';

part 'sleep_chart_state.dart';

class SleepChartCubit extends Cubit<SleepChartState> {
  SleepChartCubit() : super(SleepChartsLoading());

  Future<void> getDataFromNow()async{
    if (state is SleepChartsSuccess) {
      log('Week data is already loaded. Skipping execution.');
      return;
    }

    emit(SleepChartsLoading());
    List<double> dataWeek = [];
    for (var i = 0; i < 7; i++) {
      double total = await getDataForDay(
        date: DateTime.now().subtract(const Duration(days: 7)).add(Duration(days: i)),
        healthType: HealthDataType.SLEEP_SESSION,
      );
      dataWeek.add(total);
    }
    emit(SleepChartsSuccess(dataWeek: dataWeek,dataMonth: const []));

    List<double> dataMonth = [];
    for (var i = 0; i < 30; i++) {
      double total = await getDataForDay(
        date: DateTime.now().subtract(const Duration(days: 30)).add(Duration(days: i)),
        healthType: HealthDataType.SLEEP_SESSION,
      );
      dataMonth.add(total);
    }
    emit(SleepChartsSuccess(dataWeek: dataWeek,dataMonth: dataMonth));
  }
}
