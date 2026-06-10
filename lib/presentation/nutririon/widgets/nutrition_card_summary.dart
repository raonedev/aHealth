import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/nutrition/nutrition_cubit.dart';
import '../../../models/nutrition_model.dart';
import 'circular_progress.dart';
import 'macro_chip.dart';


const Color _textPrimary = Color(0xFF1A1A1A); // Dark charcoal for primary text

const Color _proteinColor = Color(0xFFE05252);
const Color _carbsColor = Color(0xFFE0A952);
const Color _fatColor = Color(0xFF5299E0);

class NutritionSummaryCard extends StatelessWidget {
  const NutritionSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionCubit, NutritionState>(
      builder: (context, state) {
        final items = state is NutritionSuccess ? state.nutritionModel : <NutritionModel>[];
        final totalCalories = items.fold(0.0, (s, e) => s + (e.value?.calories ?? 0));
        final totalProtein = items.fold(0.0, (s, e) => s + (e.value?.protein ?? 0));
        final totalCarbs = items.fold(0.0, (s, e) => s + (e.value?.carbs ?? 0));
        final totalFat = items.fold(0.0, (s, e) => s + (e.value?.fat ?? 0));

        const double targetCalories = 2500;

        return Container(
          constraints: const BoxConstraints(minHeight: 200, minWidth: 400),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: state is NutritionLoading
              ? const Center(child: CupertinoActivityIndicator())
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nutrition',
                  style: TextStyle(
                      color: _textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Center(
                child: CircularProgress(
                  value: (totalCalories / targetCalories).clamp(0.0, 1.0),
                  color: Colors.orange,
                  size: 64,
                  icon: Icons.local_fire_department,
                  iconColor: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text('${totalCalories.toInt()} kcal',
                    style: const TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MacroChip(icon: Icons.bolt, color: _proteinColor, value: totalProtein),
                  MacroChip(icon: Icons.grain, color: _carbsColor, value: totalCarbs),
                  MacroChip(icon: Icons.water_drop, color: _fatColor, value: totalFat),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}