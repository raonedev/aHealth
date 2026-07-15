import 'package:geolocator/geolocator.dart';
import '../entities/activity.dart';
import '../entities/location_point.dart';

abstract class TrackingRepository {
  Stream<Position> get positionStream;
  Future<void> savePointsBatch(List<LocationPoint> points);
  Future<void> saveActivity(Activity activity);
  Future<List<Activity>> getActivities();
  Future<List<LocationPoint>> getPointsForActivity(String activityId);
}