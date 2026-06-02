import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/water/water_cubit.dart';

class WaterSummaryCard extends StatelessWidget {
  const WaterSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaterCubit, WaterState>(
      builder: (context, state) {
        final total = state is WaterSuccessState
            ? state.waterModel.fold(0.0, (sum, e) => sum + (e.value?.numericValue ?? 0.0))
            : 0.0;
        const double target = 4.0;
        final progress = (total / target).clamp(0.0, 1.0);

        return Container(
          constraints: const BoxConstraints(minHeight: 200, minWidth: 400),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: state is WaterLoadingState
              ? const Center(child: CircularProgressIndicator())
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Water',
                    style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation(Colors.blueAccent),
                    ),
                    const Icon(Icons.water_drop, color: Colors.blueAccent, size: 22),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('${(total * 1000).toInt()} ml',
                  style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const SizedBox(height: 4),
              Text('${(target - total).clamp(0, target).toStringAsFixed(1)} L left',
                  style: const TextStyle(color: Color(0xFF475569), fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}