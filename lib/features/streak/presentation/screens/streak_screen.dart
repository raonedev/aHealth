import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/streak_cubit.dart';
import '../cubit/streak_state.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  static String pageName="/streaks";

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StreakCubit>().loadStreak();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Streak')),
      body: BlocBuilder<StreakCubit, StreakState>(
        builder: (context, state) {
          if (state is StreakLoading || state is StreakInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StreakError) {
            return Center(child: Text(state.message));
          }
          if (state is StreakLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🔥 ${state.streak.currentStreak}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                  const Text('Current Streak'),
                  const SizedBox(height: 16),
                  Text('Longest: ${state.streak.longestStreak} days'),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
