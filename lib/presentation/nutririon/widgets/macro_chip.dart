
import 'package:flutter/material.dart';

class MacroChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double value;

  const MacroChip(
      {super.key, required this.icon, required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 2),
        Text('${value.toInt()}g',
            style: const TextStyle(
                color: Color(0xFF757575),
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
