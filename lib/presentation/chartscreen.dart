import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'dart:developer' as dev;

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key, required this.healthType});

  final HealthDataType healthType;

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<double> data = [];

  DateTime today = DateTime.now();

  @override
  void initState() {
    initialize();
    super.initState();
  }

  Future<void> initialize() async {
    ////month
    // for (var i = 1; i <= 30; i++) {
    //   double total = await getDataForDay(DateTime(today.year, today.month, i));
    //   thirtyDays.add(total);
    // }
    ////week
    for (var i = 0; i < 7; i++) {
      double total = await getDataForDay(DateTime.now()
          .subtract(const Duration(days: 7))
          .add(Duration(days: i)));
      data.add(total);
    }
    dev.log(data.length.toString());
    setState(() {});
  }

  Future<double> getDataForDay(DateTime date) async {
    double total = 0;
    // Start of the day (00:00)
    DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0);

    // End of the day (24:00, which is equivalent to the start of the next day)
    DateTime endOfDay =
        DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    bool healthTypePermission =
        await Health().hasPermissions([widget.healthType]) ?? false;
    if (!healthTypePermission) {
      healthTypePermission = await Health().requestAuthorization(
        [widget.healthType],
        permissions: [HealthDataAccess.READ],
      );
    }

    try {
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [widget.healthType],
        startTime: startOfDay,
        endTime: endOfDay,
      );

      if (healthData.isEmpty) {
        return 0;
      } else {
        healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        for (HealthDataPoint healthDataPoint in healthData) {
          total += healthDataPoint.value.toJson()['numericValue'] ?? 0;
        }
        return total;
      }
    } catch (e) {
      return 0;
    }
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
     String formattedValue;

  if (value >= 1000) {
    formattedValue = '${(value / 1000).toStringAsFixed(1)}k'; // Convert to 'k' and keep one decimal place
  } else {
    formattedValue = value.toStringAsFixed(0); // Keep it as an integer if less than 1000
  }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        formattedValue,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("A Week Line Chart"),
          Text("${widget.healthType}"),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Colors.grey,
                        strokeWidth: 0.1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return const FlLine(
                        color: Colors.grey,
                        strokeWidth: 0.1,
                      );
                    },
                  ),
                  titlesData:  FlTitlesData(
                    topTitles:  const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    // leftTitles: AxisTitles(
                    //   axisNameWidget: const Text(
                    //     'Value',
                    //     style: TextStyle(
                    //       color: Colors.black,
                    //     ),
                    //   ),
                    //   sideTitles: SideTitles(
                    //     showTitles: true,
                    //     interval: 1,
                    //     reservedSize: 40,
                    //     getTitlesWidget: leftTitleWidgets,
                    //   ),
                    // ),
                  ),
                  minY: 0,
                  lineBarsData: [
                    LineChartBarData(
                        preventCurveOverShooting: true,
                        color: Colors.green,
                        barWidth: 3,
                        isCurved: true,
                        dotData: const FlDotData(
                          show: false,
                        ),
                        isStrokeCapRound: true,
                        // spots: List.generate(thirtyDays.length, (index) => FlSpot(index.toDouble(), thirtyDays[index]),),
                        // spots: [
                        //   FlSpot(0,0),
                        //   FlSpot(1,2),
                        //   FlSpot(2,1),
                        //   FlSpot(3,5),
                        //   FlSpot(4,3),
                        //   FlSpot(5,8),
                        // ],

                        spots: List.generate(
                          data.length,
                          (index) => FlSpot(
                              today
                                  .subtract(const Duration(days: 7))
                                  .add(Duration(days: index))
                                  .day
                                  .toDouble(),
                              data[index]),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.green.withOpacity(0.2),
                        ),
                        shadow: const Shadow(
                          color: Colors.grey,
                          offset: Offset(0, 1),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
