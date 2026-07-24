import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'step_point.dart';

class DayListTile extends StatelessWidget {
  final StepPoint point;
  const DayListTile({super.key, required this.point});
  String _fmt(double v) => NumberFormat('#,###').format(v.round());
  @override
  Widget build(BuildContext context) {
    final hit = point.steps >= point.target;
    final pct = (point.steps / point.target).clamp(0.0, 1.0);
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
            color: hit ? const Color(0xFFEAF3DE) : const Color(0xFFFAEEDA),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.directions_walk_rounded,
              color: hit ? const Color(0xFF3B6D11) : const Color(0xFF854F0B), size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(DateFormat('EEEE').format(point.date),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(DateFormat('dd MMM').format(point.date),
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(_fmt(point.steps),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                  color: Color(0xFF3B6D11))),
          Text('${(pct * 100).round()}% of goal',
              style: TextStyle(fontSize: 11,
                  color: hit ? Colors.grey : const Color(0xFF854F0B))),
          const SizedBox(height: 4),
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: pct, minHeight: 4, backgroundColor: const Color(0xFFEEEEEE),
                valueColor: AlwaysStoppedAnimation(
                    hit ? const Color(0xFF639922) : const Color(0xFFEF9F27)),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}
