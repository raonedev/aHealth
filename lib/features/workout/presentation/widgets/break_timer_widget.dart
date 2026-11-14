import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BreakTimerWidget extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback? onComplete;

  const BreakTimerWidget({
    super.key,
    this.initialSeconds = 60,
    this.onComplete,
  });

  static Future<void> show(BuildContext context, {int initialSeconds = 60}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: BreakTimerWidget(initialSeconds: initialSeconds),
      ),
    );
  }

  @override
  State<BreakTimerWidget> createState() => _BreakTimerWidgetState();
}

class _BreakTimerWidgetState extends State<BreakTimerWidget> {
  late int _totalSeconds;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.initialSeconds;
    _remainingSeconds = widget.initialSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _isRunning = true);
    HapticFeedback.lightImpact();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        HapticFeedback.heavyImpact();
        widget.onComplete?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Break finished! Ready for next set! 💪'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
    HapticFeedback.lightImpact();
  }

  void _resetTimer([int? newTotal]) {
    _timer?.cancel();
    setState(() {
      if (newTotal != null) _totalSeconds = newTotal;
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
    });
    HapticFeedback.selectionClick();
  }

  void _adjustSeconds(int delta) {
    setState(() {
      final updated = (_remainingSeconds + delta).clamp(5, 600);
      _remainingSeconds = updated;
      if (!_isRunning) _totalSeconds = updated;
    });
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0 ? (_remainingSeconds / _totalSeconds) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 20, color: Colors.black87),
                  const SizedBox(width: 6),
                  const Text('Break Timer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
              Row(
                children: [
                  _presetChip(30),
                  const SizedBox(width: 4),
                  _presetChip(60),
                  const SizedBox(width: 4),
                  _presetChip(90),
                  const SizedBox(width: 4),
                  _presetChip(120),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 24),
                  onPressed: () => _adjustSeconds(-15),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 84,
                  child: Text(
                    _formatTime(_remainingSeconds),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: _remainingSeconds <= 5 && _isRunning ? Colors.red : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 24),
                  onPressed: () => _adjustSeconds(15),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning ? Colors.amber.shade700 : Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: 18, color: Colors.white),
                  label: Text(_isRunning ? 'Pause' : 'Start', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => _resetTimer(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                _remainingSeconds <= 5 ? Colors.red : Colors.blue.shade600,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetChip(int seconds) {
    final isSelected = _totalSeconds == seconds;
    return GestureDetector(
      onTap: () => _resetTimer(seconds),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${seconds}s',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
