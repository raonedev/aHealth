import 'package:flutter/material.dart';

import 'water_chart_screen.dart';
import 'widgets/water_bar.dart';
import 'widgets/water_point.dart';
import 'widgets/water_week_summary.dart';
import 'widgets/water_week_tile.dart';
import 'widgets/week_summary.dart';

class WaterMonthlyTab extends StatelessWidget {
  final List<double> monthData;
  final bool loaded;
  const WaterMonthlyTab({super.key, required this.monthData, required this.loaded});

  List<WaterPoint> get _points {
    final now = DateTime.now();
    return List.generate(monthData.length, (i) =>
      WaterPoint(now.subtract(Duration(days: 29 - i)), monthData[i], kWaterTarget));
  }

  List<WaterWeekSummary> get _weeks {
    final pts = _points;
    final result = <WaterWeekSummary>[];
    for (int i = 0; i < pts.length; i += 7) {
      final slice = pts.sublist(i, (i + 7).clamp(0, pts.length));
      final total = slice.fold(0.0, (s, p) => s + p.liters);
      result.add(WaterWeekSummary(
        weekNum: result.length + 1,
        start: slice.first.date,
        end: slice.last.date,
        total: total,
        avg: total / slice.length,
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final pts = _points.reversed.toList();
    final total = monthData.isEmpty ? 0.0 : monthData.reduce((a, b) => a + b);
    final best = monthData.isEmpty ? 0.0 : monthData.reduce((a, b) => a > b ? a : b);
    final hit = monthData.where((l) => l >= kWaterTarget).length;

    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        WaterSummaryCards(items: [
          ('Total', '${total.toStringAsFixed(1)}L', true),
          ('Best day', '${best.toStringAsFixed(1)}L', false),
          ('Goal hit', '$hit/${monthData.length}', false),
        ]),
        if (!loaded)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(children: [
              SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF185FA5))),
              SizedBox(width: 8),
              Text('Loading monthly data...', style: TextStyle(color: Colors.grey)),
            ]),
          )
        else
          WaterBarChart(points: pts, label: 'Last 30 days'),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text('Weekly summary',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: Colors.grey[600], letterSpacing: .5)),
        ),
        ..._weeks.map((w) => WaterWeekTile(summary: w)),
        const SizedBox(height: 16),
      ],
    );
  }
}

