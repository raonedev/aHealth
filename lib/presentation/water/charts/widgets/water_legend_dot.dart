
import 'package:flutter/material.dart';

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;
  const LegendDot({super.key, required this.color, required this.label, this.dashed = false});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 14, height: 3,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ]);
  }
}