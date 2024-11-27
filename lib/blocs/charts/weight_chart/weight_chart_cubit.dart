import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

import '../../../config/common_method.dart';

part 'weight_chart_state.dart';

class WeightChartCubit extends Cubit<WeightChartState> {
  WeightChartCubit() : super(WeightChartsLoading());

  Future<void> getWeekDataFromNow()async{
    if (state is WeightChartsWeekSuccess) {
      log('Week data is already loaded. Skipping execution.');
      return;
    }

    emit(WeightChartsLoading());
    List<double> data = [];
    for (var i = 0; i < 7; i++) {
      double total = await getDataForDay(
        date: DateTime.now().subtract(const Duration(days: 7)).add(Duration(days: i)),
        healthType: HealthDataType.WEIGHT,
      );
      data.add(total);
    }
    emit(WeightChartsWeekSuccess(data: data));
  }

  Future<void> getMonthDataFromNow()async{
    if (state is WeightChartsMonthSuccess) {
      log('Month data is already loaded. Skipping execution.');
      return;
    }

    emit(WeightChartsLoading());
    List<double> data = [];
    for (var i = 0; i < 30; i++) {
      double total = await getDataForDay(
        date: DateTime.now().subtract(const Duration(days: 30)).add(Duration(days: i)),
        healthType: HealthDataType.WEIGHT,
      );
      data.add(total);
    }
    emit(WeightChartsMonthSuccess(data: data));
  }
}
