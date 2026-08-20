import '../entities/streak_entity.dart';
import '../repositories/streak_repository.dart';

class LogActivityUsecase {
  final StreakRepository repository;
  LogActivityUsecase(this.repository);

  Future<bool> call(StreakActivityType type, {DateTime? date}) =>
      repository.logActivity(type, date: date);
}
