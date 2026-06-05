import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/charts/water_chart/water_chart_cubit.dart';
import 'water_month_tab.dart';
import 'water_week_tab.dart';

const double kWaterTarget = 2.5; // liters

class WaterChartScreen extends StatefulWidget {
  const WaterChartScreen({super.key});
  @override
  State<WaterChartScreen> createState() => _WaterChartScreenState();
}

class _WaterChartScreenState extends State<WaterChartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    context.read<WaterChartCubit>().getChartData();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Water'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tab,
          labelColor: const Color(0xFF185FA5),
          indicatorColor: const Color(0xFF185FA5),
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'Weekly'), Tab(text: 'Monthly')],
        ),
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
            return TabBarView(
              controller: _tab,
              children: [
                WaterWeeklyTab(weekData: state.weekData),
                WaterMonthlyTab(monthData: state.monthData, loaded: state.monthLoaded),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}