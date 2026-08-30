import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../blocs/charts/calorie_chart/calorie_chart_cubit.dart';
import '../../blocs/charts/calorie_chart/calorie_point.dart';
import '../../blocs/nutrition/nutrition_cubit.dart';
import '../../common/common_method.dart';
import 'widgets/build_card_content.dart';
import 'widgets/calorie_line_chart.dart';
import 'widgets/card_shell.dart';

const Color _textPrimary = Color(0xFF1A1A1A);

class CalorieChartScreen extends StatefulWidget {
  const CalorieChartScreen({super.key});
  static String pageName = "/calories-chart";

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
                  CalorieLineChart(
                      points: pts, label: 'Calories - last 7 days'),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text("Today's items",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700])),
                        Spacer(),
                        IconButton(
                          icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowLeft01),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            final cubit = context.read<NutritionCubit>();
                            cubit.getNutritionData(
                                date: cubit.selectedDate
                                    .subtract(const Duration(days: 1)));
                          },
                        ),
                        GestureDetector(
                          onTap: () async {
                            final cubit = context.read<NutritionCubit>();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: cubit.selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              cubit.getNutritionData(date: picked);
                            }
                          },
                          child: Text(
                              dateLabel(
                                  context.read<NutritionCubit>().selectedDate),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary)),
                        ),
                        IconButton(
                          icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowRight01),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            final cubit = context.read<NutritionCubit>();
                            final next =
                                cubit.selectedDate.add(const Duration(days: 1));
                            final today = DateTime.now();
                            if (!next.isAfter(
                                DateTime(today.year, today.month, today.day))) {
                              cubit.getNutritionData(date: next);
                            }
                          },
                        ),
                      ],
                    ),
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
