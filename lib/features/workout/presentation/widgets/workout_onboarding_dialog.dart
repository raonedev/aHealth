import 'package:flutter/material.dart';
import '../../services/workout_service.dart';

class WorkoutOnboardingDialog extends StatefulWidget {
  const WorkoutOnboardingDialog({super.key});

  /// Displays the first-time workout questionnaire.
  /// Returns `true` if a recommended plan was applied, `false` otherwise.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const WorkoutOnboardingDialog(),
    );
  }

  @override
  State<WorkoutOnboardingDialog> createState() =>
      _WorkoutOnboardingDialogState();
}

class _WorkoutOnboardingDialogState extends State<WorkoutOnboardingDialog> {
  final WorkoutService _service = WorkoutService();

  // Selected values
  String _selectedGoal = 'build_muscle';
  String _selectedLevel = 'beginner';
  bool _wantRecommendation = true;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _goals = [
    {
      'key': 'build_muscle',
      'title': 'Build muscle',
      'icon': Icons.fitness_center_rounded,
      'desc': 'Hypertrophy & muscle growth',
    },
    {
      'key': 'lose_fat',
      'title': 'Lose fat',
      'icon': Icons.local_fire_department_rounded,
      'desc': 'Calorie burn & lean definition',
    },
    {
      'key': 'improve_strength',
      'title': 'Improve strength',
      'icon': Icons.sports_gymnastics_rounded,
      'desc': 'Heavy lifting & raw power',
    },
    {
      'key': 'improve_endurance',
      'title': 'Improve endurance',
      'icon': Icons.directions_run_rounded,
      'desc': 'Stamina & cardiovascular health',
    },
    {
      'key': 'general_fitness',
      'title': 'General fitness',
      'icon': Icons.favorite_rounded,
      'desc': 'Overall health & daily wellness',
    },
  ];

  final List<Map<String, dynamic>> _levels = [
    {
      'key': 'beginner',
      'title': 'Beginner',
      'desc': 'New to workouts or getting started',
    },
    {
      'key': 'intermediate',
      'title': 'Intermediate',
      'desc': 'Consistent training for 6+ months',
    },
    {
      'key': 'advanced',
      'title': 'Advanced',
      'desc': 'Structured high-intensity routines',
    },
  ];

  Future<void> _handleConfirm() async {
    setState(() => _isSaving = true);

    bool applied = false;
    if (_wantRecommendation) {
      applied = await _service.applyRecommendedPlan(
        _selectedGoal,
        _selectedLevel,
      );
    }

    await _service.setWorkoutOnboardingCompleted(
      completed: true,
      goal: _selectedGoal,
      level: _selectedLevel,
    );

    if (mounted) {
      Navigator.of(context).pop(applied);
    }
  }

  Future<void> _handleSkip() async {
    await _service.setWorkoutOnboardingCompleted(completed: true);
    if (mounted) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return PopScope(
      canPop: !_isSaving,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _service.setWorkoutOnboardingCompleted(completed: true);
        }
      },
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Workout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Personalize your routine in seconds',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isSaving)
                    TextButton(
                      onPressed: _handleSkip,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 20),

            // Questions list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // Question 1: Goal
                  _buildQuestionTitle(
                    number: '1',
                    question: 'What is your main goal?',
                  ),
                  const SizedBox(height: 10),
                  ..._goals.map((g) {
                    final isSelected = _selectedGoal == g['key'];
                    return _buildOptionTile(
                      title: g['title'] as String,
                      subtitle: g['desc'] as String,
                      icon: g['icon'] as IconData,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() => _selectedGoal = g['key'] as String);
                      },
                    );
                  }),

                  const SizedBox(height: 20),

                  // Question 2: Fitness Level
                  _buildQuestionTitle(
                    number: '2',
                    question: 'What is your fitness level?',
                  ),
                  const SizedBox(height: 10),
                  ..._levels.map((lvl) {
                    final isSelected = _selectedLevel == lvl['key'];
                    return _buildOptionTile(
                      title: lvl['title'] as String,
                      subtitle: lvl['desc'] as String,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() => _selectedLevel = lvl['key'] as String);
                      },
                    );
                  }),

                  const SizedBox(height: 20),

                  // Question 3: Recommendation
                  _buildQuestionTitle(
                    number: '3',
                    question: 'Default recommended plan?',
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Would you like us to automatically load recommended exercises into your weekly plan based on your goal?',
                    style: TextStyle(fontSize: 12.5, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  _buildOptionTile(
                    title: 'Yes, load recommended exercises',
                    subtitle: 'Prefill my weekly schedule with curated exercises',
                    icon: Icons.auto_awesome_rounded,
                    isSelected: _wantRecommendation,
                    onTap: () => setState(() => _wantRecommendation = true),
                  ),
                  _buildOptionTile(
                    title: 'No, I\'ll create my own plan',
                    subtitle: 'Start with an empty schedule and add manually',
                    icon: Icons.edit_calendar_rounded,
                    isSelected: !_wantRecommendation,
                    onTap: () => setState(() => _wantRecommendation = false),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Bottom CTA
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _wantRecommendation
                              ? 'Generate Plan & Continue'
                              : 'Start My Plan',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTitle({
    required String number,
    required String question,
  }) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50.withValues(alpha: 0.5) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.blue.shade700 : Colors.black54,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.blue.shade900 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isSelected ? Colors.blue.shade800 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                size: 20,
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

