import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../blocs/charts/step_chart/step_chart_cubit.dart';
import '../../blocs/step/step_cubit.dart';
import '../../services/step_tracking_service.dart';
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
  bool _trackingEnabled = false;

  @override
  void initState() {
    super.initState();
    context.read<StepChartCubit>().getDataFromNow();
    SharedPreferences.getInstance().then((prefs) {
      setState(() =>
          _trackingEnabled = prefs.getBool('step_tracking_enabled') ?? false);
    });
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
        actions: [
          if (_trackingEnabled)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: OutlinedButton(
                onPressed: () async {
                  final val = await syncStepsNow();
                  if (val) {
                    context.read<StepsCubit>().getStepData();
                    context.read<StepChartCubit>().getDataFromNow();
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                ),
                child: const Text('Sync'),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final enabled = prefs.getBool('step_tracking_enabled') ?? false;
                if (enabled) {
                  await stopTracking();
                } else {
                  await startTracking();
                }
                setState(() {});
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
              ),
              child: FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                builder: (context, snap) {
                  final enabled =
                      snap.data?.getBool('step_tracking_enabled') ?? false;
                  return Text(enabled ? 'Disable' : 'Enable');
                },
              ),
            ),
          ),
        ],
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
