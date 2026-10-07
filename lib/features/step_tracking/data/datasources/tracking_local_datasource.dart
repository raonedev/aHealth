import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../models/location_point_model.dart';
import '../models/activity_model.dart';

abstract class TrackingLocalDataSource {
  Future<void> insertPoint(LocationPointModel point);
  Future<void> insertPointsBatch(List<LocationPointModel> points);
  Future<void> insertActivity(ActivityModel activity);
  Future<List<ActivityModel>> getActivities();
  Future<List<LocationPointModel>> getPointsForActivity(String activityId);
}

class TrackingLocalDataSourceImpl implements TrackingLocalDataSource {
  Future<Database> get db => AppDatabase.instance.database;

  @override
  Future<void> insertPoint(LocationPointModel point) async {
    final database = await db;
    await database.insert(
      'location_points',
      point.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
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