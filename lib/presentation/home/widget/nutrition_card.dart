import 'package:ahealth/blocs/nutrition/nutrition_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/spring_button_widget.dart';
import '../../common/nutrition_calc.dart';

const _kOnSurfaceVariant = Color(0xFF40493D);
const _kSecondaryContainer = Color(0xFFFC820C);
const _kPrimary = Color(0xFF0D631B);
const _kTertiary = Color(0xFF00569F);
const _kSurfaceContainerHighest = Color(0xFFE3E2E2);

class NutritionCard extends StatelessWidget {
  const NutritionCard({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: FutureBuilder<NutritionTargets>(
            future: TargetCalorieCalculator.calculate(),
            builder: (context, asyncSnapshot) {
              final targets = asyncSnapshot.data;
              final target = targets?.target ?? 2200;
              return BlocBuilder<NutritionCubit, NutritionState>(
                builder: (context, state) {
                  num consumed = 0;
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
                  final percent =
                      target == 0 ? 0.0 : (consumed / target).clamp(0.0, 1.0);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (targets != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'BMR ${targets.bmr} · TDEE ${targets.tdee} · ${targets.activityLabel}',
                            style: TextStyle(
                                fontSize: 10,
                                color:
                                    _kOnSurfaceVariant.withValues(alpha: 0.7)),
                          ),
                        ),
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
                                      color: _kSecondaryContainer.withValues(
                                          alpha: 0.1),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: _kSecondaryContainer.withValues(
                                            alpha: 0.2),
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
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _MacroChip(
                              label: 'PROTEIN',
                              value: '${protein}g',
                              color: _kPrimary),
                          const SizedBox(width: 12),
                          _MacroChip(
                              label: 'CARBS',
                              value: '${carbs}g',
                              color: _kSecondaryContainer),
                          const SizedBox(width: 12),
                          _MacroChip(
                              label: 'FATS',
                              value: '${fats.toStringAsPrecision(2)}g',
                              color: _kTertiary),
                        ],
                      ),
                    ],
                  );
                },
              );
            }),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
}
