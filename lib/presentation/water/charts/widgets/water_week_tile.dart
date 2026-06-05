
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../water_chart_screen.dart';
import 'water_week_summary.dart';

class WaterWeekTile extends StatelessWidget {
  final WaterWeekSummary summary;
  const WaterWeekTile({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final hit = summary.avg >= kWaterTarget;
    final pct = (summary.avg / kWaterTarget).clamp(0.0, 1.0);
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
            color: hit ? const Color(0xFFE6F1FB) : const Color(0xFFB5D4F4).withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.calendar_view_week_rounded,
              color: hit ? const Color(0xFF185FA5) : const Color(0xFF85B7EB), size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Week ${summary.weekNum}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text('${DateFormat('dd MMM').format(summary.start)} - ${DateFormat('dd MMM').format(summary.end)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${summary.total.toStringAsFixed(1)} L',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                  color: hit ? const Color(0xFF185FA5) : const Color(0xFFA32D2D))),
          Text('avg ${summary.avg.toStringAsFixed(1)} L/day',
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