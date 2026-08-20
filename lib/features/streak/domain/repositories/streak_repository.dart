import '../entities/streak_entity.dart';

abstract class StreakRepository {
  Future<void> logActivity(StreakActivityType type);
  Future<StreakEntity> getStreak();
}
