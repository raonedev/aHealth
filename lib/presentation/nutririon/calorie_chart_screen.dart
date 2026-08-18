import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/charts/calorie_chart/calorie_chart_cubit.dart';
import '../../blocs/charts/calorie_chart/calorie_point.dart';
import '../../blocs/nutrition/nutrition_cubit.dart';
import 'widgets/build_card_content.dart';
import 'widgets/calorie_line_chart.dart';
import 'widgets/card_shell.dart';

class CalorieChartScreen extends StatefulWidget {
  const CalorieChartScreen({super.key});
  static String pageName="/calories-chart";


  @override
  State<CalorieChartScreen> createState() => _CalorieChartScreenState();
}

class _CalorieChartScreenState extends State<CalorieChartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CalorieChartCubit>().getWeekData();
    context.read<NutritionCubit>().getNutritionData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Calories'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocBuilder<CalorieChartCubit, CalorieChartState>(
        builder: (context, chartState) {
          return BlocBuilder<NutritionCubit, NutritionState>(
            builder: (context, nutriState) {
              if (chartState is CalorieChartLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (chartState is CalorieChartFailed) {
                return Center(child: Text(chartState.errorMessage));
              }
              if (chartState is! CalorieChartSuccess) {
                return const SizedBox();
              }

              final pts = List.generate(
                  7,
                  (i) => CaloriePoint(
                        chartState.weekStartDate.add(Duration(days: i)),
                        chartState.consumed[i],
                        chartState.target,
                        chartState.tdee,
                      ));

              final todayItems = nutriState is NutritionSuccess
                  ? (List.of(nutriState.nutritionModel)
                    ..sort((a, b) => (b.value?.calories ?? 0)
                        .compareTo(a.value?.calories ?? 0)))
                  : [];

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  CalorieLineChart(points: pts, label: 'Calories - last 7 days'),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Today's items",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700])),
                  ),
                  const SizedBox(height: 8),
                  if (todayItems.isEmpty)
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Text('No items logged today',
                          style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ...todayItems.map((item) => Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: CardShell(
                            child: BuildCardContent(
                              item: item,
                              count: 1,
                              groupItems: [item],
                            ),
                          ),
                        )),
                ],
              );
            },
          );
        },
      ),
    );
  }
}