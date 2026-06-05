import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'legend_dot.dart';
import 'step_point.dart';

class StepLineChart extends StatelessWidget {
  final List<StepPoint> points;
  final String label;
  const StepLineChart({super.key, required this.points, required this.label});
  
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
                dateFormat: points.length > 10
                    ? DateFormat('dd MMM')
                    : DateFormat('EEE'),
                intervalType: DateTimeIntervalType.days,
                interval: points.length > 10 ? 7 : 1,
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                labelFormat: '{value}',
                axisLabelFormatter: (details) {
                  return ChartAxisLabel(
                    '${(details.value / 1000).toStringAsFixed(0)}k',
                    const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                },
                majorGridLines: const MajorGridLines(
                    width: 0.5, color: Color(0xFFEEEEEE)),
                axisLine: const AxisLine(width: 0),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                builder: (data, point, series, pointIndex, seriesIndex) {
                  final p = data as StepPoint;
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(DateFormat('EEE, dd MMM').format(p.date),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 4),
                        Row(children: [
                          const CircleAvatar(radius: 4, backgroundColor: Color(0xFF639922)),
                          const SizedBox(width: 6),
                          Text('${_fmt(p.steps)} steps',
                              style: const TextStyle(fontSize: 11)),
                        ]),
                        const SizedBox(height: 2),
                        Row(children: [
                          const CircleAvatar(radius: 4, backgroundColor: Color(0xFFEF9F27)),
                          const SizedBox(width: 6),
                          Text('Target: ${_fmt(p.target)}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ]),
                      ],
                    ),
                  );
                },
              ),
              series: <CartesianSeries>[
                // Target line
                LineSeries<StepPoint, DateTime>(
                  dataSource: points,
                  xValueMapper: (p, _) => p.date,
                  yValueMapper: (p, _) => p.target,
                  color: const Color(0xFFEF9F27),
                  width: 1.5,
                  dashArray: const [5, 3],
                  enableTooltip: false,
                  markerSettings: const MarkerSettings(isVisible: false),
                ),
                // Steps area+line
                SplineAreaSeries<StepPoint, DateTime>(
                  dataSource: points,
                  xValueMapper: (p, _) => p.date,
                  yValueMapper: (p, _) => p.steps,
                  color: const Color(0xFF639922),
                  opacity: 0.1,
                  borderColor: const Color(0xFF639922),
                  borderWidth: 2,
                  splineType: SplineType.natural,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    height: 6,
                    width: 6,
                    borderWidth: 1.5,
                    borderColor: Colors.white,
                    color: const Color(0xFF639922),
                    shape: DataMarkerType.circle,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 4, 0, 4),
            child: Row(children: [
              LegendDot(color: Color(0xFF639922), label: 'Steps taken'),
              SizedBox(width: 16),
              LegendDot(color: Color(0xFFEF9F27), label: 'Target', dashed: true),
            ]),
          ),
        ],
      ),
    );
  }
}