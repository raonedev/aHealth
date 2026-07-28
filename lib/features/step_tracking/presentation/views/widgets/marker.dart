import 'dart:math' as math;

import 'package:flutter/material.dart';

class RunnerMarker extends StatelessWidget {
  const RunnerMarker({super.key, required this.isMoving, required this.heading});

  final bool isMoving;
  final double heading;

  @override
  Widget build(BuildContext context) {
    final color = isMoving ? Colors.blue : Colors.grey;

    return SizedBox(
      width: 40,
      height: 50,
      child: CustomPaint(
        painter: _PinPainter(color: color),
        child: Center(
          heightFactor: 0.65,
          child: isMoving
              ? Transform.rotate(
                  angle: heading * math.pi / 180,
                  child: const Icon(
                    Icons.navigation_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                )
              : Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xE6FFFFFF),
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  _PinPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final headRadius = w / 2;
    final headCenter = Offset(w / 2, headRadius);

    final path = Path()
      ..moveTo(w / 2, h)
      ..lineTo(w * 0.22, headRadius * 1.15)
      ..arcToPoint(
        Offset(w * 0.78, headRadius * 1.15),
        radius: Radius.circular(headRadius),
        clockwise: true,
        largeArc: true,
      )
      ..close();

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(path.shift(const Offset(0, 1)), shadowPaint);

    final fillPaint = Paint()..color = color;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, borderPaint);

    canvas.drawCircle(headCenter, headRadius - 1, fillPaint);
    canvas.drawCircle(headCenter, headRadius - 1, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PinPainter oldPainter) => oldPainter.color != color;
}