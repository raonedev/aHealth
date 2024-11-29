import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

import '../../../config/common_method.dart';

part 'height_chart_state.dart';

class HeightChartCubit extends Cubit<HeightChartState> {
  HeightChartCubit() : super(HeightChartsLoading());

  Future<void> getDataFromNow()async{
    if (state is HeightChartsSuccess) {
      log('Week data is already loaded. Skipping execution.');
      return;
    }

    emit(HeightChartsLoading());
    List<double> dataWeek = [];
    for (var i = 0; i < 7; i++) {
      double total = await getDataForDay(
        date: DateTime.now().subtract(const Duration(days: 7)).add(Duration(days: i)),
        healthType: HealthDataType.HEIGHT,
      );
      dataWeek.add(total);
    }
    emit(HeightChartsSuccess(dataWeek: dataWeek,dataMonth: const []));


    List<double> dataMonth = [];
    for (var i = 0; i < 30; i++) {
      double total = await getDataForDay(
        date: DateTime.now().subtract(const Duration(days: 30)).add(Duration(days: i)),
        healthType: HealthDataType.HEIGHT,
      );
      dataMonth.add(total);
    }
    emit(HeightChartsSuccess(dataWeek: dataWeek,dataMonth: dataMonth));
  }
}
