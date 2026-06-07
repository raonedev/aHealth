import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'step_chart_screen.dart';
import 'widgets/step_line_chart.dart';
import 'widgets/step_point.dart';
import 'widgets/summary_cards.dart';
import 'widgets/week_list_tile.dart';

class MonthlyTab extends StatelessWidget {
  final List<double> monthData;
  final bool loaded;
  const MonthlyTab({super.key, required this.monthData, required this.loaded});

  List<StepPoint> get _points {
    final now = DateTime.now();
    return List.generate(monthData.length, (i) {
      final date = now.subtract(Duration(days: 29 - i));
      return StepPoint(date, monthData[i], kDailyTarget);
    });
  }

  List<WeekSummary> get _weekSummaries {
    final pts = _points.reversed.toList();
    final weeks = <WeekSummary>[];
    for (int i = 0; i < pts.length; i += 7) {
      final slice = pts.sublist(i, (i + 7).clamp(0, pts.length));
      final total = slice.fold(0.0, (s, p) => s + p.steps);
      weeks.add(WeekSummary(
        weekNum: weeks.length + 1,
        start: slice.first.date,
        end: slice.last.date,
        total: total,
        avg: total / slice.length,
      ));
    }
    return weeks;
  }
  
  String _fmt(double v) => NumberFormat('#,###').format(v.round());
  
  String _fmtK(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}K' : _fmt(v);

  @override
  Widget build(BuildContext context) {
    final pts = _points;
    final total = monthData.isEmpty ? 0.0 : monthData.reduce((a, b) => a + b);
    final best = monthData.isEmpty ? 0.0 : monthData.reduce((a, b) => a > b ? a : b);
    final hit = monthData.where((s) => s >= kDailyTarget).length;

    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        SummaryCards(
          items: [
            ('Total', _fmtK(total), true),
            ('Best day', _fmt(best), false),
            ('Goal hit', '$hit/${monthData.length}', false),
          ],
        ),
        if (!loaded)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(children: [
              SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B6D11))),
              SizedBox(width: 8),
              Text('Loading monthly data...', style: TextStyle(color: Colors.grey)),
            ]),
          )
        else
          StepLineChart(points: pts, label: 'Last 30 days'),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('Weekly summary',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: Colors.grey[600], letterSpacing: .5)),
        ),
        const SizedBox(height: 8),
        ..._weekSummaries.map((w) => WeekListTile(summary: w)),
        const SizedBox(height: 16),
      ],
    );
  }
}