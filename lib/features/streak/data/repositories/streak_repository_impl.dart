import '../../domain/entities/streak_entity.dart';
import '../../domain/repositories/streak_repository.dart';
import '../datasources/streak_local_datasource.dart';

class StreakRepositoryImpl implements StreakRepository {
  final StreakLocalDataSource localDataSource;
  StreakRepositoryImpl(this.localDataSource);

  @override
  Future<bool> logActivity(StreakActivityType type) => localDataSource.markActivity(type);

  @override
  Future<StreakEntity> getStreak() async {
    final current = await localDataSource.calculateCurrentStreak();
    final longest = await localDataSource.calculateLongestStreak();
    return StreakEntity(currentStreak: current, longestStreak: longest);
  }
}
