import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/usecases/get_location_stream.dart';
import '../../domain/usecases/calculate_distance.dart';
import '../../domain/usecases/save_activity.dart';
import '../../domain/repositories/tracking_repository.dart';
import 'tracking_state.dart';

class TrackingCubit extends Cubit<TrackingState> {
  final GetLocationStream getLocationStream;
  final CalculateDistance calculateDistance;
  final SaveActivity saveActivity;
  final TrackingRepository repository;

  StreamSubscription<Position>? _sub;
  Timer? _timer;
  final List<LocationPoint> _points = [];
  double _distance = 0;
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;
  String _activityId = '';
  ActivityType _currentType = ActivityType.run;
  static const double _accuracyThreshold = 20;

  TrackingCubit({
    required this.getLocationStream,
    required this.calculateDistance,
    required this.saveActivity,
    required this.repository,
  }) : super(TrackingIdle());

  void start({ActivityType type = ActivityType.run}) {
    Future(() async {
      final granted = await _ensureLocationPermission();
      if (!granted) {
        emit(TrackingPermissionDenied());
        return;
      }

      _activityId = const Uuid().v4();
      _currentType = type;
      _points.clear();
      _distance = 0;
      _elapsed = Duration.zero;
      _startTime = DateTime.now();

      // Create session in database immediately
      final initialActivity = Activity(
        id: _activityId,
        type: _currentType,
        startTime: _startTime!,
        endTime: null,
        distanceMeters: 0,
        durationSeconds: 0,
        avgPaceSecPerKm: 0,
        calories: 0,
      );
      await saveActivity(initialActivity);

      _sub = getLocationStream().listen(_onPosition, onError: (_) {});
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _elapsed = DateTime.now().difference(_startTime!);
        _emitActive();
      });

      emit(
        TrackingActive(
          points: const [],
          distanceMeters: 0,
          elapsed: Duration.zero,
        ),
      );
    });
  }

  Future<bool> _ensureLocationPermission() async {
    if (Platform.isAndroid) await Permission.notification.request();
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<List<Activity>> getHistory() => repository.getActivities();

  void _onPosition(Position pos) {
    if (pos.accuracy > _accuracyThreshold) return;

    dev.log(
      "lat ${pos.latitude} long ${pos.longitude} alt ${pos.altitude} speed ${pos.speed}",
    );

    final point = LocationPoint(
      activityId: _activityId,
      lat: pos.latitude,
      lng: pos.longitude,
      altitude: pos.altitude,
      speed: pos.speed,
      accuracy: pos.accuracy,
      timestamp: DateTime.now(),
    );

    if (_points.isNotEmpty) {
      _distance += calculateDistance(_points.last, point);
    }
    _points.add(point);

    // Save data for this session at each interval and update the ongoing session path
    _saveIntervalData(point);

    _emitActive();
  }

  Future<void> _saveIntervalData(LocationPoint point) async {
    try {
      await repository.savePoint(point);
      await _syncActiveSession();
    } catch (e, st) {
      dev.log("Error saving tracking interval data: $e", stackTrace: st);
    }
  }

  Future<void> _syncActiveSession() async {
    if (_startTime == null || _activityId.isEmpty) return;
    final currentActivity = Activity(
      id: _activityId,
      type: _currentType,
      startTime: _startTime!,
      endTime: null, // Still active / not stopped
      distanceMeters: _distance,
      durationSeconds: _elapsed.inSeconds,
      avgPaceSecPerKm: _distance <= 0
          ? 0
          : _elapsed.inSeconds / (_distance / 1000),
      calories: _estimateCalories(_distance, _elapsed.inSeconds),
    );
    await saveActivity(currentActivity);
  }

  double _estimateCalories(double distanceMeters, int durationSeconds) {
    return (distanceMeters / 1000) * 60;
  }

  void _emitActive() {
    if (state is TrackingPaused) return;
    emit(
      TrackingActive(
        points: List.unmodifiable(_points),
        distanceMeters: _distance,
        elapsed: _elapsed,
      ),
    );
  }

  void pause() {
    _sub?.pause();
    _timer?.cancel();
    _syncActiveSession();
    emit(
      TrackingPaused(
        points: List.unmodifiable(_points),
        distanceMeters: _distance,
        elapsed: _elapsed,
      ),
    );
  }

  void resume() {
    if (_sub == null) return;
    _sub!.resume();
    final resumedAt = DateTime.now().subtract(_elapsed);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = DateTime.now().difference(resumedAt);
      _emitActive();
    });
    emit(
      TrackingActive(
        points: List.unmodifiable(_points),
        distanceMeters: _distance,
        elapsed: _elapsed,
      ),
    );
  }

  Future<void> stop({
    required ActivityType type,
    required double calories,
  }) async {
    _sub?.cancel();
    _timer?.cancel();

    _currentType = type;
    final finalCalories = calories > 0
        ? calories
        : _estimateCalories(_distance, _elapsed.inSeconds);

    final activity = Activity(
      id: _activityId,
      type: _currentType,
      startTime: _startTime ?? DateTime.now(),
      endTime: DateTime.now(),
      distanceMeters: _distance,
      durationSeconds: _elapsed.inSeconds,
      avgPaceSecPerKm: _distance <= 0
          ? 0
          : _elapsed.inSeconds / (_distance / 1000),
      calories: finalCalories,
    );
    await saveActivity(activity);

    emit(
      TrackingCompleted(activity: activity, points: List.unmodifiable(_points)),
    );
  }

  void reset() => emit(TrackingIdle());

  @override
  Future<void> close() {
    _sub?.cancel();
    _timer?.cancel();
    return super.close();
  }
}
