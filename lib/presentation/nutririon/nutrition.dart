import 'package:ahealth/common/spring_button_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahealth/models/nutrition_model.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../app_routes.dart';
import '../../blocs/nutrition/nutrition_cubit.dart';
import '../nitritiondetailscreen.dart';
import 'widgets/circular_progress.dart';
import 'widgets/macro_card.dart';
import 'widgets/macro_chip.dart';

// Light Theme Color Palette
const Color _bg = Color(0xFFF6F6F9); // Light grayish-white background
const Color _card = Color(0xFFFFFFFF); // White cards
const Color _textPrimary = Color(0xFF1A1A1A); // Dark charcoal for primary text
const Color _textSecondary =
    Color(0xFF757575); // Muted gray for subtitles/labels

const Color _proteinColor = Color(0xFFE05252);
const Color _carbsColor = Color(0xFFE0A952);
const Color _fatColor = Color(0xFF5299E0);

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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: kToolbarHeight+28),
        child: SpringButton(
          SpringButtonType.withOpacity,
          onTap: () {

          },
          uiChild: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                    )
                  ]),
              child: Transform.scale(
                scale: 0.6,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedScanImage,
                  color: Colors.white,
                ),
              )),
        ),
      ),
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
                  Text(state.errorMessage,
                      style: const TextStyle(color: _textSecondary)),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        context.read<NutritionCubit>().getNutritionData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final items = state is NutritionSuccess
              ? state.nutritionModel
              : <NutritionModel>[];

          final totalCalories =
              items.fold(0.0, (s, e) => s + (e.value?.calories ?? 0));
          final totalProtein =
              items.fold(0.0, (s, e) => s + (e.value?.protein ?? 0));
          final totalCarbs =
              items.fold(0.0, (s, e) => s + (e.value?.carbs ?? 0));
          final totalFat = items.fold(0.0, (s, e) => s + (e.value?.fat ?? 0));

          const double targetCalories = 2500;
          const double targetProtein = 150;
          const double targetCarbs = 300;
          const double targetFat = 80;

          return SafeArea(
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
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
                            const SizedBox(width: 8),
                            const Text('Nutrition',
                                style: TextStyle(
                                    color: _textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            const Spacer(),
                            IconButton(
                                onPressed: () =>
                                    context.push(AppRoutes.searchScreen),
                                icon: const Icon(CupertinoIcons.search)),
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${(targetCalories - totalCalories).clamp(0, targetCalories).toInt()}',
                                    style: const TextStyle(
                                        color: _textPrimary,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text('Calories left',
                                      style: TextStyle(
                                          color: _textSecondary, fontSize: 14)),
                                ],
                              ),
                              const Spacer(),
                              CircularProgress(
                                value: (totalCalories / targetCalories)
                                    .clamp(0.0, 1.0),
                                color: Colors.orange,
                                // Pop color for the main calorie ring
                                size: 80,
                                icon: Icons.local_fire_department,
                                iconColor: Colors.orange,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Macros Row
                        Row(
                          children: [
                            Expanded(
                              child: MacroCard(
                                label:
                                    'Protein${totalProtein > targetProtein ? ' over' : ''}',
                                value: totalProtein > targetProtein
                                    ? totalProtein - targetProtein
                                    : targetProtein - totalProtein,
                                unit: 'g',
                                color: _proteinColor,
                                icon: Icons.bolt,
                                progress: (totalProtein / targetProtein)
                                    .clamp(0.0, 1.0),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: MacroCard(
                                label: 'Carbs left',
                                value: (targetCarbs - totalCarbs)
                                    .clamp(0, targetCarbs),
                                unit: 'g',
                                color: _carbsColor,
                                icon: Icons.grain,
                                progress:
                                    (totalCarbs / targetCarbs).clamp(0.0, 1.0),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: MacroCard(
                                label: 'Fats left',
                                value:
                                    (targetFat - totalFat).clamp(0, targetFat),
                                unit: 'g',
                                color: _fatColor,
                                icon: Icons.water_drop,
                                progress:
                                    (totalFat / targetFat).clamp(0.0, 1.0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text('Recently uploaded',
                            style: TextStyle(
                                color: _textPrimary,
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

                      return SpringButton(
                        SpringButtonType.withOpacity,
                        onTap: () async{

                          HapticFeedback.mediumImpact();
                          await Future.delayed(Durations.short4);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NutritionDetailScreen(nutritionModel: item),
                          ),
                        );
                        },
                        uiChild: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _card,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade100,
                                    // Light placeholder background
                                    child: Icon(Icons.restaurant,
                                        color: Colors.grey.shade400),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.value?.name ?? 'Unknown',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: _textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15),
                                            ),
                                          ),
                                          Text(timeStr,
                                              style: const TextStyle(
                                                  color: _textSecondary,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                              Icons.local_fire_department,
                                              color: Colors.orange,
                                              size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${item.value?.calories?.toInt() ?? 0} kcal',
                                            style: const TextStyle(
                                                color: _textPrimary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          MacroChip(
                                              icon: Icons.bolt,
                                              color: _proteinColor,
                                              value: item.value?.protein ?? 0),
                                          const SizedBox(width: 8),
                                          MacroChip(
                                              icon: Icons.grain,
                                              color: _carbsColor,
                                              value: item.value?.carbs ?? 0),
                                          const SizedBox(width: 8),
                                          MacroChip(
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
