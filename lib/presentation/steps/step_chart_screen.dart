import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/charts/step_chart/step_chart_cubit.dart';
import 'monthly_tab.dart';
import 'weekly_tab.dart';

const double kDailyTarget = 8000;

class StepChartScreen extends StatefulWidget {
  const StepChartScreen({super.key});
  @override
  State<StepChartScreen> createState() => _StepChartScreenState();
}

class _StepChartScreenState extends State<StepChartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    context.read<StepChartCubit>().getDataFromNow();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Steps'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tab,
          labelColor: const Color(0xFF3B6D11),
          indicatorColor: const Color(0xFF3B6D11),
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'Weekly'), Tab(text: 'Monthly')],
        ),
      ),
      body: BlocBuilder<StepChartCubit, StepChartState>(
        builder: (context, state) {
          if (state is StepChartsLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF3B6D11)));
          }
          if (state is StepChartsFailed) {
            return Center(child: Text(state.errorMessage));
          }
          if (state is StepChartsSuccess) {
            return TabBarView(
              controller: _tab,
              children: [
                WeeklyTab(weekData: state.weekData),
                MonthlyTab(monthData: state.monthData, loaded: state.monthLoaded),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}