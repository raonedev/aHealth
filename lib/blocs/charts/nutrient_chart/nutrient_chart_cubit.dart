import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

part 'nutrient_chart_state.dart';

enum NutrientType { protein, carbs, fat }

class NutrientChartCubit extends Cubit<NutrientChartState> {
  NutrientChartCubit() : super(NutrientChartLoading());

  Future<void> getWeekData() async {
    emit(NutrientChartLoading());
    try {
      bool hasPermission =
          await Health().hasPermissions([HealthDataType.NUTRITION]) ?? false;
      if (!hasPermission) {
        hasPermission = await Health().requestAuthorization(
            [HealthDataType.NUTRITION],
            permissions: [HealthDataAccess.READ]);
      }
      if (!hasPermission) {
        emit(NutrientChartFailed(errorMessage: "Permission Denied"));
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

      final Map<DateTime, Map<NutrientType, double>> byDay = {};
      for (final d in data) {
        final day = DateTime(d.dateFrom.year, d.dateFrom.month, d.dateFrom.day);
        final v = d.value;
        if (v is! NutritionHealthValue) continue;
        final entry = byDay.putIfAbsent(
            day, () => {NutrientType.protein: 0, NutrientType.carbs: 0, NutrientType.fat: 0});
        entry[NutrientType.protein] =
            entry[NutrientType.protein]! + (v.protein ?? 0);
        entry[NutrientType.carbs] =
            entry[NutrientType.carbs]! + (v.carbs ?? 0);
        entry[NutrientType.fat] =
            entry[NutrientType.fat]! + (v.fat ?? 0);
      }

      final Map<NutrientType, List<double>> weekData = {
        for (final t in NutrientType.values)
          t: List.generate(7, (i) {
            final d = weekStart.add(Duration(days: i));
            return byDay[d]?[t] ?? 0;
          })
      };

      emit(NutrientChartSuccess(weekStartDate: weekStart, weekData: weekData));
    } catch (e) {
      emit(NutrientChartFailed(errorMessage: e.toString()));
    }
  }
}