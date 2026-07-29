import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/weight/weight_cubit.dart';
import '../../../helper/helper_func.dart';
const _kPrimary = Color(0xFF0D631B);
const _kOnSurfaceVariant = Color(0xFF40493D);
const _kSurfaceContainerLowest = Color(0xFFFFFFFF);

class WeightCard extends StatelessWidget {
  const WeightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: BlocBuilder<WeightCubit, WeightState>(
        builder: (context, state) {
          Widget content;
          if (state is WeightLoading) {
            content = const CupertinoActivityIndicator();
          } else if (state is WeightFailed) {
            content = Text(state.errorMessage,
                style: const TextStyle(fontSize: 12, color: Colors.red));
          } else if (state is WeightSuccess && state.weightModel.isNotEmpty) {
            final value = state.weightModel[0].value?.numericValue;
            content = Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    text: value != null ? '$value ' : '0 ',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                    children: const [
                      TextSpan(
                        text: 'kg',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.south_east, color: _kPrimary, size: 16),
              ],
            );
          } else {
            content =
                const Text('No Weight Data', style: TextStyle(fontSize: 12));
          }

          return GestureDetector(
            onTap: () => showWeightDialog(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'WEIGHT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: _kOnSurfaceVariant,
                      ),
                    ),
                    Icon(Icons.monitor_weight,
                        color: _kOnSurfaceVariant, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                content,
              ],
            ),
          );
        },
      ),
    );
  }
}