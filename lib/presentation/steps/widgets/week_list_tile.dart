import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../step_chart_screen.dart';

class WeekSummary {
  final int weekNum;
  final DateTime start;
  final DateTime end;

  final double total;
  final double avg;

  WeekSummary(
      {required this.weekNum,
      required this.start,
      required this.end,
      required this.total,
      required this.avg});
}

class WeekListTile extends StatelessWidget {
  final WeekSummary summary;
  const WeekListTile({super.key, required this.summary});

  String _fmt(double v) => NumberFormat('#,###').format(v.round());

  @override
  Widget build(BuildContext context) {
    final hit = summary.avg >= kDailyTarget;
    final pct = (summary.avg / kDailyTarget).clamp(0.0, 1.0);
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: hit ? const Color(0xFFEAF3DE) : const Color(0xFFFAEEDA),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.calendar_view_week_rounded,
              color: hit ? const Color(0xFF3B6D11) : const Color(0xFF854F0B),
              size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Week ${summary.weekNum}',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(
              '${DateFormat('dd MMM').format(summary.start)} – ${DateFormat('dd MMM').format(summary.end)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(_fmt(summary.total),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3B6D11))),
          Text('avg ${_fmt(summary.avg)}/day',
              style: TextStyle(
                  fontSize: 11,
                  color: hit ? Colors.grey : const Color(0xFF854F0B))),
          const SizedBox(height: 4),
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 4,
                backgroundColor: const Color(0xFFEEEEEE),
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
