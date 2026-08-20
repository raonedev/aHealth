import '../entities/streak_entity.dart';

abstract class StreakRepository {
  Future<bool> logActivity(StreakActivityType type, {DateTime? date});
  Future<StreakEntity> getStreak();
}
