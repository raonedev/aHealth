import '../../domain/entities/activity.dart';

class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.type,
    required super.startTime,
    super.endTime,
    required super.distanceMeters,
    required super.durationSeconds,
    required super.avgPaceSecPerKm,
    required super.calories,
  });

  factory ActivityModel.fromEntity(Activity e) => ActivityModel(
        id: e.id,
        type: e.type,
        startTime: e.startTime,
        endTime: e.endTime,
        distanceMeters: e.distanceMeters,
        durationSeconds: e.durationSeconds,
        avgPaceSecPerKm: e.avgPaceSecPerKm,
        calories: e.calories,
      );

  factory ActivityModel.fromMap(Map<String, dynamic> map) => ActivityModel(
        id: map['id'] as String,
        type: ActivityType.values[map['type'] as int],
        startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
        endTime: map['endTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int)
            : null,
        distanceMeters: map['distanceMeters'] as double,
        durationSeconds: map['durationSeconds'] as int,
        avgPaceSecPerKm: map['avgPaceSecPerKm'] as double,
        calories: map['calories'] as double,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.index,
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime?.millisecondsSinceEpoch,
        'distanceMeters': distanceMeters,
        'durationSeconds': durationSeconds,
        'avgPaceSecPerKm': avgPaceSecPerKm,
        'calories': calories,
      };
}