import 'dart:io';

import 'package:geolocator/geolocator.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../datasources/tracking_local_datasource.dart';
import '../models/activity_model.dart';
import '../models/location_point_model.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingLocalDataSource local;
  TrackingRepositoryImpl(this.local);

  
@override
Stream<Position> get positionStream => Geolocator.getPositionStream(
      locationSettings: Platform.isAndroid
          ? AndroidSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
              intervalDuration: const Duration(seconds: 3),
              foregroundNotificationConfig: const ForegroundNotificationConfig(
                notificationTitle: "aHealth is tracking",
                notificationText: "Recording your route in the background",
                enableWakeLock: true,
              ),
            )
          : AppleSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
              pauseLocationUpdatesAutomatically: false,
              showBackgroundLocationIndicator: true,
            ),
    );

  @override
  Future<void> savePointsBatch(List<LocationPoint> points) => local.insertPointsBatch(
        points.map((p) => LocationPointModel.fromEntity(p)).toList(),
      );

  @override
  Future<void> saveActivity(Activity activity) =>
      local.insertActivity(ActivityModel.fromEntity(activity));

  @override
  Future<List<Activity>> getActivities() => local.getActivities();

  @override
  Future<List<LocationPoint>> getPointsForActivity(String activityId) =>
      local.getPointsForActivity(activityId);
}