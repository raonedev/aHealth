// ignore_for_file: use_build_context_synchronously


import 'package:ahealth/common/spring_button_widget.dart';
import 'package:ahealth/presentation/home/widget/height_card.dart';
import 'package:ahealth/presentation/sleep/sleep_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../app_routes.dart';
import '../../appcolors.dart';
import '../../blocs/nutrition/nutrition_cubit.dart';
import '../../blocs/sleep/sleep_cubit.dart';
import '../../blocs/step/step_cubit.dart';
import '../../blocs/water/water_cubit.dart';
import '../../blocs/weight/weight_cubit.dart';
import '../../helper/helper_func.dart';
const _kPrimary = Color(0xFF0D631B);
const _kPrimaryContainer = Color(0xFF2E7D32);
const _kSecondaryContainer = Color(0xFFFC820C);
const _kTertiary = Color(0xFF00569F);
const _kOnSurfaceVariant = Color(0xFF40493D);
const _kSurfaceContainerLowest = Color(0xFFFFFFFF);
const _kSurfaceContainerHighest = Color(0xFFE3E2E2);

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            _buildTopBar(context),
            const SizedBox(height: 8),
            _buildNutritionCard(context),
            const SizedBox(height: 16),
            _buildStepsCard(context),
            const SizedBox(height: 16),
             Row(
              children: [
                Expanded(child: _buildHydrationCard(context)),
                const SizedBox(width: 16),
                Expanded(child: _buildWeightCard(context)),
              ],
            ),
            const SizedBox(height: 16),
            HeightCard(),
            const SizedBox(height: 16),
            _buildSleepCard(context),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: 56,
          height: 56,
          child: FloatingActionButton(
            backgroundColor: _kPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onPressed: () {
              context.push(AppRoutes.stepsTrackingScreen);
            },
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedWorkoutRun,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ---- Top bar -------------------------------------------------------

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAJtVbqxggIsR_e7KqZyZO0g0gVoC-0DoAHd_qh9wmN9na-aOysN3OTP7HvohOtLfx72vUeWuToNo_oOWeGjUISmoxk4zzB99FGOjY7kz3yQduM-xAoJx4UTitnmCUsGDpY_-Upg_tCwfs1cjS9bWSwAYcuW9bDkrdbQ8u9NcQp0Jrc6cIesmtnQc-8JppW3xMJIxoMbtqqNCWc_4IxmKv9PULowc0Qpd6mUSdL7UMqGrs7EpJGy2lGaw20E9AnfTWkDu5NCn-xKGc',
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WELCOME BACK,',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: _kOnSurfaceVariant,
                  ),
                ),
                const Text(
                  // TODO: bind to real user name
                  'Alex',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
        SpringButton(
          SpringButtonType.withOpacity,
          onTap: () {},
          uiChild: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _kSurfaceContainerLowest,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:  0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(Icons.search, color: _kOnSurfaceVariant),
          ),
        ),
      ],
    );
  }

  // ---- Nutrition card --------------------------------------------------

  Widget _buildNutritionCard(BuildContext context) {
    return SpringButton(
      SpringButtonType.withOpacity,
      onTap: () async {
        HapticFeedback.mediumImpact();
        await Future.delayed(Durations.medium1);
        context.go('/shell/nutrition');
      },
      uiChild: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFFFFBF8)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BlocBuilder<NutritionCubit, NutritionState>(
          builder: (context, state) {
            num consumed = 0;
            num target = 2200;
            num protein = 0, carbs = 0, fats = 0;

            if (state is NutritionSuccess) {
               for (final entry in state.nutritionModel) {
                consumed += entry.value?.calories ?? 0;
                protein += entry.value?.protein ?? 0;
                carbs += entry.value?.carbs ?? 0;
                fats += entry.value?.fat ?? 0;
              }
            }

            final remaining = (target - consumed).clamp(0, target);
            final percent = target == 0 ? 0.0 : (consumed / target).clamp(0.0, 1.0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DAILY NUTRITION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: _kOnSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.end,
                            children: [
                              Text(
                                '$consumed',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '/ $target kcal',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _kOnSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (state is NutritionLoading)
                            const CupertinoActivityIndicator()
                          else if (state is NutritionFailed)
                            Text(state.errorMessage,
                                style: const TextStyle(color: Colors.red))
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _kSecondaryContainer.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: _kSecondaryContainer.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                '$remaining kcal left',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _kSecondaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 112,
                      height: 112,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 112,
                            height: 112,
                            child: CircularProgressIndicator(
                              value: percent,
                              strokeWidth: 8,
                              backgroundColor: _kSurfaceContainerHighest,
                              valueColor: const AlwaysStoppedAnimation(
                                  _kSecondaryContainer),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_fire_department,
                              color: _kSecondaryContainer,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ), const SizedBox(height: 20),
                Row(
                  children: [
                    _macroChip('PROTEIN', '${protein}g', _kPrimary),
                    const SizedBox(width: 12),
                    _macroChip('CARBS', '${carbs}g', _kSecondaryContainer),
                    const SizedBox(width: 12),
                    _macroChip('FATS', '${fats}g', _kTertiary),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _macroChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _kOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Steps card -----------------------------------------------------

  Widget _buildStepsCard(BuildContext context) {
    const target = 8000;

    return SpringButton(
      SpringButtonType.withOpacity,
      onTap: () async {
        HapticFeedback.mediumImpact();
        await Future.delayed(Durations.medium1);
        context.push(AppRoutes.stepChartScreen);
      },
      uiChild: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF7FDF7)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BlocBuilder<StepsCubit, StepsState>(
          builder: (context, state) {
            num steps = 0;
            Widget trailing = const SizedBox();

            if (state is StepLoadingState) {
              trailing = const CupertinoActivityIndicator();
            } else if (state is StepFailed) {
              steps = 0;
            } else if (state is StepSuccessState) {
              for (final step in state.stepModel) {
                if (step.value != null) {
                  steps += step.value!.numericValue ?? 0;
                }
              }
            }

            final percent = (steps / target).clamp(0.0, 1.0);

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _kPrimaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.directions_walk,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STEPS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: _kOnSurfaceVariant,
                              ),
                            ),
                            trailing is CupertinoActivityIndicator
                                ? trailing
                                : Text(
                                    '$steps / $target',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '${(percent * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _kPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    backgroundColor:
                        _kSurfaceContainerHighest.withValues(alpha: 0.5),
                    valueColor:
                        const AlwaysStoppedAnimation(_kPrimaryContainer),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---- Hydration card ---------------------------------------------------

  Widget _buildHydrationCard(BuildContext context) {
    const target = 3.0;

    return SpringButton(
      SpringButtonType.withOpacity,
      onTap: () async {
        HapticFeedback.mediumImpact();
        await Future.delayed(Durations.medium1);
        context.push(AppRoutes.waterChartScreen);
      },
      uiChild: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _kSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BlocBuilder<WaterCubit, WaterState>(
          builder: (context, state) {
            double liters = 0;
             if (state is WaterSuccessState) {
              for (final entry in state.waterModel) {
                liters += entry.value?.numericValue ?? 0;
              }
            }
            final percent = (liters / target).clamp(0.0, 1.0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HYDRATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: _kOnSurfaceVariant,
                      ),
                    ),
                    Icon(Icons.water_drop, color: _kTertiary, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                if (state is WaterLoadingState)
                  const CupertinoActivityIndicator()
                else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        liters.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: _kTertiary,
                        ),
                      ),
                      const Text('L', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Text(
                    'Target: ${target}L',
                    style: TextStyle(fontSize: 11, color: _kOnSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 6,
                    backgroundColor: _kTertiary.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(
                        _kTertiary.withValues(alpha: 0.8)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---- Weight card ------------------------------------------------------

  Widget _buildWeightCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: BlocBuilder<WeightCubit, WeightState>(
        builder: (context, state) {
          Widget content;
          if (state is WeightLoading) {
            content = const CupertinoActivityIndicator();
          } else if (state is WeightFailed) {
            content = Text(state.errorMessage,
                style: const TextStyle(fontSize: 12, color: Colors.red));
          } else if (state is WeightSuccess && state.weightModel.isNotEmpty) {
            final value = state.weightModel[0].value?.numericValue;
            content = Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    text: value != null ? '$value ' : '0 ',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                    children: const [
                      TextSpan(
                        text: 'kg',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.south_east, color: _kPrimary, size: 16),
              ],
            );
          } else {
            content = const Text('No Weight Data', style: TextStyle(fontSize: 12));
          }

          return GestureDetector(
            onTap: () => showWeightDialog(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'WEIGHT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: _kOnSurfaceVariant,
                      ),
                    ),
                    Icon(Icons.monitor_weight,
                        color: _kOnSurfaceVariant, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                content,
              ],
            ),
          );
        },
      ),
    );
  }

  // ---- Sleep card -------------------------------------------------------

  Widget _buildSleepCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return const SleepPickerBottomSheet();
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _kSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BlocBuilder<SleepCubit, SleepState>(
          builder: (context, state) {
            String duration = '--';
            if (state is SleepSuccessState && state.sleepModel.isNotEmpty) {
              final minutes = state.sleepModel[0].value?.numericValue ?? 0;
              final hours = (minutes / 60);
              duration = '${hours.floor()}h ${((hours - hours.floor()) * 60).round()}m';
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _kTertiary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.bedtime, color: _kTertiary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SLEEP QUALITY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: _kOnSurfaceVariant,
                              ),
                            ),
                            if (state is SleepLoadingState)
                              const CupertinoActivityIndicator()
                            else if (state is SleepFailedState)
                              const Text('failed to load sleep',
                                  style: TextStyle(fontSize: 12))
                            else
                              Text(
                                duration,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                          ],
                        ),
                      ],
                    ),
                    // TODO: real sleep score isn't in SleepState — wire up if available
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _kPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _kPrimary.withValues(alpha: 0.2)),
                      ),
                      child: const Text(
                        'SCORE: 84',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Static placeholder bars — replace with real hourly sleep data if available
                SizedBox(
                  height: 80,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [0.3, 0.6, 0.85, 0.45, 0.75, 0.35, 0.65, 1.0, 0.4]
                        .map((h) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Container(
                                  height: 80 * h,
                                  decoration: BoxDecoration(
                                    color: _kTertiary.withValues(alpha: 0.3 + h * 0.4),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('11:30 PM',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _kOnSurfaceVariant.withValues(alpha: 0.6))),
                    // TODO: real REM duration isn't in SleepState — wire up if available
                    const Text('REM Sleep: 1h 45m',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    Text('06:50 AM',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _kOnSurfaceVariant.withValues(alpha: 0.6))),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}