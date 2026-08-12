import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../domain/entities/progress_entry.dart';
import 'progress_local_db.dart';

class ProgressRepository {
  final ProgressLocalDb _localDb = ProgressLocalDb.instance;
  final _uuid = const Uuid();

  Future<List<ProgressEntry>> getEntries() => _localDb.getAllEntries();

  /// Copies picked image into app's documents/progress_photos dir and saves record.
  Future<ProgressEntry> addEntry({
    required DateTime date,
    required double weight,
    required File pickedImage,
  }) async {
    final savedPath = await _saveImageLocally(pickedImage);
    final entry = ProgressEntry(
      id: _uuid.v4(),
      date: date,
      weight: weight,
      photoPath: savedPath,
    );
    await _localDb.insertEntry(entry);
    return entry;
  }

  Future<ProgressEntry> updateEntry({
    required ProgressEntry existing,
    required DateTime date,
    required double weight,
    File? newPickedImage,
  }) async {
    String photoPath = existing.photoPath;
    if (newPickedImage != null) {
      await _deleteFileIfExists(existing.photoPath);
      photoPath = await _saveImageLocally(newPickedImage);
    }
    final updated = existing.copyWith(date: date, weight: weight, photoPath: photoPath);
    await _localDb.updateEntry(updated);
    return updated;
  }

  Future<void> deleteEntry(ProgressEntry entry) async {
    await _deleteFileIfExists(entry.photoPath);
    await _localDb.deleteEntry(entry.id);
  }

  Future<String> _saveImageLocally(File image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final progressDir = Directory(p.join(appDir.path, 'progress_photos'));
    if (!await progressDir.exists()) {
      await progressDir.create(recursive: true);
    }
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
    final savedFile = await image.copy(p.join(progressDir.path, fileName));
    return savedFile.path;
  }

  Future<void> _deleteFileIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
