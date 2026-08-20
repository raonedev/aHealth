import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/progress_entry.dart';

class ProgressLocalDb {
  static final ProgressLocalDb instance = ProgressLocalDb._internal();
  ProgressLocalDb._internal();


  Future<Database> get database => AppDatabase.instance.database;


  Future<void> insertEntry(ProgressEntry entry) async {
    final db = await database;
    await db.insert('progress_entries', entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateEntry(ProgressEntry entry) async {
    final db = await database;
    await db.update('progress_entries', entry.toMap(),
        where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<void> deleteEntry(String id) async {
    final db = await database;
    await db.delete('progress_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ProgressEntry>> getAllEntries() async {
    final db = await database;
    final result = await db.query('progress_entries', orderBy: 'date ASC');
    return result.map((e) => ProgressEntry.fromMap(e)).toList();
  }
}
