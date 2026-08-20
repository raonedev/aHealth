import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'nutrient_point.dart';

class NutrientLineChart extends StatelessWidget {
  final List<NutrientPoint> points;
  final String label;
  final Color color;
  final String unit;
  const NutrientLineChart({
    super.key,
    required this.points,
    required this.label,
    required this.color,
    this.unit = 'g',
  });

  String _fmt(double v) => NumberFormat('#,##0').format(v);

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
                majorGridLines:
                    const MajorGridLines(width: 0.5, color: Color(0xFFEEEEEE)),
                axisLine: const AxisLine(width: 0),
                labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              trackballBehavior: TrackballBehavior(
                enable: true,
                activationMode: ActivationMode.singleTap,
                tooltipSettings: const InteractiveTooltip(enable: false),
                lineType: TrackballLineType.vertical,
                lineColor: color,
                lineDashArray: const [4, 2],
                markerSettings: const TrackballMarkerSettings(
                  markerVisibility: TrackballVisibilityMode.visible,
                  height: 8,
                  width: 8,
                  borderWidth: 2,
                  borderColor: Colors.white,
                ),
                builder: (context, details) {
                  if (details.point == null) return const SizedBox();
                  final p = details.point!;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${DateFormat('EEE, dd MMM').format(p.x as DateTime)}\n${_fmt(p.y as double)} $unit',
                      style: TextStyle(
                          fontSize: 11, color: color, fontWeight: FontWeight.w500),
                    ),
                  );
                },
              ),
              series: <CartesianSeries>[
                SplineAreaSeries<NutrientPoint, DateTime>(
                  dataSource: points,
                  xValueMapper: (p, _) =>
                      DateTime(p.date.year, p.date.month, p.date.day),
                  yValueMapper: (p, _) => p.value,
                  color: color,
                  opacity: 0.1,
                  borderColor: color,
                  borderWidth: 2,
                  splineType: SplineType.natural,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    height: 6,
                    width: 6,
                    borderWidth: 1.5,
                    borderColor: Colors.white,
                    color: color,
                    shape: DataMarkerType.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}