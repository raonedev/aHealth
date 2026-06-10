import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/nutrition_model.dart';
import '../presentation/nutririon/nutrition_group/models/food_scan_group_model.dart';

const _foodScanGroupBox = 'food_scan_groups';

class NutritionService {
  static const _uuid = Uuid();

  static Future<void> init() async {
    await Hive.openBox<FoodScanGroup>(_foodScanGroupBox);
  }

  /// Compress image, save to app dir, return (uuid, savedPath, base64)
  static Future<({String uuid, String imagePath, String base64})> prepareImage(
      File imageFile) async {
    final id = _uuid.v4();
    final appDir = await getApplicationDocumentsDirectory();
    final destPath = '${appDir.path}/food_scans/$id.jpg';
    await Directory('${appDir.path}/food_scans').create(recursive: true);

    final compressed = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      destPath,
      quality: 70,
      minWidth: 800,
      minHeight: 800,
    );

    if (compressed == null) throw Exception('Image compression failed');

    final bytes = await compressed.readAsBytes();
    final base64 = base64Encode(bytes);

    return (uuid: id, imagePath: destPath, base64: base64);
  }

  static Future<void> saveScanGroup({
    required String uuid,
    required String imagePath,
    required List<ValueFood> foods,
  }) async {
    final box = Hive.box<FoodScanGroup>(_foodScanGroupBox);
    final group = FoodScanGroup(
      uuid: uuid,
      imagePath: imagePath,
      timestamp: DateTime.now(),
      foods: foods.map(ValueFoodHive.fromValueFood).toList(),
    );
    await box.put(uuid, group);
    dev.log('Saved scan group: $uuid with ${foods.length} foods');
  }

  static List<FoodScanGroup> getAllGroups() {
    final box = Hive.box<FoodScanGroup>(_foodScanGroupBox);
    return box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static Future<void> deleteGroup(String uuid) async {
    final box = Hive.box<FoodScanGroup>(_foodScanGroupBox);
    await box.delete(uuid);
  }
}