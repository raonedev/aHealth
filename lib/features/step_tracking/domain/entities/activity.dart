import 'package:equatable/equatable.dart';

enum ActivityType { run, walk, cycle }

class Activity extends Equatable {
  final String id;
  final ActivityType type;
  final DateTime startTime;
  final DateTime? endTime;
  final double distanceMeters;
  final int durationSeconds;
  final double avgPaceSecPerKm;
  final double calories;

  const Activity({
    required this.id,
    required this.type,
    required this.startTime,
    this.endTime,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.avgPaceSecPerKm,
    required this.calories,
  });

  @override
  List<Object?> get props =>
      [id, type, startTime, endTime, distanceMeters, durationSeconds, avgPaceSecPerKm, calories];
}