import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

part 'water_chart_state.dart';

class WaterChartCubit extends Cubit<WaterChartState> {
  WaterChartCubit() : super(WaterChartLoading());

  Future<double> _getWaterForDay(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    try {
      final data = await Health().getHealthDataFromTypes(
        types: [HealthDataType.WATER],
        startTime: start,
        endTime: end,
      );

      // Explicitly type the fold inputs to guarantee it treats 'sum' as a pure double
      return data.fold<double>(0.0, (double sum, HealthDataPoint p) {
        final valueWrapper = p.value;
        if (valueWrapper is NumericHealthValue) {
          return sum + valueWrapper.numericValue.toDouble();
        }
        return sum;
      });
    } catch (_) {
      return 0.0;
    }
  }

  Future<void> getChartData() async {
    if (state is WaterChartSuccess) return;
    emit(WaterChartLoading());

    bool perm = await Health().hasPermissions([HealthDataType.WATER]) ?? false;
    if (!perm) {
      perm = await Health().requestAuthorization(
        [HealthDataType.WATER],
        permissions: [HealthDataAccess.READ_WRITE],
      );
    }

    // Week: 6 days ago → today
    final weekData = <double>[];
    for (var i = 6; i >= 0; i--) {
      weekData.add(await _getWaterForDay(
        DateTime.now().subtract(Duration(days: i)),
      ));
    }
    emit(WaterChartSuccess(
        weekData: weekData, monthData: [], monthLoaded: false));

    // Month: 29 days ago → today
    final monthData = <double>[];
    for (var i = 29; i >= 0; i--) {
      monthData.add(await _getWaterForDay(
        DateTime.now().subtract(Duration(days: i)),
      ));
    }
    emit(WaterChartSuccess(
        weekData: weekData, monthData: monthData, monthLoaded: true));
  }
}
