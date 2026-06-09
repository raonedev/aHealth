import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'step_chart_screen.dart';
import 'widgets/day_list_tile.dart';
import 'widgets/step_line_chart.dart';
import 'widgets/step_point.dart';
import 'widgets/summary_cards.dart';

class WeeklyTab extends StatelessWidget {
  final List<double> weekData;
  const WeeklyTab({super.key, required this.weekData});

  List<StepPoint> get _points {
    final now = DateTime.now();
    return List.generate(weekData.length, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return StepPoint(date, weekData[i], kDailyTarget);
    });
  }
  
  String _fmt(double v) => NumberFormat('#,###').format(v.round());

  @override
  Widget build(BuildContext context) {
    final pts = _points;
    final today = pts.isNotEmpty ? pts.last : null;
    final double avg = weekData.isEmpty ? 0 : weekData.reduce((a, b) => a + b) / weekData.length;
    final hit = weekData.where((s) => s >= kDailyTarget).length;

    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        SummaryCards(
          items: [
            ('Today', today != null ? _fmt(today.steps) : '-', true),
            ('Avg/day', _fmt(avg), false),
            ('Goal hit', '$hit/${weekData.length}', false),
          ],
        ),
        StepLineChart(points: pts, label: 'Last 7 days'),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('Daily breakdown',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: Colors.grey[600], letterSpacing: .5)),
        ),
        const SizedBox(height: 8),
         ...pts.reversed.map((p) => DayListTile(point: p)),
        const SizedBox(height: 16),
      ],
    );
  }
}