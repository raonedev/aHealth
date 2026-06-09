import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

part 'water_chart_state.dart';

class WaterChartCubit extends Cubit<WaterChartState> {
  WaterChartCubit() : super(WaterChartLoading());

  Future<Map<DateTime, double>> _getWaterBatch({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

    final Map<DateTime, double> result = {};
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      result[DateTime(d.year, d.month, d.day)] = 0;
    }

    try {
      final data = await Health().getHealthDataFromTypes(
        types: [HealthDataType.WATER],
        startTime: start,
        endTime: end,
      );
      for (final p in data) {
        final day = DateTime(p.dateFrom.year, p.dateFrom.month, p.dateFrom.day);
        if (p.value is NumericHealthValue) {
          result[day] = (result[day] ?? 0) + (p.value as NumericHealthValue).numericValue.toDouble();
        }
      }
    } catch (_) {}

    return result;
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

    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 6));
    final monthStart = now.subtract(const Duration(days: 29));

    final batch = await _getWaterBatch(startDate: monthStart, endDate: now);

    final weekData = List.generate(7, (i) {
      final d = weekStart.add(Duration(days: i));
      return batch[DateTime(d.year, d.month, d.day)] ?? 0;
    });

    emit(WaterChartSuccess(weekStartDate: weekStart, weekData: weekData, monthData: [], monthLoaded: false));

    final monthData = List.generate(30, (i) {
      final d = monthStart.add(Duration(days: i));
      return batch[DateTime(d.year, d.month, d.day)] ?? 0;
    });

    emit(WaterChartSuccess(weekStartDate: weekStart, weekData: weekData, monthData: monthData, monthLoaded: true));
  }

  Future<void> getWeekData(DateTime anyDayInWeek) async {
    emit(WaterChartLoading());
    final monday = anyDayInWeek.subtract(Duration(days: anyDayInWeek.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    final batch = await _getWaterBatch(startDate: monday, endDate: sunday);
    final weekData = List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return batch[DateTime(d.year, d.month, d.day)] ?? 0;
    });

    final current = state is WaterChartSuccess ? state as WaterChartSuccess : null;
    emit(WaterChartSuccess(
      weekStartDate: monday,
      weekData: weekData,
      monthData: current?.monthData ?? [],
      monthLoaded: current?.monthLoaded ?? false,
    ));
  }

  Future<void> getMonthData(int year, int month) async {
    emit(WaterChartLoading());
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    final batch = await _getWaterBatch(startDate: firstDay, endDate: lastDay);
    final monthData = List.generate(lastDay.day, (i) =>
      batch[DateTime(year, month, i + 1)] ?? 0);

    final current = state is WaterChartSuccess ? state as WaterChartSuccess : null;
    emit(WaterChartSuccess(
      weekStartDate: current?.weekStartDate ?? DateTime.now().subtract(const Duration(days: 6)),
      weekData: current?.weekData ?? [],
      monthData: monthData,
      monthLoaded: true,
    ));
  }
}
