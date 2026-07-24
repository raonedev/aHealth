import 'package:ahealth/presentation/water/charts/water_chart_screen.dart';
import 'package:flutter/material.dart';

import 'widgets/water_bar.dart';
import 'widgets/water_day_tile.dart';
import 'widgets/water_point.dart';
import 'widgets/week_summary.dart';

class WaterWeeklyTab extends StatelessWidget {
  final List<double> weekData;
  const WaterWeeklyTab({super.key, required this.weekData});

  List<WaterPoint> get _points {
    final now = DateTime.now();
    return List.generate(weekData.length, (i) =>
      WaterPoint(now.subtract(Duration(days: 6 - i)), weekData[i], kWaterTarget));
  }

  @override
  Widget build(BuildContext context) {
    final pts = _points.reversed.toList();
    final today = pts.isNotEmpty ? pts.last.liters : 0.0;
    final avg = weekData.isEmpty ? 0.0 : weekData.reduce((a, b) => a + b) / weekData.length;
    final hit = weekData.where((l) => l >= kWaterTarget).length;

    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        WaterSummaryCards(items: [
          ('Today', '${today.toStringAsFixed(1)}L', true),
          ('Avg/day', '${avg.toStringAsFixed(1)}L', false),
          ('Goal hit', '$hit/${weekData.length}', false),
        ]),
        WaterBarChart(points: pts, label: 'Last 7 days'),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text('Daily breakdown',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: Colors.grey[600], letterSpacing: .5)),
        ),
        ...pts.map((p) => WaterDayTile(point: p)),
        const SizedBox(height: 16),
      ],
    );
  }
}