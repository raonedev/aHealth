import 'dart:io';
import 'package:live_activities/live_activities.dart';

class LiveTracking {
  static const _group = 'group.dev.raone.ahealth';
  static final _la = LiveActivities();
  static bool _inited = false;
  static bool _creating = false;
  static String? _actId;

  static String _fmt(Duration d) {
    final h = d.inHours;
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '${d.inMinutes}:$s';
  }

  static Future<void> show({
    required String text,
    required Duration elapsed,
    bool running = true,
  }) async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    try {
      if (!_inited) {
        await _la.init(appGroupId: _group);
        _inited = true;
      }
      if (!await _la.areActivitiesEnabled()) return;
      final data = <String, dynamic>{
        'title': running ? 'aHealth is tracking' : 'Tracking paused',
        'distance': text,
        'elapsedText': _fmt(elapsed),
        'startMs': DateTime.now()
            .subtract(elapsed)
            .millisecondsSinceEpoch
            .toDouble(),
        'running': running,
      };
      if (_actId == null) {
        if (_creating) return;
        _creating = true;
        try {
          final id = 'tracking_${DateTime.now().millisecondsSinceEpoch}';
          _actId = await _la.createActivity(id, data);
        } finally {
          _creating = false;
        }
      } else {
        await _la.updateActivity(_actId!, data);
      }
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      if (_actId != null) await _la.endActivity(_actId!);
    } catch (_) {}
    _actId = null;
  }
}
