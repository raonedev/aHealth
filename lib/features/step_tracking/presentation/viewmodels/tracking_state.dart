import 'package:equatable/equatable.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/location_point.dart';

abstract class TrackingState extends Equatable {
  const TrackingState();
  @override
  List<Object?> get props => [];
}

class TrackingIdle extends TrackingState {}

class TrackingActive extends TrackingState {
  final List<LocationPoint> points;
  final double distanceMeters;
  final Duration elapsed;

  const TrackingActive({
    required this.points,
    required this.distanceMeters,
    required this.elapsed,
  });

  double get paceSecPerKm =>
      distanceMeters <= 0 ? 0 : elapsed.inSeconds / (distanceMeters / 1000);

  @override
  List<Object?> get props => [points, distanceMeters, elapsed];
}

class TrackingPaused extends TrackingActive {
  const TrackingPaused({
    required super.points,
    required super.distanceMeters,
    required super.elapsed,
  });
}

class TrackingCompleted extends TrackingState {
  final Activity activity;
  final List<LocationPoint> points;
  const TrackingCompleted({required this.activity, required this.points});

  @override
  List<Object?> get props => [activity, points];
}
class TrackingPermissionDenied extends TrackingState {

  @override
  List<Object?> get props => [];
}