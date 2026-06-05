import 'package:flutter/material.dart';

class SummaryCards extends StatelessWidget {
  final List<(String, String, bool)> items;
  const SummaryCards({super.key, required this.items});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: items.map((item) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.$1, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(item.$2, style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500,
                  color: item.$3 ? const Color(0xFF3B6D11) : Colors.black87)),
            ]),
          ),
        )).toList(),
      ),
    );
  }
}
