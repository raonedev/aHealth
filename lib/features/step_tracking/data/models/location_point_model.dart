import '../../domain/entities/location_point.dart';

class LocationPointModel extends LocationPoint {
  const LocationPointModel({
    super.id,
    required super.activityId,
    required super.lat,
    required super.lng,
    required super.altitude,
    required super.speed,
    required super.accuracy,
    required super.timestamp,
  });

  factory LocationPointModel.fromEntity(LocationPoint e) => LocationPointModel(
        id: e.id,
        activityId: e.activityId,
        lat: e.lat,
        lng: e.lng,
        altitude: e.altitude,
        speed: e.speed,
        accuracy: e.accuracy,
        timestamp: e.timestamp,
      );

  factory LocationPointModel.fromMap(Map<String, dynamic> map) => LocationPointModel(
        id: map['id'] as int?,
        activityId: map['activityId'] as String,
        lat: map['lat'] as double,
        lng: map['lng'] as double,
        altitude: map['altitude'] as double,
        speed: map['speed'] as double,
        accuracy: map['accuracy'] as double,
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'activityId': activityId,
        'lat': lat,
        'lng': lng,
        'altitude': altitude,
        'speed': speed,
        'accuracy': accuracy,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };
}