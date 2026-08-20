import '../entities/streak_entity.dart';
import '../repositories/streak_repository.dart';

class LogActivityUsecase {
  final StreakRepository repository;
  LogActivityUsecase(this.repository);

  Future<bool> call(StreakActivityType type) => repository.logActivity(type);
}
