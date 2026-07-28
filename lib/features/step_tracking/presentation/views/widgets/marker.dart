import 'dart:math' as math;

import 'package:flutter/material.dart';

class RunnerMarker extends StatelessWidget {
  const RunnerMarker({super.key, required this.isMoving, required this.heading});

  final bool isMoving;
  final double heading;

  @override
  Widget build(BuildContext context) {
    final color = isMoving ? Colors.blue : Colors.grey;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: isMoving
          ? Transform.rotate(
              angle: heading * math.pi / 180,
              child: const Icon(
                Icons.navigation_rounded,
                size: 10,
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
    );
  }
}