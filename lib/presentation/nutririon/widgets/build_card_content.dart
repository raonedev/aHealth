import 'package:flutter/material.dart';
import '../../../models/nutrition_model.dart';
import 'package:ahealth/presentation/nutririon/widgets/food_image.dart';
import 'macro_chip.dart';

// Dynamic typography colors optimized to contrast cleanly over dynamic frosted glass textures
const Color _textPrimary = Color(0xFF1C1C1E);
const Color _textSecondary = Color(0xFF636366);

const Color _proteinColor = Color(0xFFFF453A); // iOS Red System Color
const Color _carbsColor = Color(0xFFFF9F0A);   // iOS Orange System Color
const Color _fatColor = Color(0xFF0A84FF);     // iOS Blue System Color

class BuildCardContent extends StatelessWidget {
  const BuildCardContent({
    super.key,
    required this.item,
    required this.count,
    required this.groupItems,
  });

  final NutritionModel item;
  final int count;
  final List<NutritionModel> groupItems;

  @override
  Widget build(BuildContext context) {
    final time = item.dateTo != null
        ? TimeOfDay.fromDateTime(DateTime.parse(item.dateTo!))
        : null;
    final timeStr = time != null
        ? '${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')}${time.period == DayPeriod.am ? 'am' : 'pm'}'
        : '';

    final totalKcal = groupItems.fold<int>(
        0, (sum, i) => sum + (i.value?.calories?.toInt() ?? 0));

    return Row(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FoodImage(item: item),
            ),
            if (count > 1)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      count > 1
                          ? '${item.value?.name ?? ''} +${count - 1} more'
                          : item.value?.name ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: -0.2),
                    ),
                  ),
                  Text(
                    timeStr,
                    style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: _carbsColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$totalKcal kcal',
                    style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  MacroChip(
                      icon: Icons.bolt,
                      color: _proteinColor,
                      value: item.value?.protein ?? 0),
                  const SizedBox(width: 8),
                  MacroChip(
                      icon: Icons.grain,
                      color: _carbsColor,
                      value: item.value?.carbs ?? 0),
                  const SizedBox(width: 8),
                  MacroChip(
                      icon: Icons.water_drop,
                      color: _fatColor,
                      value: item.value?.fat ?? 0),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}