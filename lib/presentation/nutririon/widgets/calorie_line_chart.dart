import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../blocs/charts/calorie_chart/calorie_point.dart';
import '../../steps/widgets/legend_dot.dart';

class CalorieLineChart extends StatelessWidget {
  final List<CaloriePoint> points;
  final String label;
  const CalorieLineChart(
      {super.key, required this.points, required this.label});

  static const _consumedColor = Color(0xFF639922);
  static const _targetColor = Color(0xFFEF9F27);
  static const _tdeeColor = Color(0xFF5299E0);

  String _fmt(double v) => NumberFormat('#,###').format(v.round());

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          SizedBox(
            height: 220,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat('EEE'),
                intervalType: DateTimeIntervalType.days,
                interval: 1,
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                axisLabelFormatter: (details) => ChartAxisLabel(
                  '${(details.value / 1000).toStringAsFixed(1)}k',
                  const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                majorGridLines:
                    const MajorGridLines(width: 0.5, color: Color(0xFFEEEEEE)),
                axisLine: const AxisLine(width: 0),
              ),
              trackballBehavior: TrackballBehavior(
                enable: true,
                activationMode: ActivationMode.singleTap,
                tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
                tooltipSettings: const InteractiveTooltip(enable: false),
                lineType: TrackballLineType.vertical,
                lineColor: _consumedColor,
                lineDashArray: const [4, 2],
                markerSettings: const TrackballMarkerSettings(
                  markerVisibility: TrackballVisibilityMode.visible,
                  height: 8,
                  width: 8,
                  borderWidth: 2,
                  borderColor: Colors.white,
                ),
                builder: (context, trackballDetails) {
                  final grp = trackballDetails.groupingModeInfo;
                  if (grp == null) return const SizedBox();
                  final pts = grp.points;
                  final date =
                      pts.isNotEmpty ? pts[0].x as DateTime : DateTime.now();
                  double val(int i) => pts.length > i ? pts[i].y as double : 0;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('EEE, dd MMM').format(date),
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      _tip('Consumed: ${_fmt(val(0))}', _consumedColor),
                      const SizedBox(height: 4),
                      _tip('Target: ${_fmt(val(1))}', _targetColor),
                      const SizedBox(height: 4),
                      _tip('TDEE: ${_fmt(val(2))}', _tdeeColor),
                    ],
                  );
                },
              ),
              series: <CartesianSeries>[
                SplineAreaSeries<CaloriePoint, DateTime>(
                  dataSource: points,
                  xValueMapper: (p, _) =>
                      DateTime(p.date.year, p.date.month, p.date.day),
                  yValueMapper: (p, _) => p.consumed,
                  color: _consumedColor,
                  opacity: 0.1,
                  borderColor: _consumedColor,
                  borderWidth: 2,
                  splineType: SplineType.natural,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    height: 6,
                    width: 6,
                    borderWidth: 1.5,
                    borderColor: Colors.white,
                    color: _consumedColor,
                    shape: DataMarkerType.circle,
                  ),
                ),
                LineSeries<CaloriePoint, DateTime>(
                  dataSource: points,
                  xValueMapper: (p, _) =>
                      DateTime(p.date.year, p.date.month, p.date.day),
                  yValueMapper: (p, _) => p.target,
                  color: _targetColor,
                  width: 1.5,
                  dashArray: const [5, 3],
                  enableTooltip: false,
                  markerSettings: const MarkerSettings(isVisible: false),
                ),
                LineSeries<CaloriePoint, DateTime>(
                  dataSource: points,
                  xValueMapper: (p, _) =>
                      DateTime(p.date.year, p.date.month, p.date.day),
                  yValueMapper: (p, _) => p.tdee,
                  color: _tdeeColor,
                  width: 1.5,
                  dashArray: const [2, 2],
                  enableTooltip: false,
                  markerSettings: const MarkerSettings(isVisible: false),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 4, 0, 4),
            child: Wrap(spacing: 16, runSpacing: 4, children: [
              LegendDot(color: _consumedColor, label: 'Consumed'),
              LegendDot(color: _targetColor, label: 'Target', dashed: true),
              LegendDot(color: _tdeeColor, label: 'TDEE', dashed: true),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _tip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      );
}