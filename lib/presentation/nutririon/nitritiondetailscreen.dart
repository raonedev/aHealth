import 'package:ahealth/common/spring_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/nutrition_model.dart';

// Premium iOS Light Theme Palette
const Color _bg = Color(0xFFF2F2F7);          // iOS System Background Light
const Color _surface = Color(0xFFFFFFFF);     // Pure White for Cards/Sheets
const Color _textPrimary = Color(0xFF000000); // Sharp Primary Text
const Color _textSecondary = Color(0xFF8E8E93);// iOS Muted Gray Subtitles
const Color _separator = Color(0xFFE5E5EA);    // iOS Border Line Color

// Accent Colors
const Color _proteinColor = Color(0xFFFF453A); // iOS System Red
const Color _carbsColor = Color(0xFFFF9F0A);   // iOS System Orange
const Color _fatColor = Color(0xFF0A84FF);     // iOS System Blue
const Color _microColor = Color(0xFF30D158);   // iOS System Green

class NutritionDetailScreen extends StatelessWidget {
  final NutritionModel nutritionModel;

  const NutritionDetailScreen({super.key, required this.nutritionModel});

  @override
  Widget build(BuildContext context) {
    final valueFood = nutritionModel.value;
    final totalCalories = valueFood?.calories?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: CupertinoBackButton(onPressed: () => Navigator.of(context).pop()),
        title: const Text(
          "Nutrition Info",
          style: TextStyle(
            color: _textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // Android dark icons
          statusBarBrightness: Brightness.light,    // iOS dark text
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Native iOS feel
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Name Header
            Text(
              valueFood?.name ?? "Unknown Food",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                fontSize: 28,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Per serving size",
              style: TextStyle(color: _textSecondary, fontSize: 15, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 24),

            // Premium Calorie Indicator
            SpringButton(
              SpringButtonType.onlyScale,
              onTap: (){},
              uiChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Energy",
                              style: TextStyle(fontSize: 14, color: _textSecondary, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "$totalCalories kcal",
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _textPrimary, letterSpacing: -0.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Macronutrients iOS List Group
            _buildSectionHeader("MACRONUTRIENTS"),
            _iOSListGroup(
              children: [
                _buildListTile('Protein', valueFood?.protein, 'g', _proteinColor),
                _buildListTile('Carbs', valueFood?.carbs, 'g', _carbsColor),
                _buildListTile('Fat', valueFood?.fat, 'g', _fatColor),
                _buildListTile('Fiber', valueFood?.fiber, 'g', Colors.brown.shade400),
                _buildListTile('Sugar', valueFood?.sugar, 'g', Colors.pink.shade300),
              ],
            ),
            const SizedBox(height: 24),

            // Micronutrients iOS List Group
            _buildSectionHeader("MICRONUTRIENTS"),
            _iOSListGroup(
              children: [
                _buildListTile('Calcium', valueFood?.calcium, 'mg', _microColor),
                _buildListTile('Cholesterol', valueFood?.cholesterol, 'mg', _microColor),
                _buildListTile('Iron', valueFood?.iron, 'mg', _microColor),
                _buildListTile('Potassium', valueFood?.potassium, 'mg', _microColor),
                _buildListTile('Sodium', valueFood?.sodium, 'mg', _microColor),
              ],
            ),
            const SizedBox(height: 24),

            // Vitamins iOS List Group
            _buildSectionHeader("VITAMINS"),
            _iOSListGroup(
              children: [
                _buildListTile('Vitamin A', valueFood?.vitaminA, 'µg', Colors.purple.shade400),
                _buildListTile('Vitamin C', valueFood?.vitaminC, 'mg', Colors.purple.shade400),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Segment Header Title
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
    );
  }

  // Wrapper mimicking Apple's grouped layout setting
  Widget _iOSListGroup({required List<Widget> children}) {
    List<Widget> dividedChildren = [];
    for (int i = 0; i < children.length; i++) {
      dividedChildren.add(children[i]);
      if (i != children.length - 1) {
        dividedChildren.add(
          const Padding(
            padding: EdgeInsets.only(left: 44.0), // Keeps lines alignment matching text offset
            child: Divider(color: _separator, height: 1, thickness: 0.5),
          ),
        );
      }
    }

    return SpringButton(

      SpringButtonType.onlyScale,
      onTap: (){},
      uiChild: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: dividedChildren),
      ),
    );
  }

  // Sleek row replacing blocky material cards
  Widget _buildListTile(String title, double? value, String unit, Color indicatorColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        children: [
          // Dot indicator representing macro breakdown
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: indicatorColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          Text(
            value != null ? "${value.toStringAsFixed(1)}$unit" : "0.0$unit",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom iOS Chevron Back button wrapper
class CupertinoBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CupertinoBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.blue, // iOS blue default call-to-action color
          size: 20,
        ),
      ),
    );
  }
}