import '../entities/activity.dart';
import '../repositories/tracking_repository.dart';

class SaveActivity {
  final TrackingRepository repo;
  SaveActivity(this.repo);
  Future<void> call(Activity activity) => repo.saveActivity(activity);
}