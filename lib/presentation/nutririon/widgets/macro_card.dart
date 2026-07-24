import 'package:flutter/material.dart';

import 'circular_progress.dart';

const Color _card = Color(0xFFFFFFFF); // White cards
const Color _textPrimary = Color(0xFF1A1A1A); // Dark charcoal for primary text
const Color _textSecondary =
Color(0xFF757575); // Muted gray for subtitles/labels
class MacroCard extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;
  final IconData icon;
  final double progress;

  const MacroCard({super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    required this.progress,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${value.toInt()}$unit',
              style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: _textSecondary, fontSize: 11)),
          const SizedBox(height: 10),
          Center(
            child: CircularProgress(
              value: progress,
              color: color,
              size: 52,
              icon: icon,
              iconColor: color,
            ),
          ),
        ],
      ),
    );
  }
}