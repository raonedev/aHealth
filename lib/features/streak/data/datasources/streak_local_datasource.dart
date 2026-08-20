import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/streak_entity.dart';

abstract class StreakLocalDataSource {
  Future<bool> markActivity(StreakActivityType type, {DateTime? date});
  Future<int> calculateCurrentStreak();
  Future<int> calculateLongestStreak();
}

class StreakLocalDataSourceImpl implements StreakLocalDataSource {
  Future<Database> get db => AppDatabase.instance.database;

  @override
  Future<bool> markActivity(StreakActivityType type, {DateTime? date}) async {
    final database = await db;
    final targetDate = DateFormat('yyyy-MM-dd').format(date ?? DateTime.now());
    final existing = await database
        .query('streak_log', where: 'date = ?', whereArgs: [targetDate]);
    final isFirstToday = existing.isEmpty;
    if (isFirstToday) {
      await database
          .insert('streak_log', {'date': targetDate, '${type.name}_logged': 1});
    } else {
      await database.update('streak_log', {'${type.name}_logged': 1},
          where: 'date = ?', whereArgs: [targetDate]);
    }
    return isFirstToday;
  }

  @override
  Future<int> calculateCurrentStreak() async {
    final database = await db;
    final rows = await database.query('streak_log', orderBy: 'date DESC');
    int streak = 0;
    DateTime checkDate = DateTime.now();
    for (final row in rows) {
      final expected = DateFormat('yyyy-MM-dd').format(checkDate);
      final isComplete = row['water_logged'] == 1 ||
          row['food_logged'] == 1 ||
          row['weight_logged'] == 1;
      if (row['date'] == expected && isComplete) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Future<int> calculateLongestStreak() async {
    final database = await db;
    final rows = await database.query('streak_log', orderBy: 'date ASC');
    int longest = 0, current = 0;
    DateTime? prevDate;
    for (final row in rows) {
      final isComplete = row['water_logged'] == 1 ||
          row['food_logged'] == 1 ||
          row['weight_logged'] == 1;
      final date = DateFormat('yyyy-MM-dd').parse(row['date'] as String);
      if (!isComplete) {
        current = 0;
        prevDate = null;
        continue;
      }
      if (prevDate != null && date.difference(prevDate).inDays == 1) {
        current++;
      } else {
        current = 1;
      }
      longest = current > longest ? current : longest;
      prevDate = date;
    }
    return longest;
  }
}
