import '../entities/streak_entity.dart';
import '../repositories/streak_repository.dart';

class GetStreakUsecase {
  final StreakRepository repository;
  GetStreakUsecase(this.repository);

  Future<StreakEntity> call() => repository.getStreak();
}
