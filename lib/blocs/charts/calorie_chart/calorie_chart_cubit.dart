import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

import '../../../presentation/common/nutrition_calc.dart';

part 'calorie_chart_state.dart';

class CalorieChartCubit extends Cubit<CalorieChartState> {
  CalorieChartCubit() : super(CalorieChartLoading());

  Future<void> getWeekData() async {
    emit(CalorieChartLoading());
    try {
      bool hasPermission =
          await Health().hasPermissions([HealthDataType.NUTRITION]) ?? false;
      if (!hasPermission) {
        hasPermission = await Health().requestAuthorization(
            [HealthDataType.NUTRITION],
            permissions: [HealthDataAccess.READ]);
      }
      if (!hasPermission) {
        emit(CalorieChartFailed(errorMessage: "Permission Denied"));
        return;
      }

      final now = DateTime.now();
      final weekStart = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 6));

      final data = await Health().getHealthDataFromTypes(
        types: [HealthDataType.NUTRITION],
        startTime: weekStart,
        endTime: now,
      );

      final Map<DateTime, double> byDay = {};
      for (final d in data) {
        final day =
            DateTime(d.dateFrom.year, d.dateFrom.month, d.dateFrom.day);
        final v = d.value;
        if (v is! NutritionHealthValue) continue;
        byDay[day] = (byDay[day] ?? 0) + (v.calories ?? 0);
      }

      final consumed = List.generate(7, (i) {
        final d = weekStart.add(Duration(days: i));
        return byDay[d] ?? 0;
      });

      final targets = await TargetCalorieCalculator.calculate();

      emit(CalorieChartSuccess(
        weekStartDate: weekStart,
        consumed: consumed,
        target: targets.target.toDouble(),
        tdee: targets.tdee.toDouble(),
      ));
    } catch (e) {
      emit(CalorieChartFailed(errorMessage: e.toString()));
    }
  }
}