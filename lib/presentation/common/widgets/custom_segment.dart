import 'dart:ui';

import 'package:ahealth/appcolors.dart';
import 'package:flutter/material.dart';

import '../../../common/spring_button_widget.dart';

class CustomSlidingSegmentedControl extends StatelessWidget {
  final int currentSelection;
  final List<String> children;
  final Function(int) onValueChanged;
  final Color thumbColor;

  const CustomSlidingSegmentedControl({
    super.key,
    required this.currentSelection,
    required this.children,
    required this.onValueChanged,
    this.thumbColor = primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.3);

    final Color textColor = isDark ? Colors.white : Colors.black;

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double itemWidth = width / children.length;

        return ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: width,
              height: 52,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Stack(
                children: [
                  // Sliding Thumb
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment(
                      (currentSelection * 2 / (children.length - 1)) - 1,
                      0,
                    ),
                    child: Container(
                      width: itemWidth - 8,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: thumbColor,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: thumbColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Labels
                  Row(
                    children: List.generate(children.length, (index) {
                      bool isSelected = currentSelection == index;
                      return Expanded(
                        child: SpringButton(
                          SpringButtonType.withOpacity,
                          onTap: () => onValueChanged(index),
                          uiChild: Center(
                            child: Text(
                              children[index],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : textColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
