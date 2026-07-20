import 'dart:ui';

import 'package:ahealth/presentation/nutririon/widgets/food_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/nutrition_model.dart';

const Color _surface = Color(0xFFFFFFFF);
const Color _textPrimary = Color(0xFF1A1A1A);
const Color _textSecondary = Color(0xFF757575);

// ─── Card Item Widget ────────────────────────────────────────────────────────

class GroupFoodCard extends StatelessWidget {
  final NutritionModel item;
  final VoidCallback onTap;

  const GroupFoodCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Food image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FoodImage(item: item),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.value?.name ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _MacroTag(
                            icon: Icons.local_fire_department_rounded,
                            color: Colors.orange,
                            label:
                            '${item.value?.calories?.toInt() ?? 0} kcal',
                          ),
                          const SizedBox(width: 8),
                          _MacroTag(
                            icon: Icons.bolt,
                            color: const Color(0xFFE05252),
                            label:
                            '${(item.value?.protein ?? 0).toStringAsFixed(0)}g',
                          ),
                          const SizedBox(width: 8),
                          _MacroTag(
                            icon: Icons.grain,
                            color: const Color(0xFFE0A952),
                            label:
                            '${(item.value?.carbs ?? 0).toStringAsFixed(0)}g',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: _textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MacroTag extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _MacroTag(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─── Dialog ─────────────────────────────────────────────────────────────────

class GroupFoodDialog extends StatefulWidget {
  final List<NutritionModel> groupItems;

  const GroupFoodDialog({super.key, required this.groupItems});

  @override
  State<GroupFoodDialog> createState() => _GroupFoodDialogState();
}

class _GroupFoodDialogState extends State<GroupFoodDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // Refined to 480ms to match the outBack transition rhythm perfectly
      duration: const Duration(milliseconds: 480),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalKcal = widget.groupItems
        .fold<int>(0, (s, i) => s + (i.value?.calories?.toInt() ?? 0));
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
    
                  // Summary header card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                                Icons.local_fire_department_rounded,
                                color: Colors.orange,
                                size: 28),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Energy",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: _textSecondary,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "$totalKcal kcal",
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                    letterSpacing: -0.5),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${widget.groupItems.length} items',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: _textSecondary,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
    
                  // Animated list
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight:
                      MediaQuery.of(context).size.height * 0.45,
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      shrinkWrap: true,
                      itemCount: widget.groupItems.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final item = widget.groupItems[i];
                        return _AnimatedCard(
                          index: i,
                          controller: _controller,
                          child: GroupFoodCard(
                            item: item,
                            onTap: () {
                              context.pop();
                              context.push('/nutrition/detail',
                                  extra: item);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Optimized Animated Wrapper ─────────────────────────────────────────────

class _AnimatedCard extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const _AnimatedCard({
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Limits cascading lag offsets to prevent squeezing late-items animations
    final double start = (index * 0.07).clamp(0.0, 0.35);
    final double end = (start + 0.65).clamp(0.0, 1.0);

    final curve = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeInCubic),
    );

    return AnimatedBuilder(
      animation: curve,
      child: child, // Performance critical: Caches card layer so layout avoids repeating ticks
      builder: (context, cachedChild) {
        return Transform.scale(
          scale: 0.88 + (0.12 * curve.value), // Subtler range for premium material movement
          child: Opacity(
            opacity: curve.value.clamp(0.0, 1.0),
            child: cachedChild,
          ),
        );
      },
    );
  }
}