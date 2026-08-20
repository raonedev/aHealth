class StreakEntity {
  final int currentStreak;
  final int longestStreak;

  StreakEntity({required this.currentStreak, required this.longestStreak});
}
enum StreakActivityType { water, food, weight }