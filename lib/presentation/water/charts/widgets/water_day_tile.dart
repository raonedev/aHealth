import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'water_point.dart';

class WaterDayTile extends StatelessWidget {
  final WaterPoint point;
  const WaterDayTile({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    final hit = point.liters >= point.target;
    final pct = (point.liters / point.target).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: hit ? const Color(0xFFE6F1FB) : const Color(0xFFB5D4F4).withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.water_drop_rounded,
              color: hit ? const Color(0xFF185FA5) : const Color(0xFF85B7EB), size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(DateFormat('EEEE').format(point.date),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(DateFormat('dd MMM').format(point.date),
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${point.liters.toStringAsFixed(2)} L',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                  color: hit ? const Color(0xFF185FA5) : const Color(0xFFA32D2D))),
          Text('${(pct * 100).round()}% of goal',
              style: TextStyle(fontSize: 11,
                  color: hit ? Colors.grey : const Color(0xFFA32D2D))),
          const SizedBox(height: 4),
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: pct, minHeight: 4,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: AlwaysStoppedAnimation(
                    hit ? const Color(0xFF185FA5) : const Color(0xFF85B7EB)),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}
