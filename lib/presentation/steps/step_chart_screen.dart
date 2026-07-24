import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/charts/step_chart/step_chart_cubit.dart';
import '../common/widgets/custom_segment.dart';
import 'monthly_tab.dart';
import 'weekly_tab.dart';

const double kDailyTarget = 8000;

class StepChartScreen extends StatefulWidget {
  const StepChartScreen({super.key});

  @override
  State<StepChartScreen> createState() => _StepChartScreenState();
}

class _StepChartScreenState extends State<StepChartScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<StepChartCubit>().getDataFromNow();
  }

  @override
  void dispose() {
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
      ),
      body: BlocBuilder<StepChartCubit, StepChartState>(
        builder: (context, state) {
          if (state is StepChartsLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B6D11)));
          }
          if (state is StepChartsFailed) {
            return Center(child: Text(state.errorMessage));
          }
          if (state is StepChartsSuccess) {
            return Stack(
              children: [
                IndexedStack(
                  index: _selectedTab,
                  children: [
                    WeeklyTab(weekData: state.weekData),
                    MonthlyTab(
                        monthData: state.monthData, loaded: state.monthLoaded),
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
                        thumbColor: const Color(0xFF3B6D11),
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
