import 'package:ahealth/common/spring_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../blocs/charts/nutrient_chart/nutrient_chart_cubit.dart';
import '../../common/common_method.dart';
import '../../models/nutrition_model.dart';
import '../common/widgets/custom_segment.dart';
import '../../blocs/nutrition/nutrition_cubit.dart';
import 'widgets/build_card_content.dart';
import 'widgets/card_shell.dart';
import 'widgets/nutrient_line_chart.dart';
import 'widgets/nutrient_point.dart';

class _NutrientConf {
  final String label;
  final Color color;
  final double Function(NutritionModel) getter;
  const _NutrientConf(this.label, this.color, this.getter);
}

const _confs = [
  _NutrientConf('Protein', Color(0xFFE05252), _protein),
  _NutrientConf('Carbs', Color(0xFFE0A952), _carbs),
  _NutrientConf('Fat', Color(0xFF5299E0), _fat),
];

double _protein(NutritionModel m) => m.value?.protein ?? 0;
double _carbs(NutritionModel m) => m.value?.carbs ?? 0;
double _fat(NutritionModel m) => m.value?.fat ?? 0;

// Light Theme Color Palette
const Color _textPrimary = Color(0xFF1A1A1A);

class NutrientChartScreen extends StatefulWidget {
  const NutrientChartScreen({super.key, this.currentTab = 0});
  static String pageName = "/nutrition-chart";
  final int currentTab;

  @override
  State<NutrientChartScreen> createState() => _NutrientChartScreenState();
}

class _NutrientChartScreenState extends State<NutrientChartScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _tab = widget.currentTab;
    context.read<NutrientChartCubit>().getWeekData();
    context.read<NutritionCubit>().getNutritionData();
  }

  List<NutrientPoint> _points(List<double> weekData, DateTime weekStart) {
    return List.generate(weekData.length,
        (i) => NutrientPoint(weekStart.add(Duration(days: i)), weekData[i]));
  }

  @override
  Widget build(BuildContext context) {
    final conf = _confs[_tab];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Nutrients'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: CustomSlidingSegmentedControl(
              currentSelection: _tab,
              children: const ['Protein', 'Carbs', 'Fat'],
              icons: const [Icons.bolt, Icons.grain, Icons.water_drop],
              onValueChanged: (i) => setState(() => _tab = i),
              thumbColor: conf.color,
            ),
          ),
          Expanded(
            child: BlocBuilder<NutrientChartCubit, NutrientChartState>(
              builder: (context, chartState) {
                return BlocBuilder<NutritionCubit, NutritionState>(
                  builder: (context, nutriState) {
                    if (chartState is NutrientChartLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (chartState is NutrientChartFailed) {
                      return Center(child: Text(chartState.errorMessage));
                    }
                    if (chartState is! NutrientChartSuccess) {
                      return const SizedBox();
                    }

                    final nutrientType = NutrientType.values[_tab];
                    final pts = _points(chartState.weekData[nutrientType]!,
                        chartState.weekStartDate);

                    final todayItems = nutriState is NutritionSuccess
                        ? (nutriState.nutritionModel
                            .where((m) => conf.getter(m) > 0)
                            .toList()
                          ..sort((a, b) =>
                              conf.getter(b).compareTo(conf.getter(a))))
                        : <NutritionModel>[];

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadiusGeometry.circular(8),
                            child: NutrientLineChart(
                              points: pts,
                              label: '${conf.label} - last 7 days',
                              color: conf.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text("Nutrient items",
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
                                    dateLabel(context
                                        .read<NutritionCubit>()
                                        .selectedDate),
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
                                  final next = cubit.selectedDate
                                      .add(const Duration(days: 1));
                                  final today = DateTime.now();
                                  if (!next.isAfter(DateTime(
                                      today.year, today.month, today.day))) {
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                            child: Text('No items logged today',
                                style: TextStyle(color: Colors.grey)),
                          )
                        else
                          ...todayItems.map((item) => SpringButton(
                                SpringButtonType.withOpacity,
                                onTap: () async {
                                  HapticFeedback.mediumImpact();
                                  context.push('/nutrition/detail',
                                      extra: item);
                                },
                                uiChild: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 10),
                                  child: CardShell(
                                    child: BuildCardContent(
                                      item: item,
                                      count: 1,
                                      groupItems: [item],
                                    ),
                                  ),
                                ),
                              )),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
