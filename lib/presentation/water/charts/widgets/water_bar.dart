import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../steps/widgets/legend_dot.dart';
import '../water_chart_screen.dart';
import 'water_point.dart';

class WaterBarChart extends StatefulWidget {
  final List<WaterPoint> points;
  final String label;
  const WaterBarChart({super.key, required this.points, required this.label});
  @override
  State<WaterBarChart> createState() => _WaterBarChartState();
}

class _WaterBarChartState extends State<WaterBarChart> {
  late final TrackballBehavior _trackball;

  @override
  void initState() {
    super.initState();
    _trackball = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      shouldAlwaysShow: false,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
      tooltipSettings: const InteractiveTooltip(enable: false),
      lineType: TrackballLineType.vertical,
      lineWidth: 1,
      lineColor: Colors.grey.withValues(alpha: 0.4),
      lineDashArray: const [4, 2],
      builder: (context, details) {
        final info = details.groupingModeInfo;
        if (info == null || info.points.isEmpty) return const SizedBox();
        final pts = info.points;
        final liters = pts.length > 1
            ? (pts[1].y as num).toDouble()
            : (pts[0].y as num).toDouble();
        final target = kWaterTarget;
        final date = pts[0].x as DateTime;
        final hit = liters >= target;

        return IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C2A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Text(
                  DateFormat('EEE, dd MMM').format(date),
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: const Color(0xFFE6F1FB),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const CircleAvatar(
                      radius: 4, backgroundColor: Color(0xFF185FA5)),
                  const SizedBox(width: 6),
                  Text('${liters.toStringAsFixed(2)} L',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: hit
                              ? const Color(0xFF185FA5)
                              : const Color(0xFFA32D2D))),
                ]),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAEEDA),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(8)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const CircleAvatar(
                      radius: 4, backgroundColor: Color(0xFFEF9F27)),
                  const SizedBox(width: 6),
                  Text('Target: ${target.toStringAsFixed(1)} L',
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF854F0B),
                          fontWeight: FontWeight.w500)),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

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
            child: Text(widget.label,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          SizedBox(
            height: 220,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              trackballBehavior: _trackball,
              primaryXAxis: DateTimeAxis(
                dateFormat: widget.points.length > 10
                    ? DateFormat('dd MMM')
                    : DateFormat('EEE'),
                intervalType: DateTimeIntervalType.days,
                interval: widget.points.length > 10 ? 7 : 1,
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: (kWaterTarget * 1.4).ceilToDouble(),
                axisLabelFormatter: (d) => ChartAxisLabel(
                  '${d.value.toStringAsFixed(1)}L',
                  const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                majorGridLines:
                    const MajorGridLines(width: 0.5, color: Color(0xFFEEEEEE)),
                axisLine: const AxisLine(width: 0),
              ),
              series: <CartesianSeries>[
                // Target line
                LineSeries<WaterPoint, DateTime>(
                  dataSource: widget.points,
                  xValueMapper: (p, _) => p.date,
                  yValueMapper: (p, _) => p.target,
                  color: const Color(0xFFEF9F27),
                  width: 1.5,
                  dashArray: const [5, 3],
                  enableTooltip: true,
                  markerSettings: const MarkerSettings(isVisible: false),
                ),
                // Water bars
                ColumnSeries<WaterPoint, DateTime>(
                  dataSource: widget.points,
                  xValueMapper: (p, _) => p.date,
                  yValueMapper: (p, _) => p.liters,
                  pointColorMapper: (p, _) => p.liters >= p.target
                      ? const Color(0xFF185FA5)
                      : const Color(0xFF85B7EB),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                  width: 0.5,
                  enableTooltip: true,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 4, 0, 4),
            child: Row(children: [
              LegendDot(color: Color(0xFF185FA5), label: 'Water intake'),
              SizedBox(width: 16),
              LegendDot(
                  color: Color(0xFFEF9F27), label: 'Target', dashed: true),
            ]),
          ),
        ],
      ),
    );
  }
}
