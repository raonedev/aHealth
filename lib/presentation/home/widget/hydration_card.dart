import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app_routes.dart';
import '../../../blocs/water/water_cubit.dart';
import '../../../common/spring_button_widget.dart';

const _kSurfaceContainerLowest = Color(0xFFFFFFFF);

const _kTertiary = Color(0xFF00569F);
const _kOnSurfaceVariant = Color(0xFF40493D);

class HydrationCard extends StatelessWidget {
  const HydrationCard({super.key});

  @override
  Widget build(BuildContext context) {
    const target = 3.0;

    return SpringButton(
      SpringButtonType.withOpacity,
      onTap: () async {
        HapticFeedback.mediumImpact();
        await Future.delayed(Durations.medium1);
        context.push(AppRoutes.waterChartScreen);
      },
      uiChild: Container(
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
        child: BlocBuilder<WaterCubit, WaterState>(
          builder: (context, state) {
            double liters = 0;
            if (state is WaterSuccessState) {
              for (final entry in state.waterModel) {
                liters += entry.value?.numericValue ?? 0;
              }
            }
            final percent = (liters / target).clamp(0.0, 1.0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HYDRATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: _kOnSurfaceVariant,
                      ),
                    ),
                    Icon(Icons.water_drop, color: _kTertiary, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                if (state is WaterLoadingState)
                  const CupertinoActivityIndicator()
                else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        liters.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: _kTertiary,
                        ),
                      ),
                      const Text('L', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Text(
                    'Target: ${target}L',
                    style: TextStyle(fontSize: 11, color: _kOnSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 6,
                    backgroundColor: _kTertiary.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(
                        _kTertiary.withValues(alpha: 0.8)),
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
