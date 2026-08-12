import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/progress_entry.dart';

class ProgressLocalDb {
  static final ProgressLocalDb instance = ProgressLocalDb._internal();
  ProgressLocalDb._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'progress_photos.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE progress_entries (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            weight REAL NOT NULL,
            photoPath TEXT NOT NULL
          )
        ''');
      },
    );
  }

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
