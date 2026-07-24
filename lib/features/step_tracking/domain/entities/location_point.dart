import 'package:equatable/equatable.dart';

class LocationPoint extends Equatable {
  final int? id;
  final String activityId;
  final double lat;
  final double lng;
  final double altitude;
  final double speed;
  final double accuracy;
  final DateTime timestamp;

  const LocationPoint({
    this.id,
    required this.activityId,
    required this.lat,
    required this.lng,
    required this.altitude,
    required this.speed,
    required this.accuracy,
    required this.timestamp,
  });

  LocationPoint copyWith({int? id}) => LocationPoint(
        id: id ?? this.id,
        activityId: activityId,
        lat: lat,
        lng: lng,
        altitude: altitude,
        speed: speed,
        accuracy: accuracy,
        timestamp: timestamp,
      );

  @override
  List<Object?> get props => [id, activityId, lat, lng, altitude, speed, accuracy, timestamp];
}