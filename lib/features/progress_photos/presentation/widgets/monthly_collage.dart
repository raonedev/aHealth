import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:screenshot/screenshot.dart';
import '../../domain/entities/progress_entry.dart';

class MonthlyCollage extends StatelessWidget {
  final DateTime month;
  final List<ProgressEntry> entries;
  final ScreenshotController controller;

  const MonthlyCollage({
    super.key,
    required this.month,
    required this.entries,
    required this.controller,
  });

  List<ProgressEntry> get _monthEntries => entries
      .where((e) => e.date.year == month.year && e.date.month == month.month)
      .toList();

  static Future<void> generateAndSave({
  required BuildContext context,
  required ScreenshotController controller,
}) async {
  try {
    await Future.delayed(const Duration(milliseconds: 200));
    final bytes = await controller.capture(pixelRatio: 2.0, delay: const Duration(milliseconds: 100));
    if (bytes == null) {
      dev.log("capture returned null");
      return;
    }
    await Gal.putImageBytes(bytes,
        name: 'progress_collage_${DateTime.now().millisecondsSinceEpoch}');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collage saved to gallery')),
      );
    }
  } catch (e, s) {
    dev.log("exception", error: e, stackTrace: s);
  }
}

  @override
  Widget build(BuildContext context) {
    final monthEntries = _monthEntries;
    return Screenshot(
      controller: controller,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: monthEntries.isEmpty
            ? const SizedBox(
                height: 150,
                child: Center(child: Text('No photos this month')),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: monthEntries.length,
                itemBuilder: (context, i) {
                  return Image.file(File(monthEntries[i].photoPath),
                      fit: BoxFit.cover);
                },
              ),
      ),
    );
  }
}
