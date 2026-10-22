import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../../../constants.dart';
import '../../models/workout_models.dart';
import '../../services/workout_service.dart';

class ExerciseDetailDialog extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback? onLogged;

  const ExerciseDetailDialog({
    super.key,
    required this.exercise,
    this.onLogged,
  });

  static Future<void> show(BuildContext context, Exercise exercise, {VoidCallback? onLogged}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExerciseDetailDialog(exercise: exercise, onLogged: onLogged),
    );
  }

  @override
  State<ExerciseDetailDialog> createState() => _ExerciseDetailDialogState();
}

class _ExerciseDetailDialogState extends State<ExerciseDetailDialog> {
  VideoPlayerController? _videoController;
  bool _isPlaying = true;
  bool _isFemaleSelected = false;
  bool _isVideoLoading = false;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    _loadGenderAndInit();
  }

  Future<void> _loadGenderAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    final gender = prefs.getString(PrefKeys.gender)?.toLowerCase() ?? 'male';
    if (mounted) {
      setState(() {
        _isFemaleSelected = gender == 'female';
      });
    }
    _initVideo();
  }

  void _initVideo() async {
    final videoUrl = _isFemaleSelected
        ? widget.exercise.femaleVideo
        : widget.exercise.maleVideo;

    if (videoUrl == null || videoUrl.isEmpty) {
      setState(() => _isVideoLoading = false);
      return;
    }

    setState(() {
      _isVideoLoading = true;
    });

    _videoController?.dispose();
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(_isMuted ? 0.0 : 1.0);
      await controller.play();
      if (mounted) {
        setState(() {
          _videoController = controller;
          _isPlaying = true;
          _isVideoLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _isPlaying = false;
      } else {
        _videoController!.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleMute() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _videoController!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  String get _currentThumbnail => _isFemaleSelected
      ? (widget.exercise.femaleThumbnail ?? widget.exercise.maleThumbnail ?? '')
      : (widget.exercise.maleThumbnail ?? widget.exercise.femaleThumbnail ?? '');

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video / Thumbnail container
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      height: 280,
                      width: double.infinity,
                      color: Colors.black,
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: [
                          if (_videoController != null &&
                              _videoController!.value.isInitialized)
                            Positioned.fill(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                clipBehavior: Clip.hardEdge,
                                child: SizedBox(
                                  width: _videoController!.value.size.width,
                                  height: _videoController!.value.size.height,
                                  child: VideoPlayer(_videoController!),
                                ),
                              ),
                            )
                          else if (_currentThumbnail.isNotEmpty)
                            Positioned.fill(
                              child: Image.network(
                                _currentThumbnail,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => const Center(
                                  child: Icon(Icons.fitness_center, size: 64, color: Colors.white38),
                                ),
                              ),
                            )
                          else
                            const Center(
                              child: Icon(Icons.fitness_center, size: 64, color: Colors.white38),
                            ),

                          if (_isVideoLoading)
                            const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            )
                          else if (_videoController != null &&
                              _videoController!.value.isInitialized)
                            Center(
                              child: GestureDetector(
                                onTap: _togglePlayPause,
                                child: AnimatedOpacity(
                                  opacity: _isPlaying ? 0.0 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(14),
                                    child: Icon(
                                      _isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 38,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Male / Female switcher toggle badge
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _GenderButton(
                                    label: 'Male',
                                    isSelected: !_isFemaleSelected,
                                    onTap: () {
                                      if (_isFemaleSelected) {
                                        setState(() => _isFemaleSelected = false);
                                        _initVideo();
                                      }
                                    },
                                  ),
                                  _GenderButton(
                                    label: 'Female',
                                    isSelected: _isFemaleSelected,
                                    onTap: () {
                                      if (!_isFemaleSelected) {
                                        setState(() => _isFemaleSelected = true);
                                        _initVideo();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Mute / Unmute toggle button
                          Positioned(
                            bottom: 14,
                            right: 14,
                            child: GestureDetector(
                              onTap: _toggleMute,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  _isMuted ? Icons.volume_off : Icons.volume_up,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title & Target Muscle
                  Text(
                    widget.exercise.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _badge(widget.exercise.bodyPart.toUpperCase(), Colors.blue.shade50, Colors.blue.shade800),
                      _badge(widget.exercise.target, Colors.green.shade50, Colors.green.shade800),
                      _badge(widget.exercise.difficulty, Colors.amber.shade50, Colors.amber.shade900),
                      if (widget.exercise.equipment.isNotEmpty)
                        _badge(widget.exercise.equipment, Colors.grey.shade100, Colors.grey.shade800),
                    ],
                  ),

                  if (widget.exercise.shortDescription.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      widget.exercise.shortDescription,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
                    ),
                  ],

                  if (widget.exercise.steps.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Text('Steps', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ...widget.exercise.steps.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${entry.key + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 13, height: 1.35))),
                          ],
                        ),
                      );
                    }),
                  ],

                  if (widget.exercise.formCues.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text('Form Cues', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    ...widget.exercise.formCues.map((cue) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                              const SizedBox(width: 6),
                              Expanded(child: Text(cue, style: const TextStyle(fontSize: 13))),
                            ],
                          ),
                        )),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.black87),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _showAddToPlanDialog(context),
                    icon: const Icon(Icons.calendar_month, color: Colors.black87, size: 20),
                    label: const Text('Add to Plan', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _showQuickLogDialog(context),
                    icon: const Icon(Icons.check, color: Colors.white, size: 20),
                    label: const Text('Log Workout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textCol)),
    );
  }

  void _showAddToPlanDialog(BuildContext context) {
    int selectedDay = DateTime.now().weekday; // 1 = Mon .. 7 = Sun
    int sets = 3;
    int reps = 10;
    double weight = 0.0;
    int rest = 60;
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Plan for Week', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Day:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: List.generate(7, (i) {
                      final dayNum = i + 1;
                      final isSel = selectedDay == dayNum;
                      return ChoiceChip(
                        label: Text(dayNames[i]),
                        selected: isSel,
                        showCheckmark: false,
                        selectedColor: Colors.black87,
                        labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87, fontSize: 12),
                        onSelected: (_) => setDialogState(() => selectedDay = dayNum),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _stepperField('Sets', sets, (v) => setDialogState(() => sets = (sets + v).clamp(1, 20))),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _stepperField('Reps', reps, (v) => setDialogState(() => reps = (reps + v).clamp(1, 100))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _stepperField('Weight (kg)', weight.toInt(), (v) => setDialogState(() => weight = (weight + v).clamp(0.0, 500.0))),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _stepperField('Break (s)', rest, (v) => setDialogState(() => rest = (rest + (v * 15)).clamp(15, 300))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final planned = PlannedExercise(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    exerciseId: widget.exercise.id,
                    exerciseName: widget.exercise.name,
                    bodyPart: widget.exercise.bodyPart,
                    sets: sets,
                    reps: reps,
                    weightKg: weight,
                    restSeconds: rest,
                  );
                  final messenger = ScaffoldMessenger.of(context);
                  await WorkoutService().addExerciseToPlan(selectedDay, planned);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Added to ${dayNames[selectedDay - 1]}\'s plan!')),
                    );
                    widget.onLogged?.call();
                  }
                },
                child: const Text('Save to Plan', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  void _showQuickLogDialog(BuildContext context) {
    int sets = 3;
    int reps = 10;
    double weight = 0.0;
    int duration = 15;
    int calories = 90;
    bool syncHealthConnect = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Log Workout Session',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.exercise.name,
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.exercise.bodyPart.toUpperCase(),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _stepperFieldLarge('Sets', sets, '', (v) => setSheetState(() => sets = (sets + v).clamp(1, 20))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _stepperFieldLarge('Reps', reps, '', (v) => setSheetState(() => reps = (reps + v).clamp(1, 100))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _stepperFieldLarge('Weight', weight.toInt(), 'kg', (v) => setSheetState(() => weight = (weight + v).clamp(0.0, 500.0))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _stepperFieldLarge('Duration', duration, 'min', (v) => setSheetState(() => duration = (duration + v).clamp(1, 180))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _stepperFieldLarge('Est. Calories', calories, 'kcal', (v) => setSheetState(() => calories = (calories + (v * 10)).clamp(10, 2000))),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: syncHealthConnect ? Colors.green.shade50 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.favorite,
                            color: syncHealthConnect ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                        ),
                        title: const Text('Sync to Health Connect', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        subtitle: const Text('Directly write workout session to Android Health', style: TextStyle(fontSize: 11)),
                        value: syncHealthConnect,
                        activeThumbColor: Colors.black87,
                        onChanged: (v) => setSheetState(() => syncHealthConnect = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        if (ctx.mounted) Navigator.pop(ctx);
                        final log = await WorkoutService().logWorkout(
                          exerciseName: widget.exercise.name,
                          bodyPart: widget.exercise.bodyPart,
                          sets: sets,
                          reps: reps,
                          weightKg: weight,
                          durationMinutes: duration,
                          caloriesBurned: calories,
                          syncHealthConnect: syncHealthConnect,
                        );
                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                log.syncedHealthConnect
                                    ? 'Logged & synced to Health Connect!'
                                    : 'Logged locally!',
                              ),
                            ),
                          );
                          widget.onLogged?.call();
                        }
                      },
                      child: const Text('Confirm & Log Session', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _stepperFieldLarge(String label, int val, String unit, Function(int) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => onChange(-1),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(Icons.remove, size: 20, color: Colors.black87),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('$val', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 2),
                    Text(unit, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
              GestureDetector(
                onTap: () => onChange(1),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepperField(String label, int val, Function(int) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => onChange(-1),
                child: const Icon(Icons.remove_circle_outline, size: 20),
              ),
              Text('$val', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              GestureDetector(
                onTap: () => onChange(1),
                child: const Icon(Icons.add_circle_outline, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black87 : Colors.white70,
          ),
        ),
      ),
    );
  }
}
