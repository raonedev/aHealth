import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/location_point_model.dart';
import '../models/activity_model.dart';

abstract class TrackingLocalDataSource {
  Future<void> insertPointsBatch(List<LocationPointModel> points);
  Future<void> insertActivity(ActivityModel activity);
  Future<List<ActivityModel>> getActivities();
  Future<List<LocationPointModel>> getPointsForActivity(String activityId);
}

class TrackingLocalDataSourceImpl implements TrackingLocalDataSource {
  Database? _db;

  Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'tracking.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
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
      },
    );
  }

  @override
  Future<void> insertPointsBatch(List<LocationPointModel> points) async {
    final database = await db;
    final batch = database.batch();
    for (final p in points) {
      batch.insert(
        'location_points',
        p.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> insertActivity(ActivityModel activity) async {
    final database = await db;
    await database.insert(
      'activities',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<ActivityModel>> getActivities() async {
    final database = await db;
    final maps = await database.query('activities', orderBy: 'startTime DESC');
    return maps.map((m) => ActivityModel.fromMap(m)).toList();
  }

  @override
  Future<List<LocationPointModel>> getPointsForActivity(String activityId) async {
    final database = await db;
    final maps = await database.query(
      'location_points',
      where: 'activityId = ?',
      whereArgs: [activityId],
      orderBy: 'timestamp ASC',
    );
    return maps.map((m) => LocationPointModel.fromMap(m)).toList();
  }
}