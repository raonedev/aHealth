import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

import '../../../config/common_method.dart';

part 'water_chart_state.dart';

class WaterChartCubit extends Cubit<WaterChartState> {
  WaterChartCubit() : super(WaterChartLoading());

  Future<void> getWeekDataFromNow()async{
    if (state is WaterChartWeekSuccess) {
      log('Week data is already loaded. Skipping execution.');
      return;
    }

    emit(WaterChartLoading());
    List<double> data = [];
    for (var i = 0; i < 7; i++) {
      double total = await getDataForDay(
        date: DateTime.now().subtract(const Duration(days: 7)).add(Duration(days: i)),
        healthType: HealthDataType.WATER,
      );
      data.add(total);
    }
    emit(WaterChartWeekSuccess(data: data));
  }

  Future<void> getMonthDataFromNow()async{
    if (state is WaterChartMonthSuccess) {
      log('Month data is already loaded. Skipping execution.');
      return;
    }

    emit(WaterChartLoading());
    List<double> data = [];
    for (var i = 0; i < 30; i++) {
      double total = await getDataForDay(
        date: DateTime.now().subtract(const Duration(days: 30)).add(Duration(days: i)),
        healthType: HealthDataType.WATER,
      );
      data.add(total);
    }
    emit(WaterChartMonthSuccess(data: data));
  }
}
