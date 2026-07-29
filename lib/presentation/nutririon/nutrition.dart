import 'dart:developer' as dev;
import 'dart:io';

import 'package:ahealth/common/spring_button_widget.dart';
import 'package:ahealth/presentation/nutririon/widgets/build_card_content.dart';
import 'package:ahealth/presentation/nutririon/widgets/card_shell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahealth/models/nutrition_model.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../app_routes.dart';
import '../../blocs/food_scan/food_scan_cubit.dart';
import '../../blocs/nutrition/nutrition_cubit.dart';
import '../../services/nutrition_service.dart';
import '../common/camera_view.dart';
import '../common/nutrition_calc.dart';
import 'nutrition_group/models/food_scan_group_model.dart';
import 'widgets/circular_progress.dart';
import 'widgets/food_scan_nutrition_loading.dart';
import 'widgets/macro_card.dart';

import 'widgets/nutrition_group_dialog.dart';

// Light Theme Color Palette
const Color _bg = Color(0xFFF6F6F9);
const Color _card = Color(0xFFFFFFFF);
const Color _textPrimary = Color(0xFF1A1A1A);
const Color _textSecondary = Color(0xFF757575);

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

  Map<String, List<NutritionModel>> _groupItems(List<NutritionModel> items) {
    final groups = NutritionService.getAllGroups();
    final Map<String, List<NutritionModel>> grouped = {};
    final List<NutritionModel> ungrouped = [];

    for (final item in items) {
      final group = groups.cast<FoodScanGroup?>().firstWhere(
            (g) => g!.foods.any((f) =>
                item.value?.name != null &&
                f.name != null &&
                item.value!.name!.startsWith(f.name!)),
            orElse: () => null,
          );
      if (group != null) {
        grouped.putIfAbsent(group.imagePath, () => []).add(item);
      } else {
        ungrouped.add(item);
      }
    }

    return {
      ...grouped,
      for (final i in ungrouped) i.value?.name ?? '': [i]
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: kToolbarHeight + 28),
        child: SpringButton(
          SpringButtonType.withOpacity,
          onTap: () async {
            try {
              final result = await Navigator.push<File>(context,
                  MaterialPageRoute(builder: (_) => const CameraScreen()));
              if (result == null) return;
              final prepared = await NutritionService.prepareImage(result);

              if (!context.mounted) return;
              showModalBottomSheet(
                context: context,
                isDismissible: false,
                enableDrag: false,
                backgroundColor: Colors.transparent,
                builder: (_) => BlocProvider.value(
                  value: context.read<FoodScanCubit>(),
                  child: const FoodScanLoadingSheet(),
                ),
              );

              context.read<FoodScanCubit>().scanFoodImage(
                    base64Image: prepared.base64,
                    groupUuid: prepared.uuid,
                    imagePath: prepared.imagePath,
                  );
            } catch (e, s) {
              dev.log('Exception', error: e, stackTrace: s);
            }
          },
          uiChild: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [BoxShadow(color: Colors.grey)]),
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

          if (state is NutritionEmpty) {
            return Center(
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.searchFoodScreen),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.square_list,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text('No meals logged yet',
                        style: TextStyle(
                            color: _textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    const Text('Tap the scan button to add food',
                        style: TextStyle(color: _textSecondary, fontSize: 13)),
                    const SizedBox(height: 6),
                  ],
                ),
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

          return FutureBuilder<NutritionTargets>(
              future: TargetCalorieCalculator.calculate(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final targets = snapshot.data!;

                final targetCalories = targets.target.toDouble();
                final targetProtein = targets.protein;
                final targetCarbs = targets.carbs;
                final targetFat = targets.fat;

                // Compute once, not inside builder
                final groupedItems = _groupItems(items);
                return SafeArea(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                      onPressed: () => context
                                          .push(AppRoutes.searchFoodScreen),
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
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                color: _textSecondary,
                                                fontSize: 14)),
                                      ],
                                    ),
                                    const Spacer(),
                                    CircularProgress(
                                      value: (totalCalories / targetCalories)
                                          .clamp(0.0, 1.0),
                                      color: Colors.orange,
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
                                      label: totalProtein > targetProtein
                                          ? 'Protein over'
                                          : 'Protein',
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
                                      progress: (totalCarbs / targetCarbs)
                                          .clamp(0.0, 1.0),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: MacroCard(
                                      label: 'Fats left',
                                      value: (targetFat - totalFat)
                                          .clamp(0, targetFat),
                                      unit: 'g',
                                      color: _fatColor,
                                      icon: Icons.water_drop,
                                      progress: (totalFat / targetFat)
                                          .clamp(0.0, 1.0),
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
                            final entry = groupedItems.entries.elementAt(index);
                            final entryItems = entry.value;
                            final first = entryItems.first;
                            final isGroup = entryItems.length > 1;
                            final heroTag = entry.key;

                            return SpringButton(
                              SpringButtonType.withOpacity,
                              onTap: () async {
                                HapticFeedback.mediumImpact();
                                if (isGroup) {
                                  // ignore: use_build_context_synchronously
                                  // await _showGroupSheet(context, entryItems);
                                  context.push(GroupFoodDialog.name,
                                      extra: entryItems);
                                } else {
                                  // ignore: use_build_context_synchronously
                                  context.push('/nutrition/detail',
                                      extra: first);
                                }
                              },
                              uiChild: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 10),
                                child: SizedBox(
                                  height: 84 + (isGroup ? 16.0 : 10),
                                  child: Stack(
                                    children: [
                                      if (isGroup) ...[
                                        Positioned(
                                          left: 6,
                                          right: 14,
                                          bottom: 0,
                                          top: 6,
                                          child: CardShell(),
                                        ),
                                        if (entryItems.length > 2)
                                          Positioned(
                                            left: 12,
                                            right: 10,
                                            bottom: 0,
                                            top: 12,
                                            child: CardShell(),
                                          ),
                                      ],
                                      Positioned(
                                        left: 0,
                                        right: isGroup ? 6 : 0,
                                        top: 0,
                                        bottom: isGroup ? 6 : 0,
                                        // Wrap the main interactive card shell with Hero
                                        child: Hero(
                                          tag: heroTag,
                                          // Material ensures text styling behaves during flight
                                          child: Material(
                                            type: MaterialType.transparency,
                                            child: CardShell(
                                              child: BuildCardContent(
                                                item: first,
                                                count: entryItems.length,
                                                groupItems: entryItems,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: groupedItems.length,
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                );
              });
        },
      ),
    );
  }
}
