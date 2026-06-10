import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'legend_dot.dart';
import 'step_point.dart';

class StepLineChart extends StatelessWidget {
  final List<StepPoint> points;
  final String label;
  StepLineChart({super.key, required this.points, required this.label});

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
                // rangePadding: ChartRangePadding.additional,

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
                majorGridLines:
                    const MajorGridLines(width: 0.5, color: Color(0xFFEEEEEE)),
                axisLine: const AxisLine(width: 0),
              ),
              trackballBehavior: TrackballBehavior(
                enable: true,
                activationMode: ActivationMode.singleTap,
                // FIX: Force the trackball to group data from all series together
                tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
                tooltipSettings: const InteractiveTooltip(enable: false),
                lineType: TrackballLineType.vertical,
                lineColor: Colors.orange,
                lineDashArray: const [4, 2],
                markerSettings: const TrackballMarkerSettings(
                  markerVisibility: TrackballVisibilityMode.visible,
                  height: 8,
                  width: 8,
                  borderWidth: 2,
                  borderColor: Colors.white,
                ),
                builder: (context, trackballDetails) {
                  if (trackballDetails.groupingModeInfo == null) {
                    return const SizedBox();
                  }
                  final points = trackballDetails.groupingModeInfo!.points;
                  // points[0] = target series, points[1] = steps series
                  final stepVal =
                      points.length > 1 ? points[1].y as double : 0.0;
                  final targetVal =
                      points.isNotEmpty ? points[0].y as double : 0.0;
                  final date = points.isNotEmpty
                      ? points[0].x as DateTime
                      : DateTime.now();
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Steps tooltip (linked to green line)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3DE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF3B6D11).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${DateFormat('EEE, dd MMM').format(date)}\n${_fmt(stepVal)} steps',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF3B6D11),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Target tooltip (linked to amber line)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAEEDA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF854F0B).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Target: ${_fmt(targetVal)}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF854F0B),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  );
                },
              ),
              series: <CartesianSeries>[
                // Target line
                LineSeries<StepPoint, DateTime>(
                  dataSource: points,
                  // Inside your series definition
                  xValueMapper: (p, _) =>
                      DateTime(p.date.year, p.date.month, p.date.day),
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
                  // Inside your series definition
                  xValueMapper: (p, _) =>
                      DateTime(p.date.year, p.date.month, p.date.day),
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
              LegendDot(
                  color: Color(0xFFEF9F27), label: 'Target', dashed: true),
            ]),
          ),
        ],
      ),
    );
  }
}
