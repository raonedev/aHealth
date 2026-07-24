import 'package:flutter/material.dart';

class CircularProgress extends StatelessWidget {
  final double value;
  final Color color;
  final double size;
  final IconData icon;
  final Color iconColor;

  const CircularProgress({super.key,
    required this.value,
    required this.color,
    required this.size,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 5,
            // Slightly thinner track looks cleaner on light theme
            backgroundColor: Colors.grey.shade200,
            // Light track color
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Icon(icon, color: iconColor, size: size * 0.35),
        ],
      ),
    );
  }
}