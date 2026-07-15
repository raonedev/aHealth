import '../entities/activity.dart';
import '../repositories/tracking_repository.dart';

class GetActivities {
  final TrackingRepository repo;
  GetActivities(this.repo);
  Future<List<Activity>> call() => repo.getActivities();
}