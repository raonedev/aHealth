import 'dart:async';
import 'dart:developer' as dev;
import 'package:geolocator/geolocator.dart' hide ActivityType;
import 'package:flutter_bloc/flutter_bloc.dart';
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
  static const int _batchSize = 10;
  static const double _accuracyThreshold = 20;

  TrackingCubit({
    required this.getLocationStream,
    required this.calculateDistance,
    required this.saveActivity,
    required this.repository,
  }) : super(TrackingIdle());

  void start() {
  Future(() async {
    final granted = await _ensureLocationPermission();
    if (!granted) {
      emit(TrackingPermissionDenied());
      return;
    }

    _activityId = const Uuid().v4();
    _points.clear();
    _distance = 0;
    _elapsed = Duration.zero;
    _startTime = DateTime.now();

    _sub = getLocationStream().listen(_onPosition, onError: (_) {});
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = DateTime.now().difference(_startTime!);
      _emitActive();
    });

    emit(TrackingActive(points: const [], distanceMeters: 0, elapsed: Duration.zero));
  });
}

Future<bool> _ensureLocationPermission() async {
  if (!await Geolocator.isLocationServiceEnabled()) return false;
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
}

  void _onPosition(Position pos) {
    if (pos.accuracy > _accuracyThreshold) return;

    dev.log("lat ${pos.latitude} long ${pos.longitude} alt ${pos.altitude}");
    

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

    if (_points.length % _batchSize == 0) {
      repository.savePointsBatch(_points.sublist(_points.length - _batchSize));
    }

    _emitActive();
  }

  void _emitActive() {
    if (state is TrackingPaused) return;
    emit(TrackingActive(points: List.unmodifiable(_points), distanceMeters: _distance, elapsed: _elapsed));
  }

  void pause() {
    _sub?.pause();
    _timer?.cancel();
    emit(TrackingPaused(points: List.unmodifiable(_points), distanceMeters: _distance, elapsed: _elapsed));
  }

  void resume() {
    if (_sub == null) return;
    _sub!.resume();
    final resumedAt = DateTime.now().subtract(_elapsed);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = DateTime.now().difference(resumedAt);
      _emitActive();
    });
    emit(TrackingActive(points: List.unmodifiable(_points), distanceMeters: _distance, elapsed: _elapsed));
  }

  Future<void> stop({required ActivityType type, required double calories}) async {
    _sub?.cancel();
    _timer?.cancel();

    final remainder = _points.length % _batchSize;
    if (remainder != 0) {
      await repository.savePointsBatch(_points.sublist(_points.length - remainder));
    }

    final activity = Activity(
      id: _activityId,
      type: type,
      startTime: _startTime!,
      endTime: DateTime.now(),
      distanceMeters: _distance,
      durationSeconds: _elapsed.inSeconds,
      avgPaceSecPerKm: _distance <= 0 ? 0 : _elapsed.inSeconds / (_distance / 1000),
      calories: calories,
    );
    await saveActivity(activity);

    emit(TrackingCompleted(activity: activity, points: List.unmodifiable(_points)));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _timer?.cancel();
    return super.close();
  }
}