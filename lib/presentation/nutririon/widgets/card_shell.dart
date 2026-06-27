import 'dart:ui';
import 'package:flutter/material.dart';

class CardShell extends StatelessWidget {
  const CardShell({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          // Controls the intensity of the glass frost effect
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: child != null ? const EdgeInsets.all(12) : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // White with low opacity allows background shapes/colors to bleed through
              color: Colors.white.withValues(alpha: 0.45),
              // Simulated light reflection along the dynamic glass border edge
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}