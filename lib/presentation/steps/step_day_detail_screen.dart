import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../blocs/charts/step_chart/step_day_data.dart';

const _stepChartColor = Color(0xFF4285F4);
const _stepChartFill = Color(0xFFDCE9FF);

class StepDayDetailScreen extends StatelessWidget {
  const StepDayDetailScreen({
    required this.day,
    required this.dayData,
    super.key,
  });

  final DateTime day;
  final Future<StepDayData> dayData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(onPressed: () {
          context.pop();
        }, icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft02, color: Colors.black,),tooltip: 'Back',),
        title: Text(DateFormat('EEEE, d MMM').format(day)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: FutureBuilder<StepDayData>(
        future: dayData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Unable to load steps: ${snapshot.error}'),
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('No step data available.'));
          }

          return _StepDayContent(day: day, data: data);
        },
      ),
    );
  }
}

class _StepDayContent extends StatelessWidget {
  const _StepDayContent({required this.day, required this.data});

  final DateTime day;
  final StepDayData data;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _StepDayOverview(day: day, data: data),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
            child: Text(
              'Step records',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        if (data.records.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No step records for this day.'),
            ),
          )
        else
          SliverList.builder(
            itemCount: data.records.length,
            itemBuilder: (context, index) =>
                _StepRecordCard(record: data.records[index]),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

class _StepDayOverview extends StatelessWidget {
  const _StepDayOverview({required this.day, required this.data});

  final DateTime day;
  final StepDayData data;

  String _formatSteps(double value) =>
      NumberFormat('#,###').format(value.round());

  @override
  Widget build(BuildContext context) {
    final startOfDay = DateTime(day.year, day.month, day.day);

    return Container(
      color: Colors.white,
      padding: const EdgeInsetsDirectional.fromSTEB(12, 16, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatSteps(data.totalSteps)} steps',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 280,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              trackballBehavior: TrackballBehavior(
                enable: true,
                activationMode: ActivationMode.singleTap,
                shouldAlwaysShow: false,
                tooltipSettings: const InteractiveTooltip(enable: false),
                lineType: TrackballLineType.vertical,
                lineWidth: 1,
                lineColor: _stepChartColor.withValues(alpha: 0.35),
                markerSettings: const TrackballMarkerSettings(
                  markerVisibility: TrackballVisibilityMode.visible,
                  height: 8,
                  width: 8,
                  borderWidth: 2,
                  borderColor: Colors.white,
                ),
                builder: (context, details) {
                  final point = details.point;
                  if (point == null) return const SizedBox();
                  return _StepChartTooltip(
                    time: point.x as DateTime,
                    steps: (point.y as num).toDouble(),
                  );
                },
              ),
              primaryXAxis: DateTimeAxis(
                minimum: startOfDay,
                maximum: startOfDay.add(const Duration(hours: 23)),
                intervalType: DateTimeIntervalType.hours,
                interval: 3,
                dateFormat: DateFormat('HH'),
                title: const AxisTitle(text: 'Time'),
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                // title: const AxisTitle(text: 'Steps'),
                majorGridLines: const MajorGridLines(
                  width: 0.5,
                  color: Color(0xFFE8ECF2),
                ),
                axisLine: const AxisLine(width: 0),
              ),
              series: <CartesianSeries<StepHourCount, DateTime>>[
                ColumnSeries<StepHourCount, DateTime>(
                  dataSource: data.hourlyCounts,
                  xValueMapper: (point, _) => point.time,
                  yValueMapper: (point, _) => point.steps,
                  color: _stepChartFill,
                  width: 0.62,
                  spacing: 0.16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(5),
                  ),
                  selectionBehavior: SelectionBehavior(
                    enable: true,
                    selectedColor: _stepChartColor,
                    unselectedColor: _stepChartFill,
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

class _StepChartTooltip extends StatelessWidget {
  const _StepChartTooltip({required this.time, required this.steps});

  final DateTime time;
  final double steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2A),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('HH:mm').format(time),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${NumberFormat('#,###').format(steps.round())} steps',
            style: const TextStyle(color: Color(0xFFAECBFA), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StepRecordCard extends StatelessWidget {
  const _StepRecordCard({required this.record});

  final StepDayRecord record;

  String _formatSteps(double value) =>
      NumberFormat('#,###').format(value.round());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 8),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF3DE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_walk_rounded,
                  color: Color(0xFF3B6D11),
                  size: 18,
                  semanticLabel: 'Steps',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Steps at ${DateFormat('hh:mm a').format(record.time)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                _formatSteps(record.steps),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3B6D11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
