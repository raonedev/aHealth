import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart' show LatLng;

class JourneyShareCard extends StatelessWidget {
  final GlobalKey repaintKey;
  final List<LatLng> points;
  final String km;
  final String time;

  const JourneyShareCard({
    super.key,
    required this.repaintKey,
    required this.points,
    required this.km,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 400,
        height: 500,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Activity',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: CustomPaint(
                painter: _PathPainter(points),
                child: Container(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('Distance', '$km km'),
                _stat('Time', time),
              ],
            ),
            Text("Tracked with OCTO.")
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      );
}

class _PathPainter extends CustomPainter {
  final List<LatLng> points;
  _PathPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final lats = points.map((p) => p.latitude).toList();
    final lngs = points.map((p) => p.longitude).toList();
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);

    final latRange = (maxLat - minLat).abs() < 1e-9 ? 1 : maxLat - minLat;
    final lngRange = (maxLng - minLng).abs() < 1e-9 ? 1 : maxLng - minLng;

    Offset toOffset(LatLng p) {
      final x = (p.longitude - minLng) / lngRange * size.width;
      final y = size.height - (p.latitude - minLat) / latRange * size.height;
      return Offset(x, y);
    }

    final path = Path();
    final start = toOffset(points.first);
    path.moveTo(start.dx, start.dy);
    for (final p in points.skip(1)) {
      final o = toOffset(p);
      path.lineTo(o.dx, o.dy);
    }

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = Colors.green;
    canvas.drawCircle(start, 6, dotPaint);
    final end = toOffset(points.last);
    canvas.drawCircle(end, 6, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) => oldDelegate.points != points;
}

Future<Uint8List> captureCardAsPng(GlobalKey key) async {
  final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}