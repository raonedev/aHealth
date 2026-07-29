import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app_routes.dart';
import '../../../blocs/step/step_cubit.dart';
import '../../../common/spring_button_widget.dart';

const _kPrimaryContainer = Color(0xFF2E7D32);
const _kPrimary = Color(0xFF0D631B);
const _kOnSurfaceVariant = Color(0xFF40493D);

const _kSurfaceContainerHighest = Color(0xFFE3E2E2);

class StepsCard extends StatelessWidget {
  const StepsCard({super.key});

  @override
  Widget build(BuildContext context) {
    const target = 8000;

    return SpringButton(
      SpringButtonType.withOpacity,
      onTap: () async {
        HapticFeedback.mediumImpact();
        await Future.delayed(Durations.medium1);
        context.push(AppRoutes.stepChartScreen);
      },
      uiChild: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF7FDF7)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BlocBuilder<StepsCubit, StepsState>(
          builder: (context, state) {
            num steps = 0;
            Widget trailing = const SizedBox();

            if (state is StepLoadingState) {
              trailing = const CupertinoActivityIndicator();
            } else if (state is StepFailed) {
              steps = 0;
            } else if (state is StepSuccessState) {
              for (final step in state.stepModel) {
                if (step.value != null) {
                  steps += step.value!.numericValue ?? 0;
                }
              }
            }

            final percent = (steps / target).clamp(0.0, 1.0);

            return Column(
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
                            color: _kPrimaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.directions_walk,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STEPS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: _kOnSurfaceVariant,
                              ),
                            ),
                            trailing is CupertinoActivityIndicator
                                ? trailing
                                : Text(
                                    '$steps / $target',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '${(percent * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _kPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    backgroundColor:
                        _kSurfaceContainerHighest.withValues(alpha: 0.5),
                    valueColor:
                        const AlwaysStoppedAnimation(_kPrimaryContainer),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}