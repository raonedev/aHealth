import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // progress_photos
        await db.execute('''
          CREATE TABLE progress_entries (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            weight REAL NOT NULL,
            photoPath TEXT NOT NULL
          )
        ''');

        // step_tracking
        await db.execute('''
          CREATE TABLE activities(
            id TEXT PRIMARY KEY,
            type INTEGER,
            startTime INTEGER,
            endTime INTEGER,
            distanceMeters REAL,
            durationSeconds INTEGER,
            avgPaceSecPerKm REAL,
            calories REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE location_points(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            activityId TEXT,
            lat REAL,
            lng REAL,
            altitude REAL,
            speed REAL,
            accuracy REAL,
            timestamp INTEGER,
            FOREIGN KEY(activityId) REFERENCES activities(id)
          )
        ''');
        await db.execute('CREATE INDEX idx_points_activity ON location_points(activityId)');

        // streak
        await db.execute('''
          CREATE TABLE streak_log(
            date TEXT PRIMARY KEY,
            water_logged INTEGER DEFAULT 0,
            food_logged INTEGER DEFAULT 0,
            weight_logged INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }
}