import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constants.dart';
import '../../models/workout_models.dart';
import '../../services/workout_service.dart';
import '../widgets/body_map_widget.dart';
import '../widgets/break_timer_widget.dart';
import '../widgets/exercise_detail_dialog.dart';

class WorkoutScreen extends StatefulWidget {
  static const String routeName = '/workout';

  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  final WorkoutService _service = WorkoutService();

  late TabController _tabController;
  int _selectedDay = DateTime.now().weekday; // 1 = Mon ... 7 = Sun
  final List<String> _dayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];
  List<PlannedExercise> _currentPlan = [];
  List<WorkoutLog> _workoutLogs = [];

  bool _isLoading = true;
  bool _hasHealthPermission = false;
  String? _selectedMuscleTarget;
  String _searchQuery = '';
  String? _selectedDifficulty;
  String _userGender = 'male';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final exercises = await _service.getExercises();
    final plan = await _service.getPlanForDay(_selectedDay);
    final logs = await _service.getWorkoutLogs();
    final hasPerm = await _service.hasHealthPermission();
    final prefs = await SharedPreferences.getInstance();
    final gender = prefs.getString(PrefKeys.gender)?.toLowerCase() ?? 'male';

    if (mounted) {
      setState(() {
        _allExercises = exercises;
        _filteredExercises = exercises;
        _currentPlan = plan;
        _workoutLogs = logs;
        _hasHealthPermission = hasPerm;
        _userGender = gender;
        _isLoading = false;
      });
    }
  }

  Future<void> _changeDay(int day) async {
    setState(() => _selectedDay = day);
    final plan = await _service.getPlanForDay(day);
    if (mounted) setState(() => _currentPlan = plan);
  }

  void _applyFilter() {
    setState(() {
      _filteredExercises = _allExercises.where((ex) {
        final matchesQuery =
            _searchQuery.isEmpty ||
            ex.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ex.bodyPart.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ex.target.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesMuscle =
            _selectedMuscleTarget == null ||
            ex.target.toLowerCase().contains(
              _selectedMuscleTarget!.toLowerCase(),
            ) ||
            ex.bodyPart.toLowerCase().contains(
              _selectedMuscleTarget!.toLowerCase(),
            ) ||
            ex.secondaryMuscles.any(
              (m) => m.toLowerCase().contains(
                _selectedMuscleTarget!.toLowerCase(),
              ),
            );

        final matchesDifficulty =
            _selectedDifficulty == null ||
            ex.difficulty.toLowerCase() == _selectedDifficulty!.toLowerCase();

        return matchesQuery && matchesMuscle && matchesDifficulty;
      }).toList();
    });
  }

  Future<void> _requestHealthPerm() async {
    final granted = await _service.requestHealthPermission();
    if (mounted) {
      setState(() => _hasHealthPermission = granted);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? 'Health Connect permission granted!'
                : 'Permission denied or cancelled.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Workout & Exercises',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Break Timer',
            icon: const Icon(Icons.timer_outlined, color: Colors.black87),
            onPressed: () => BreakTimerWidget.show(context),
          ),
          IconButton(
            tooltip: _hasHealthPermission
                ? 'Health Connect Connected'
                : 'Connect Health Connect',
            icon: Icon(
              Icons.health_and_safety,
              color: _hasHealthPermission ? Colors.green : Colors.orange,
            ),
            onPressed: _requestHealthPerm,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.black45,
          indicatorColor: Colors.black87,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Weekly Plan'),
            Tab(text: 'Explore & Body'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.black87),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPlanTab(),
                _buildExploreTab(),
                _buildHistoryTab(),
              ],
            ),
    );
  }

  // ==========================================
  // TAB 1: WEEKLY PLAN
  // ==========================================
  Widget _buildPlanTab() {
    final todayLogs = _workoutLogs.where((l) {
      final now = DateTime.now();
      return l.date.year == now.year &&
          l.date.month == now.month &&
          l.date.day == now.day;
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Health Connect Permission Banner (if not granted)
          if (!_hasHealthPermission)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Enable Health Connect to sync your completed workouts with Android Health.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _requestHealthPerm,
                    child: const Text(
                      'Connect',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          // Day of Week Selector
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Weekly Schedule',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _dayNames[_selectedDay - 1],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final dayNum = i + 1;
                    final isSel = _selectedDay == dayNum;
                    final isToday = DateTime.now().weekday == dayNum;
                    return GestureDetector(
                      onTap: () => _changeDay(dayNum),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSel ? Colors.black87 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: isToday
                              ? Border.all(color: Colors.blue, width: 1.5)
                              : null,
                        ),
                        child: Column(
                          children: [
                            Text(
                              _dayNames[i],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSel ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (isToday)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isSel ? Colors.white : Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Break timer widget
          const BreakTimerWidget(initialSeconds: 60),

          const SizedBox(height: 20),

          // Today's summary card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem(
                  'Planned',
                  '${_currentPlan.length}',
                  Icons.calendar_today,
                ),
                _statItem(
                  'Logged Today',
                  '${todayLogs.length}',
                  Icons.check_circle_outline,
                ),
                _statItem(
                  'Calories',
                  '${todayLogs.fold<int>(0, (sum, item) => sum + item.caloriesBurned)} kcal',
                  Icons.local_fire_department,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Planned Exercises Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercises for ${_dayNames[_selectedDay - 1]}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Exercise'),
                onPressed: () => _tabController.animateTo(1),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (_currentPlan.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.fitness_center_outlined,
                    size: 48,
                    color: Colors.black26,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No exercises planned for ${_dayNames[_selectedDay - 1]}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _tabController.animateTo(1),
                    child: const Text(
                      'Browse & Add to Plan',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._currentPlan.map((planned) => _buildPlanCard(planned)),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }

  void _openExerciseDetailsForPlanned(PlannedExercise planned) {
    final matched = _allExercises.firstWhere(
      (e) =>
          e.id == planned.exerciseId ||
          e.name.toLowerCase() == planned.exerciseName.toLowerCase(),
      orElse: () => Exercise(
        id: planned.exerciseId,
        name: planned.exerciseName,
        bodyPart: planned.bodyPart,
        target: planned.bodyPart,
        secondaryMuscles: const [],
        equipment: 'body weight',
        difficulty: 'intermediate',
        shortDescription: 'Planned workout exercise.',
        instructions: 'Follow standard form for ${planned.exerciseName}.',
        steps: const [],
        formCues: const [],
      ),
    );
    ExerciseDetailDialog.show(context, matched, onLogged: _loadInitialData);
  }

  Widget _buildPlanCard(PlannedExercise planned) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openExerciseDetailsForPlanned(planned),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planned.exerciseName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${planned.sets} sets × ${planned.reps} reps ${planned.weightKg > 0 ? "• ${planned.weightKg}kg" : ""} • ${planned.restSeconds}s rest',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Log directly',
                  icon: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 28,
                  ),
                  onPressed: () => _logPlannedExercise(planned),
                ),
                IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () => _confirmRemovePlannedExercise(planned),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmRemovePlannedExercise(PlannedExercise planned) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Remove Exercise'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Remove "${planned.exerciseName}" from ${_dayNames[_selectedDay - 1]}\'s schedule?',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.removeExerciseFromPlan(_selectedDay, planned.id);
      _changeDay(_selectedDay);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${planned.exerciseName}" from plan'),
          ),
        );
      }
    }
  }

  void _logPlannedExercise(PlannedExercise planned) async {
    final log = await _service.logWorkout(
      exerciseName: planned.exerciseName,
      bodyPart: planned.bodyPart,
      sets: planned.sets,
      reps: planned.reps,
      weightKg: planned.weightKg,
      durationMinutes:
          (planned.sets * 3) + (planned.sets * planned.restSeconds ~/ 60),
      caloriesBurned: planned.sets * 25,
      syncHealthConnect: true,
    );
    await _loadInitialData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            log.syncedHealthConnect
                ? 'Logged "${planned.exerciseName}" to Health Connect!'
                : 'Logged "${planned.exerciseName}" locally!',
          ),
        ),
      );
    }
  }

  // ==========================================
  // TAB 2: EXPLORE & BODY MAP
  // ==========================================
  Widget _buildExploreTab() {
    return Column(
      children: [
        // Search & Filter header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search 300+ exercises with video...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() => _searchQuery = '');
                            _applyFilter();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  _searchQuery = val;
                  _applyFilter();
                },
              ),
              const SizedBox(height: 8),
              // Difficulty chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    _diffChip('All', null, icon: Icons.grid_view_rounded),
                    const SizedBox(width: 8),
                    _diffChip(
                      'Beginner',
                      'beginner',
                      dotColor: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    _diffChip(
                      'Intermediate',
                      'intermediate',
                      dotColor: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 8),
                    _diffChip(
                      'Advanced',
                      'advanced',
                      dotColor: const Color(0xFFEF4444),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List & Body Map
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              // Interactive Body Map Anatomy widget (Front / Back SVG)
              BodyMapWidget(
                selectedTarget: _selectedMuscleTarget,
                onTargetSelected: (target) {
                  setState(() => _selectedMuscleTarget = target);
                  _applyFilter();
                },
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exercises (${_filteredExercises.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  if (_selectedMuscleTarget != null)
                    Text(
                      'Filtered: $_selectedMuscleTarget',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              if (_filteredExercises.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  alignment: Alignment.center,
                  child: const Text('No exercises found matching criteria.'),
                )
              else
                ..._filteredExercises.map(
                  (exercise) => _buildExerciseCard(exercise),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _diffChip(
    String label,
    String? val, {
    IconData? icon,
    Color? dotColor,
  }) {
    final isSel = _selectedDifficulty == val;
    final activeColor = dotColor ?? Colors.black87;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedDifficulty = val);
        _applyFilter();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSel ? activeColor : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSel ? activeColor : Colors.grey.shade300,
            width: isSel ? 1.5 : 1.0,
          ),
          boxShadow: isSel
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSel ? Colors.white : dotColor,
                ),
              ),
              const SizedBox(width: 6),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSel ? Colors.white : Colors.black54,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                color: isSel ? Colors.white : Colors.black87,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise ex) {
    final thumb = _userGender == 'female'
        ? (ex.femaleThumbnail ?? ex.maleThumbnail ?? '')
        : (ex.maleThumbnail ?? ex.femaleThumbnail ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            ExerciseDetailDialog.show(context, ex, onLogged: _loadInitialData);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey.shade100,
                    child: thumb.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: thumb,
                            fit: BoxFit.cover,
                            width: 64,
                            height: 64,
                            errorWidget: (ctx, err, stack) => const Icon(
                              Icons.fitness_center,
                              color: Colors.black26,
                            ),
                          )
                        : const Icon(
                            Icons.fitness_center,
                            color: Colors.black26,
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ex.bodyPart,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ex.difficulty,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: WORKOUT HISTORY & HEALTH CONNECT
  // ==========================================
  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Logged Sessions (${_workoutLogs.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              if (!_hasHealthPermission)
                TextButton.icon(
                  onPressed: _requestHealthPerm,
                  icon: const Icon(Icons.sync, size: 16),
                  label: const Text('Connect Health'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_workoutLogs.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.history, size: 48, color: Colors.black26),
                  const SizedBox(height: 12),
                  const Text(
                    'No workout logs yet.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Log an exercise from the Explore or Plan tab.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ..._workoutLogs.map((log) => _buildLogItem(log)),
        ],
      ),
    );
  }

  Widget _buildLogItem(WorkoutLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.check, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.exerciseName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${log.setsCompleted} sets × ${log.reps} reps ${log.weightKg > 0 ? "• ${log.weightKg}kg" : ""} • ${log.durationMinutes} min • ${log.caloriesBurned} kcal',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${log.date.day}/${log.date.month}/${log.date.year} ${log.date.hour.toString().padLeft(2, '0')}:${log.date.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: log.syncedHealthConnect
                      ? Colors.green.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 12,
                      color: log.syncedHealthConnect
                          ? Colors.green
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      log.syncedHealthConnect ? 'Health Connect' : 'Local',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: log.syncedHealthConnect
                            ? Colors.green.shade800
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: Colors.blueAccent,
                ),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text(
                  'Edit',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _showEditLogDialog(log),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: Colors.redAccent,
                ),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text(
                  'Delete',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _deleteLog(log),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditLogDialog(WorkoutLog log) {
    int sets = log.setsCompleted;
    int reps = log.reps;
    double weight = log.weightKg;
    int duration = log.durationMinutes;
    int calories = log.caloriesBurned;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Edit Log: ${log.exerciseName}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _stepperEditRow(
                    'Sets',
                    sets,
                    '',
                    (v) => setSheetState(() => sets = (sets + v).clamp(1, 50)),
                  ),
                  const SizedBox(height: 10),
                  _stepperEditRow(
                    'Reps',
                    reps,
                    '',
                    (v) => setSheetState(() => reps = (reps + v).clamp(1, 200)),
                  ),
                  const SizedBox(height: 10),
                  _stepperEditRow(
                    'Weight',
                    weight.round(),
                    'kg',
                    (v) => setSheetState(
                      () => weight = (weight + v).clamp(0.0, 500.0),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _stepperEditRow(
                    'Duration',
                    duration,
                    'min',
                    (v) => setSheetState(
                      () => duration = (duration + v).clamp(1, 300),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _stepperEditRow(
                    'Calories',
                    calories,
                    'kcal',
                    (v) => setSheetState(
                      () => calories = (calories + (v * 10)).clamp(5, 3000),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        final updated = log.copyWith(
                          setsCompleted: sets,
                          reps: reps,
                          weightKg: weight,
                          durationMinutes: duration,
                          caloriesBurned: calories,
                        );
                        await _service.updateWorkoutLog(updated);
                        if (ctx.mounted) Navigator.pop(ctx);
                        await _loadInitialData();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Workout log updated!'),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _stepperEditRow(
    String label,
    int value,
    String unit,
    ValueChanged<int> onChange,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove_circle_outline, size: 22),
                onPressed: () => onChange(-1),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 50),
                alignment: Alignment.center,
                child: Text(
                  '$value${unit.isNotEmpty ? " $unit" : ""}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline, size: 22),
                onPressed: () => onChange(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _deleteLog(WorkoutLog log) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Workout Log'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Are you sure you want to delete the log for "${log.exerciseName}"?',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.deleteWorkoutLog(log.id);
      await _loadInitialData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Workout log deleted')));
      }
    }
  }
}
