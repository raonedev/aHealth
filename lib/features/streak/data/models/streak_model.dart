import '../../domain/entities/streak_entity.dart';

class StreakModel extends StreakEntity {
  StreakModel({required super.currentStreak, required super.longestStreak});

  factory StreakModel.fromEntity(StreakEntity entity) => StreakModel(
        currentStreak: entity.currentStreak,
        longestStreak: entity.longestStreak,
      );
}
