import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

import '../../../config/common_method.dart';


part 'weight_chart_state.dart';

class WeightChartCubit extends Cubit<WeightChartState> {
  WeightChartCubit() : super(WeightChartsLoading());

  Future<void> getDataFromNow()async{
    if (state is WeightChartsSuccess) {
      log('Week data is already loaded. Skipping execution.');
      return;
    }

    emit(WeightChartsLoading());
    List<double> dataWeek = [];
    for (var i = 0; i < 7; i++) {
      double total = await getDataForDay(
        date: DateTime.now().subtract(const Duration(days: 7)).add(Duration(days: i)),
        healthType: HealthDataType.WEIGHT,
      );
      dataWeek.add(total);
    }
    emit(WeightChartsSuccess(dataWeek: dataWeek,dataMonth: []));

    List<double> dataMonth = [];
    for (var i = 0; i < 30; i++) {
      double total = await getDataForDay(
        date: DateTime.now().subtract(const Duration(days: 30)).add(Duration(days: i)),
        healthType: HealthDataType.WEIGHT,
      );
      dataMonth.add(total);
    }
    emit(WeightChartsSuccess(dataWeek: dataWeek,dataMonth: dataMonth));
  }
}
