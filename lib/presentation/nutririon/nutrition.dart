import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahealth/models/nutrition_model.dart';

import '../../blocs/nutrition/nutrition_cubit.dart';

const Color _bg = Color(0xFF1A1A1A);
const Color _card = Color(0xFF2A2A2A);
const Color _proteinColor = Color(0xFFE05252);
const Color _carbsColor = Color(0xFFE0A952);
const Color _fatColor = Color(0xFF5299E0);
const Color _calColor = Color(0xFFFFFFFF);

class Nutrition extends StatefulWidget {
  const Nutrition({super.key});

  @override
  State<Nutrition> createState() => _NutritionState();
}

class _NutritionState extends State<Nutrition> {
  @override
  void initState() {
    super.initState();
    context.read<NutritionCubit>().getNutritionData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: BlocBuilder<NutritionCubit, NutritionState>(
        builder: (context, state) {
          if (state is NutritionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NutritionFailed) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage, style: const TextStyle(color: Colors.white54)),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.read<NutritionCubit>().getNutritionData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final items = state is NutritionSuccess ? state.nutritionModel : <NutritionModel>[];

          final totalCalories = items.fold(0.0, (s, e) => s + (e.value?.calories ?? 0));
          final totalProtein = items.fold(0.0, (s, e) => s + (e.value?.protein ?? 0));
          final totalCarbs = items.fold(0.0, (s, e) => s + (e.value?.carbs ?? 0));
          final totalFat = items.fold(0.0, (s, e) => s + (e.value?.fat ?? 0));

          const double targetCalories = 2500;
          const double targetProtein = 150;
          const double targetCarbs = 300;
          const double targetFat = 80;

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            const Icon(Icons.apple, color: Colors.redAccent, size: 26),
                            const SizedBox(width: 8),
                            const Text('Cal AI',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _card,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_fire_department,
                                      color: Colors.orange, size: 18),
                                  const SizedBox(width: 4),
                                  Text('${totalCalories.toInt()}',
                                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Calories Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${(targetCalories - totalCalories).clamp(0, targetCalories).toInt()}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text('Calories left',
                                      style: TextStyle(color: Colors.white54, fontSize: 14)),
                                ],
                              ),
                              const Spacer(),
                              _CircularProgress(
                                value: (totalCalories / targetCalories).clamp(0.0, 1.0),
                                color: Colors.white,
                                size: 80,
                                icon: Icons.local_fire_department,
                                iconColor: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Macros Row
                        Row(
                          children: [
                            Expanded(
                              child: _MacroCard(
                                label: 'Protein${totalProtein > targetProtein ? ' over' : ''}',
                                value: totalProtein > targetProtein
                                    ? totalProtein - targetProtein
                                    : targetProtein - totalProtein,
                                unit: 'g',
                                color: _proteinColor,
                                icon: Icons.bolt,
                                progress: (totalProtein / targetProtein).clamp(0.0, 1.0),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MacroCard(
                                label: 'Carbs left',
                                value: (targetCarbs - totalCarbs).clamp(0, targetCarbs),
                                unit: 'g',
                                color: _carbsColor,
                                icon: Icons.grain,
                                progress: (totalCarbs / targetCarbs).clamp(0.0, 1.0),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MacroCard(
                                label: 'Fats left',
                                value: (targetFat - totalFat).clamp(0, targetFat),
                                unit: 'g',
                                color: _fatColor,
                                icon: Icons.water_drop,
                                progress: (totalFat / targetFat).clamp(0.0, 1.0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text('Recently uploaded',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // Food List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final item = items[index];
                      final time = item.dateTo != null
                          ? TimeOfDay.fromDateTime(DateTime.parse(item.dateTo!))
                          : null;
                      final timeStr = time != null
                          ? '${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')}${time.period == DayPeriod.am ? 'am' : 'pm'}'
                          : '';

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.white12,
                                  child: const Icon(Icons.restaurant, color: Colors.white38),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.value?.name ?? 'Unknown',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15),
                                          ),
                                        ),
                                        Text(timeStr,
                                            style: const TextStyle(
                                                color: Colors.white38, fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.local_fire_department,
                                            color: Colors.orange, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${item.value?.calories?.toInt() ?? 0} kcal',
                                          style: const TextStyle(
                                              color: Colors.white70, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        _MacroChip(
                                            icon: Icons.bolt,
                                            color: _proteinColor,
                                            value: item.value?.protein ?? 0),
                                        const SizedBox(width: 8),
                                        _MacroChip(
                                            icon: Icons.grain,
                                            color: _carbsColor,
                                            value: item.value?.carbs ?? 0),
                                        const SizedBox(width: 8),
                                        _MacroChip(
                                            icon: Icons.water_drop,
                                            color: _fatColor,
                                            value: item.value?.fat ?? 0),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: items.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;
  final IconData icon;
  final double progress;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${value.toInt()}$unit',
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 10),
          Center(
            child: _CircularProgress(
              value: progress,
              color: color,
              size: 52,
              icon: icon,
              iconColor: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgress extends StatelessWidget {
  final double value;
  final Color color;
  final double size;
  final IconData icon;
  final Color iconColor;

  const _CircularProgress({
    required this.value,
    required this.color,
    required this.size,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 6,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Icon(icon, color: iconColor, size: size * 0.35),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double value;

  const _MacroChip({required this.icon, required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 2),
        Text('${value.toInt()}g',
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}