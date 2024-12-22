import 'dart:developer';

import 'package:intl/intl.dart';

import '../blocs/charts/height_chart/height_chart_cubit.dart';
import '../blocs/charts/sleep_chart/sleep_chart_cubit.dart';
import '../blocs/charts/water_chart/water_chart_cubit.dart';
import '../blocs/charts/weight_chart/weight_chart_cubit.dart';
import 'package:flutter/cupertino.dart';

import '../blocs/charts/step_chart/step_chart_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key, required this.healthType});

  final HealthDataType healthType;

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  // List<double> data = [];
  int? selectedValue = 0;

  DateTime today = DateTime.now();

  Future<void> getChartData() async {
    (widget.healthType == HealthDataType.STEPS)
        ? context.read<StepChartCubit>().getDataFromNow()
        : (widget.healthType == HealthDataType.WATER)
            ? context.read<WaterChartCubit>().getDataFromNow()
            : (widget.healthType == HealthDataType.SLEEP_SESSION)
                ? context.read<SleepChartCubit>().getDataFromNow()
                : (widget.healthType == HealthDataType.WEIGHT)
                    ? context.read<WeightChartCubit>().getDataFromNow()
                    : (widget.healthType == HealthDataType.HEIGHT)
                        ? context.read<HeightChartCubit>().getDataFromNow()
                        : emptyFun();
  }

  @override
  void initState() {
    getChartData();
    super.initState();
  }

  Future<void> emptyFun() async {
    log("empty func call");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: selectedValue,
                onValueChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
                children: const {0: Text("WEEK"), 1: Text("MONTH")},
              ),
            ),
          ),
          Text("${widget.healthType}"),
          (widget.healthType == HealthDataType.STEPS)
              ? _step()
              : (widget.healthType == HealthDataType.WATER)
                  ? _water()
                  : (widget.healthType == HealthDataType.SLEEP_SESSION)
                      ? _sleep()
                      : (widget.healthType == HealthDataType.WEIGHT)
                          ? _weight()
                          : (widget.healthType == HealthDataType.HEIGHT)
                              ? _height()
                              : const Text('Something went wrong'),
        ],
      ),
    );
  }

  Widget _step() {
    return BlocBuilder<StepChartCubit, StepChartState>(
      builder: (context, state) {
        if (state is StepChartsLoading) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        } else if (state is StepChartsFailed) {
          return Center(
            child: Text(state.errorMessage),
          );
        } else if (state is StepChartsSuccess) {
          if (selectedValue == 0) {
            return chartWeekWidget(data: state.weekData);
          } else {
            return chartMonthWidget(data: state.monthData);
          }
        } else {
          return Text("UNKNOWN STATE $state");
        }
      },
    );
  }

  Widget _water() {
    return BlocBuilder<WaterChartCubit, WaterChartState>(
      builder: (context, state) {
        if (state is WaterChartLoading) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        } else if (state is WaterChartFailed) {
          return Center(
            child: Text(state.errorMessage),
          );
        } else if (state is WaterChartSuccess) {
          if (selectedValue == 0) {
            return chartWeekWidget(data: state.dataWeek);
          } else {
            return chartMonthWidget(data: state.dataMonth);
          }
        } else {
          return Text("UNKNOWN STATE $state");
        }
      },
    );
  }

  Widget _sleep() {
    return BlocBuilder<SleepChartCubit, SleepChartState>(
      builder: (context, state) {
        if (state is SleepChartsLoading) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        } else if (state is SleepChartsFailed) {
          return Center(
            child: Text(state.errorMessage),
          );
        } else if (state is SleepChartsSuccess) {
          if (selectedValue == 0) {
            return chartWeekWidget(data: state.dataWeek);
          } else {
            return chartMonthWidget(data: state.dataMonth);
          }
        } else {
          return Text("UNKNOWN STATE $state");
        }
      },
    );
  }

  Widget _weight() {
    return BlocBuilder<WeightChartCubit, WeightChartState>(
      builder: (context, state) {
        if (state is WeightChartsLoading) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        } else if (state is WeightChartsFailed) {
          return Center(
            child: Text(state.errorMessage),
          );
        } else if (state is WeightChartsSuccess) {
          if (selectedValue == 0) {
            return chartWeekWidget(data: state.dataWeek);
          } else {
            return chartMonthWidget(data: state.dataMonth);
          }
        } else {
          return Text("UNKNOWN STATE $state");
        }
      },
    );
  }

  Widget _height() {
    return BlocBuilder<HeightChartCubit, HeightChartState>(
      builder: (context, state) {
        if (state is HeightChartsLoading) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        } else if (state is HeightChartsFailed) {
          return Center(
            child: Text(state.errorMessage),
          );
        } else if (state is HeightChartsSuccess) {
          if (selectedValue == 0) {
            return chartWeekWidget(data: state.dataWeek);
          } else {
            return chartMonthWidget(data: state.dataMonth);
          }
        } else {
          return Text("UNKNOWN STATE $state");
        }
      },
    );
  }

  Widget chartWeekWidget({required List<double> data}) {
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 7));
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: LineChart(
          LineChartData(
            borderData: FlBorderData(
              border: const Border(
                top: BorderSide(
                  color: Colors.transparent,
                ),
                right: BorderSide(
                  color: Colors.transparent,
                ),
                bottom: BorderSide(color: Colors.black, width: 0.3),
                left: BorderSide(color: Colors.black, width: 0.3),
              ),
            ),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: false,
                fitInsideVertically: false,
                tooltipPadding: const EdgeInsets.all(5),
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((touchedSpot) {
                    return LineTooltipItem(
                      (widget.healthType == HealthDataType.SLEEP_SESSION)?(touchedSpot.y/60).toStringAsFixed(1):touchedSpot.y.toStringAsFixed(1),
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }).toList();
                },

              ),
              getTouchedSpotIndicator:(LineChartBarData barData, List<int> indicators) {
                return indicators.map((index) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: Colors.grey.withOpacity(0.5), // Line color
                      strokeWidth: 2, // Line width
                      dashArray: [5,2]
                    ),
                    FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4, // Small dot size
                          color: Colors.green, // Dot color
                          strokeWidth: 1,
                        );
                      },
                    ),
                  );
                }).toList();
              },
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Colors.grey,
                  strokeWidth: 0.2,
                );
              },
              getDrawingVerticalLine: (value) {
                return const FlLine(
                  color: Colors.grey,
                  strokeWidth: 0.1,
                );
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1, // Show titles every 5 days
                  getTitlesWidget: (value, meta) {
                    int dayIndex = value.toInt();
                    if (dayIndex < 0 || dayIndex >= data.length) {
                      return const SizedBox.shrink();
                    }
                    DateTime date = startDate.add(Duration(days: dayIndex));
                    String formattedDate = DateFormat('EEE').format(date);
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                axisNameWidget: (widget.healthType == HealthDataType.STEPS)
                    ? const Text("Steps")
                    : (widget.healthType == HealthDataType.WATER)
                        ? const Text("LITER")
                        : (widget.healthType == HealthDataType.SLEEP_SESSION)
                            ? const Text("HOURS")
                            : (widget.healthType == HealthDataType.WEIGHT)
                                ? const Text("KG")
                                : (widget.healthType == HealthDataType.HEIGHT)
                                    ? const Text("METER")
                                    : const Text("UNKNOWN"),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize:
                      (widget.healthType == HealthDataType.STEPS) ? 50 : 30,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      (widget.healthType == HealthDataType.SLEEP_SESSION)
                          ? (value / 60).toStringAsFixed(1)
                          : value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            minY: 0,
            lineBarsData: [
              LineChartBarData(
                preventCurveOverShooting: true,
                color: Colors.green,
                barWidth: 2,
                isCurved: true,
                curveSmoothness: 0.08,
                dotData: const FlDotData(
                  show: false,
                ),
                isStrokeCapRound: true,
                spots: List.generate(
                  data.length,
                  (index) {
                    return FlSpot(index.toDouble(), data[index]);
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green.withOpacity(0.7),
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                ),
                shadow: const Shadow(
                  color: Colors.grey,
                  offset: Offset(0, 1),
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }

  Widget chartMonthWidget({required List<double> data}) {
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 30));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: LineChart(
          LineChartData(
            borderData: FlBorderData(
              border: const Border(
                top: BorderSide(
                  color: Colors.transparent,
                ),
                right: BorderSide(
                  color: Colors.transparent,
                ),
                bottom: BorderSide(color: Colors.black, width: 0.3),
                left: BorderSide(color: Colors.black, width: 0.3),
              ),
            ),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: false,
                fitInsideVertically: false,
                tooltipPadding: const EdgeInsets.all(5),
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((touchedSpot) {
                    return LineTooltipItem(
                      (widget.healthType == HealthDataType.SLEEP_SESSION)?(touchedSpot.y/60).toStringAsFixed(1):touchedSpot.y.toStringAsFixed(1),
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }).toList();
                },
              ),
              getTouchedSpotIndicator:
                  (LineChartBarData barData, List<int> indicators) {
                return indicators.map((index) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: Colors.grey.withOpacity(0.5), // Line color
                      strokeWidth: 2, // Line width
                      dashArray: [5,2]
                    ),
                    FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4, // Small dot size
                          color: Colors.green, // Dot color
                          strokeWidth: 1,
                        );
                      },
                    ),
                  );
                }).toList();
              },
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Colors.grey,
                  strokeWidth: 0.2,
                );
              },
              getDrawingVerticalLine: (value) {
                return const FlLine(
                  color: Colors.transparent,
                  strokeWidth: 0.1,
                );
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 5, // Show titles every 5 days
                  getTitlesWidget: (value, meta) {
                    int dayIndex = value.toInt();
                    if (dayIndex < 0 || dayIndex >= data.length) {
                      return const SizedBox.shrink();
                    }
                    DateTime date = startDate.add(Duration(days: dayIndex));
                    String formattedDate = "${date.day}/${date.month}";
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                axisNameWidget: (widget.healthType == HealthDataType.STEPS)
                    ? const Text("Steps")
                    : (widget.healthType == HealthDataType.WATER)
                        ? const Text("LITER")
                        : (widget.healthType == HealthDataType.SLEEP_SESSION)
                            ? const Text("HOURS")
                            : (widget.healthType == HealthDataType.WEIGHT)
                                ? const Text("KG")
                                : (widget.healthType == HealthDataType.HEIGHT)
                                    ? const Text("METER")
                                    : const Text("UNKNOWN"),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize:
                      (widget.healthType == HealthDataType.STEPS) ? 50 : 30,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      (widget.healthType == HealthDataType.SLEEP_SESSION)
                          ? (value / 60).toStringAsFixed(1)
                          : value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                preventCurveOverShooting: true,
                color: Colors.green,
                barWidth: 2,
                isCurved: true,
                dotData: const FlDotData(
                  show: false,
                ),
                isStrokeCapRound: true,
                spots: List.generate(
                  data.length,
                  (index) => FlSpot(index.toDouble(), data[index]),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green.withOpacity(0.7),
                      Colors.green.withOpacity(0.0),
                    ],
                  ),
                ),
                shadow: const Shadow(
                  color: Colors.grey,
                  offset: Offset(0, 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
