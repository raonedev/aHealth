import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/nutrition/nutrition_cubit.dart';
import '../../common/spring_button_widget.dart';
import '../../models/nutrition_model.dart';
import '../../services/nutrition_service.dart';

// Your App Color Palette Mapping
const Color _bg = Color(0xFFF6F6F9);
const Color _card = Color(0xFFFFFFFF);
const Color _textPrimary = Color(0xFF1A1A1A);
const Color _textSecondary = Color(0xFF757575);

const Color _proteinColor = Color(0xFFE05252);
const Color _carbsColor = Color(0xFFE0A952);
const Color _fatColor = Color(0xFF5299E0);

class FoodScanResultScreen extends StatefulWidget {
  final List<ValueFood> foods;
  final String imagePath;
  final String groupUuid;

  const FoodScanResultScreen({
    super.key,
    required this.foods,
    required this.imagePath,
    required this.groupUuid,
  });

  @override
  State<FoodScanResultScreen> createState() => _FoodScanResultScreenState();
}

class _FoodScanResultScreenState extends State<FoodScanResultScreen> {
  late List<bool> _selected;
  bool _logging = false;

  @override
  void initState() {
    super.initState();
    _selected = List.filled(widget.foods.length, true);
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically calculate macro totals only for items marked true
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    int selectedCount = 0;

    final selectedFoods = <ValueFood>[];
    for (int i = 0; i < widget.foods.length; i++) {
      if (_selected[i]) {
        final f = widget.foods[i];
        selectedFoods.add(f);
        totalCalories += f.calories ?? 0;
        totalProtein += f.protein ?? 0;
        totalCarbs += f.carbs ?? 0;
        totalFat += f.fat ?? 0;
        selectedCount++;
      }
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Review Scanned Food',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: _textPrimary),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Top Image and Real-time Summary Panel
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rounded Image Hero
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                    image: DecorationImage(
                      image: FileImage(File(widget.imagePath)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Selection Live Tracker Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detected Items',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Selected Total: ${totalCalories.toStringAsFixed(0)} kcal',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Inline Real-Time Micro Macro Summary Bar
                if (selectedCount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSummaryChip(
                            'P: ${totalProtein.toStringAsFixed(1)}g',
                            _proteinColor),
                        _buildSummaryChip(
                            'C: ${totalCarbs.toStringAsFixed(1)}g',
                            _carbsColor),
                        _buildSummaryChip(
                            'F: ${totalFat.toStringAsFixed(1)}g', _fatColor),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Custom Elegant Checklist
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final f = widget.foods[i];
                  final isCurrentSelected = _selected[i];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SpringButton(
                      SpringButtonType.withOpacity,
                      onTap: () {
                        setState(() {
                          _selected[i] = !_selected[i];
                        });
                      },
                      uiChild: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCurrentSelected
                                ? Colors.black.withValues(alpha: 0.1)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            // Selection State Indicator Indicator
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isCurrentSelected
                                    ? Colors.black
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isCurrentSelected
                                      ? Colors.black
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: isCurrentSelected
                                  ? const Icon(Icons.check,
                                      size: 16, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 16),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f.name ?? 'Unknown Item',
                                    style: TextStyle(
                                      color: isCurrentSelected
                                          ? _textPrimary
                                          : _textSecondary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      decoration: isCurrentSelected
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        '${f.calories?.toStringAsFixed(0)} kcal',
                                        style: const TextStyle(
                                          color: _textPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildMacroText(
                                          'P',
                                          '${f.protein?.toStringAsFixed(0)}g',
                                          _proteinColor),
                                      _buildMacroText(
                                          'C',
                                          '${f.carbs?.toStringAsFixed(0)}g',
                                          _carbsColor),
                                      _buildMacroText(
                                          'F',
                                          '${f.fat?.toStringAsFixed(0)}g',
                                          _fatColor),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: widget.foods.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // Bottom Premium Action Sheet Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: _card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: SpringButton(
          SpringButtonType.onlyScale,
          onTap: (_logging || selectedFoods.isEmpty)
              ? null
              : () async {
                  setState(() => _logging = true);

                  await context
                      .read<NutritionCubit>()
                      .addMultipleNutritionData(selectedFoods: selectedFoods);

                  await NutritionService.saveScanGroup(
                    uuid: widget.groupUuid,
                    imagePath: widget.imagePath,
                    foods: selectedFoods,
                  );
                  if (context.mounted) {
                    Navigator.popUntil(context, (r) => r.isFirst);
                  }
                },
          uiChild: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color:
                  selectedFoods.isEmpty ? Colors.grey.shade300 : Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _logging
                ? const CupertinoActivityIndicator(color: Colors.white)
                : Text(
                    selectedFoods.isEmpty
                        ? 'Select items to log'
                        : 'Log $selectedCount Items',
                    style: TextStyle(
                      color:
                          selectedFoods.isEmpty ? _textSecondary : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // Mini Macro Builder Element
  Widget _buildMacroText(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label $value',
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Header Interactive Label Chip Component
  Widget _buildSummaryChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
