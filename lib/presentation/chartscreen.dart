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
// import 'dart:developer' as dev;

///TODO:week and month chart

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key, required this.healthType});

  final HealthDataType healthType;

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  // List<double> data = [];

  DateTime today = DateTime.now();

  @override
  void initState() {
    (widget.healthType == HealthDataType.STEPS)
        ? context.read<StepChartCubit>().getWeekDataFromNow()
        : (widget.healthType == HealthDataType.WATER)
            ? context.read<WaterChartCubit>().getWeekDataFromNow()
            : (widget.healthType == HealthDataType.SLEEP_SESSION)
                ? context.read<SleepChartCubit>().getWeekDataFromNow()
                : (widget.healthType == HealthDataType.WEIGHT)
                    ? context.read<WeightChartCubit>().getWeekDataFromNow()
                    : (widget.healthType == HealthDataType.HEIGHT)
                        ? context.read<HeightChartCubit>().getWeekDataFromNow()
                        : emptyFun();
    super.initState();
  }
  Future<void> emptyFun() async{}

  // Future<void> initialize() async {
  //   ////month
  //   // for (var i = 1; i <= 30; i++) {
  //   //   double total = await getDataForDay(DateTime(today.year, today.month, i));
  //   //   thirtyDays.add(total);
  //   // }
  //   ////week
  //   for (var i = 0; i < 7; i++) {
  //     double total = await getDataForDay(DateTime.now()
  //         .subtract(const Duration(days: 7))
  //         .add(Duration(days: i)));
  //     data.add(total);
  //   }
  //   dev.log(data.length.toString());
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("A Week Line Chart"),
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
        }
        else if (state is StepChartsFailed) {
          return Center(
            child: Text(state.errorMessage),
          );
        }
        else if (state is StepChartsWeekSuccess) {
          return chartWeekWidget(data: state.data);
        } else if (state is StepChartsMonthSuccess) {
          return chartMonthWidget(data: state.data);
        }
        else {
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
        }
        else if (state is WaterChartFailed) {
          return Center(
            child: Text(state.errorMessage),
          );
        }
        else if (state is WaterChartWeekSuccess) {
          return chartWeekWidget(data: state.data);
        } else if (state is WaterChartMonthSuccess) {
          return chartMonthWidget(data: state.data);
        }
        else {
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
        }
        else if (state is SleepChartsFailed) {
          return Center(
            child: Text(state.errorMessage),
          );
        }
        else if (state is SleepChartsWeekSuccess) {
          return chartWeekWidget(data: state.data);
        } else if (state is SleepChartsMonthSuccess) {
          return chartMonthWidget(data: state.data);
        }
        else {
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
        }
        else if (state is WeightChartsFailed) {
          return Center(
            child: Text(state.errorMessage),
          );
        }
        else if (state is WeightChartsWeekSuccess) {
          return chartWeekWidget(data: state.data);
        } else if (state is WeightChartsMonthSuccess) {
          return chartMonthWidget(data: state.data);
        }
        else {
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
        }
        else if (state is HeightChartsFailed) {
          return Center(
            child: Text(state.errorMessage),
          );
        }
        else if (state is HeightChartsWeekSuccess) {
          return chartWeekWidget(data: state.data);
        } else if (state is HeightChartsMonthSuccess) {
          return chartMonthWidget(data: state.data);
        }
        else {
          return Text("UNKNOWN STATE $state");
        }
      },
    );
  }

  Widget chartWeekWidget({required List<double> data}) {
    return Padding(
          padding: const EdgeInsets.all(8.0),
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
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
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
          
                      spots: List.generate(
                        data.length,(index) => FlSpot(today.subtract(const Duration(days: 7)).add(Duration(days: index)).day.toDouble(),data[index]),
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
        );
  }
  
  Widget chartMonthWidget({required List<double> data}) {
    return Padding(
          padding: const EdgeInsets.all(8.0),
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
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
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
                      spots: List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index]),),
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
        );
  }

}
