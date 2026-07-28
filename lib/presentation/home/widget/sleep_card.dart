import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/sleep/sleep_cubit.dart';
import '../../sleep/sleep_picker.dart';

const _kPrimary = Color(0xFF0D631B);
const _kTertiary = Color(0xFF00569F);
const _kOnSurfaceVariant = Color(0xFF40493D);
const _kSurfaceContainerLowest = Color(0xFFFFFFFF);

class SleepCard extends StatelessWidget {
  const SleepCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return const SleepPickerBottomSheet();
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _kSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BlocBuilder<SleepCubit, SleepState>(
          builder: (context, state) {
            String duration = '--';
            if (state is SleepSuccessState && state.sleepModel.isNotEmpty) {
              final minutes = state.sleepModel[0].value?.numericValue ?? 0;
              final hours = (minutes / 60);
              duration =
                  '${hours.floor()}h ${((hours - hours.floor()) * 60).round()}m';
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _kTertiary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.bedtime, color: _kTertiary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SLEEP QUALITY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: _kOnSurfaceVariant,
                              ),
                            ),
                            if (state is SleepLoadingState)
                              const CupertinoActivityIndicator()
                            else if (state is SleepFailedState)
                              const Text('failed to load sleep',
                                  style: TextStyle(fontSize: 12))
                            else
                              Text(
                                duration,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                          ],
                        ),
                      ],
                    ),
                    // TODO: real sleep score isn't in SleepState — wire up if available
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _kPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: _kPrimary.withValues(alpha: 0.2)),
                      ),
                      child: const Text(
                        'SCORE: 84',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Static placeholder bars — replace with real hourly sleep data if available
                SizedBox(
                  height: 80,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [0.3, 0.6, 0.85, 0.45, 0.75, 0.35, 0.65, 1.0, 0.4]
                        .map((h) => Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: Container(
                                  height: 80 * h,
                                  decoration: BoxDecoration(
                                    color: _kTertiary.withValues(
                                        alpha: 0.3 + h * 0.4),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('11:30 PM',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _kOnSurfaceVariant.withValues(alpha: 0.6))),
                    // TODO: real REM duration isn't in SleepState — wire up if available
                    const Text('REM Sleep: 1h 45m',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700)),
                    Text('06:50 AM',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _kOnSurfaceVariant.withValues(alpha: 0.6))),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}