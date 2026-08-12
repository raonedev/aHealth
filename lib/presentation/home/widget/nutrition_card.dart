import 'package:ahealth/blocs/nutrition/nutrition_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/spring_button_widget.dart';
import '../../../constants.dart';
import '../../common/nutrition_calc.dart';

const _kOnSurfaceVariant = Color(0xFF40493D);
const _kSecondaryContainer = Color(0xFFFC820C);
const _kPrimary = Color(0xFF0D631B);
const _kTertiary = Color(0xFF00569F);
const _kSurfaceContainerHighest = Color(0xFFE3E2E2);

// Helper model to structure options cleanly
class SelectionOption {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;

  const SelectionOption({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class NutritionCard extends StatefulWidget {
  const NutritionCard({super.key});

  @override
  State<NutritionCard> createState() => _NutritionCardState();
}

class _NutritionCardState extends State<NutritionCard> {
  late Future<NutritionTargets> _targetsFuture;

  @override
  void initState() {
    super.initState();
    _targetsFuture = TargetCalorieCalculator.calculate();
  }

  void _refreshTargets() {
    setState(() {
      _targetsFuture = TargetCalorieCalculator.calculate();
    });
  }

  Future<void> _showEditGoalDialog(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  String selectedGoal =
      prefs.getString(PrefKeys.healthGoal) ?? 'maintainWeight';
  String selectedActivity =
      prefs.getString(PrefKeys.activityLevel) ?? 'lightlyActive';

  const goals = [
    SelectionOption(
      key: 'lossWeight',
      title: 'Weight Loss',
      subtitle: 'Burn fat and lower body weight',
      icon: Icons.trending_down_rounded,
    ),
    SelectionOption(
      key: 'gainWeight',
      title: 'Weight Gain',
      subtitle: 'Increase overall body mass',
      icon: Icons.trending_up_rounded,
    ),
    SelectionOption(
      key: 'maintainWeight',
      title: 'Maintain Weight',
      subtitle: 'Keep current weight and stay fit',
      icon: Icons.balance_rounded,
    ),
    SelectionOption(
      key: 'gainMuscle',
      title: 'Muscle Gain',
      subtitle: 'Build muscle strength and density',
      icon: Icons.fitness_center_rounded,
    ),
    SelectionOption(
      key: 'lifeStyleImprove',
      title: 'Lifestyle Improvement',
      subtitle: 'Focus on general health & vitality',
      icon: Icons.favorite_rounded,
    ),
  ];

  const activityLevels = [
    SelectionOption(
      key: 'sedentary',
      title: 'Sedentary',
      subtitle: 'Little or no daily exercise',
      icon: Icons.weekend_rounded,
    ),
    SelectionOption(
      key: 'lightlyActive',
      title: 'Lightly Active',
      subtitle: 'Light exercise 1–3 days/week',
      icon: Icons.directions_walk_rounded,
    ),
    SelectionOption(
      key: 'moderatelyActive',
      title: 'Moderately Active',
      subtitle: 'Moderate exercise 3–5 days/week',
      icon: Icons.directions_run_rounded,
    ),
    SelectionOption(
      key: 'veryActive',
      title: 'Very Active',
      subtitle: 'Hard exercise 6–7 days/week',
      icon: Icons.directions_bike_rounded,
    ),
    SelectionOption(
      key: 'extraActive',
      title: 'Extra Active',
      subtitle: 'Very physical job or hard training',
      icon: Icons.bolt_rounded,
    ),
  ];

  if (!context.mounted) return;

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      int currentStep = 0;
      final PageController pageController = PageController();

      return StatefulBuilder(
        builder: (context, setModalState) {
          final isLastStep = currentStep == 1;

          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.70,
            child: SafeArea(
              child: Column(
                children: [
                  // Drag Handle Indicator
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  // Header with Progress Indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        if (currentStep > 0)
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                            onPressed: () {
                              setModalState(() => currentStep--);
                              pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          )
                        else
                          const SizedBox(width: 40),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                currentStep == 0
                                    ? 'Select Your Goal'
                                    : 'Select Activity Level',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Step ${currentStep + 1} of 2',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Step Content Pages
                  Expanded(
                    child: PageView(
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Step 1: Goal Selection
                        _SelectionListView(
                          options: goals,
                          selectedValue: selectedGoal,
                          onSelect: (value) {
                            setModalState(() => selectedGoal = value);
                          },
                        ),
                        // Step 2: Activity Level Selection
                        _SelectionListView(
                          options: activityLevels,
                          selectedValue: selectedActivity,
                          onSelect: (value) {
                            setModalState(() => selectedActivity = value);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Bottom Action Button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          if (!isLastStep) {
                            setModalState(() => currentStep = 1);
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString(
                                PrefKeys.healthGoal, selectedGoal);
                            await prefs.setString(
                                PrefKeys.activityLevel, selectedActivity);
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                        child: Text(
                          isLastStep ? 'Save Changes' : 'Next Step',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return SpringButton(
      SpringButtonType.withOpacity,
      onTap: () async {
        HapticFeedback.mediumImpact();
        await Future.delayed(Durations.medium1);
        if (!context.mounted) return;
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
            future: _targetsFuture,
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
                        TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () async {
                              await _showEditGoalDialog(context);
                              _refreshTargets();
                            },
                            child: Text(
                              'BMR ${targets.bmr} · TDEE ${targets.tdee} · ${targets.activityLabel}',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: _kOnSurfaceVariant.withValues(
                                      alpha: 0.7)),
                            )),
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
                              value: '${protein.toStringAsFixed(0)}g',
                              color: _kPrimary),
                          const SizedBox(width: 12),
                          _MacroChip(
                              label: 'CARBS',
                              value: '${carbs.toInt()}g',
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


// Custom Choice Card List
class _SelectionListView extends StatelessWidget {
  final List<SelectionOption> options;
  final String selectedValue;
  final ValueChanged<String> onSelect;

  const _SelectionListView({
    required this.options,
    required this.selectedValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = option.key == selectedValue;

        return InkWell(
          onTap: () => onSelect(option.key),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.08)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  option.icon,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}