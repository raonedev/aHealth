import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/progress_entry.dart';

class WeightChart extends StatelessWidget {
  final List<ProgressEntry> entries;
  const WeightChart({super.key, required this.entries});

  @override
Widget build(BuildContext context) {
  if (entries.isEmpty) {
    return const SizedBox(
      height: 200,
      child: Center(child: Text('No data yet')),
    );
  }
  final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));
  final spots = <FlSpot>[
    for (int i = 0; i < sorted.length; i++) FlSpot(i.toDouble(), sorted[i].weight),
  ];
  final weights = sorted.map((e) => e.weight).toList();
  final minY = weights.reduce((a, b) => a < b ? a : b) - 2;
  final maxY = weights.reduce((a, b) => a > b ? a : b) + 2;

  return SizedBox(
    height: 220,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withValues(alpha: 0.15),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= sorted.length) return const SizedBox.shrink();
                  final d = sorted[i].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('${d.day}/${d.month}',
                        style: const TextStyle(fontSize: 10, color: Colors.black54)),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        '${s.y.toStringAsFixed(1)} kg',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ))
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF3B6D11),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 3.5,
                  color: const Color(0xFF3B6D11),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF3B6D11).withValues(alpha: 0.2),
                    const Color(0xFF3B6D11).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}}
