 import 'package:ahealth/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home/widget/nutrition_card.dart';

Future<void> showEditGoalDialog(BuildContext context) async {
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
        subtitle: 'Office work, very little walking, no regular exercise',
        icon: Icons.weekend_rounded,
      ),
      SelectionOption(
        key: 'lightlyActive',
        title: 'Lightly Active',
        subtitle: 'Office work + light workouts or short gym sessions',
        icon: Icons.directions_walk_rounded,
      ),
      SelectionOption(
        key: 'moderatelyActive',
        title: 'Moderately Active',
        subtitle: 'Office work + gym for 45–60 minutes, 5–6 days/week',
        icon: Icons.directions_run_rounded,
      ),
      SelectionOption(
        key: 'veryActive',
        title: 'Very Active',
        subtitle: 'Office work + intense training and high daily physical activity',
        icon: Icons.directions_bike_rounded,
      ),
      SelectionOption(
        key: 'extraActive',
        title: 'Extra Active',
        subtitle: 'Intense training plus physically demanding work or substantial daily activity',
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          if (currentStep > 0)
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 18,
                              ),
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
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString(
                                PrefKeys.healthGoal,
                                selectedGoal,
                              );
                              await prefs.setString(
                                PrefKeys.activityLevel,
                                selectedActivity,
                              );
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          child: Text(
                            isLastStep ? 'Save Changes' : 'Next Step',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
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

