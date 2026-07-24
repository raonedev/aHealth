import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/charts/water_chart/water_chart_cubit.dart';
import '../../common/widgets/custom_segment.dart';
import 'water_month_tab.dart';
import 'water_week_tab.dart';

const double kWaterTarget = 2.5; // liters

class WaterChartScreen extends StatefulWidget {
  const WaterChartScreen({super.key});
  @override
  State<WaterChartScreen> createState() => _WaterChartScreenState();
}

class _WaterChartScreenState extends State<WaterChartScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<WaterChartCubit>().getChartData();
  }

  @override
  void dispose() {  super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Water'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: BlocBuilder<WaterChartCubit, WaterChartState>(
        builder: (context, state) {
          if (state is WaterChartLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF185FA5)));
          }
          if (state is WaterChartFailed) {
            return Center(child: Text(state.errorMessage));
          }
          if (state is WaterChartSuccess) {
            return Stack(
              children: [
                IndexedStack(
                  index: _selectedTab,
                  children: [
                    WaterWeeklyTab(weekData: state.weekData),
                    WaterMonthlyTab(monthData: state.monthData, loaded: state.monthLoaded),
                  ],
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 20,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: CustomSlidingSegmentedControl(
                        currentSelection: _selectedTab,
                        children: const ['Weekly', 'Monthly'],
                        onValueChanged: (i) => setState(() => _selectedTab = i),
                        thumbColor: const Color(0xFF185FA5),
                      ),
                    ),
                  ),
                )
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}