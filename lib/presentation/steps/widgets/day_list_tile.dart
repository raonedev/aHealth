import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import 'step_point.dart';

class DayListTile extends StatelessWidget {
  final StepPoint point;
  final VoidCallback onTap;

  const DayListTile({super.key, required this.point, required this.onTap});

  String _fmt(double v) => NumberFormat('#,###').format(v.round());

  @override
  Widget build(BuildContext context) {
    final hit = point.steps >= point.target;
    final pct = (point.steps / point.target).clamp(0.0, 1.0);
    final dayLabel =
        '${DateFormat('EEEE, dd MMMM').format(point.date)}, '
        '${_fmt(point.steps)} steps';

    return Semantics(
      container: true,
      button: true,
      label: dayLabel,
      hint: 'Opens hourly step details',
      sortKey: OrdinalSortKey(-point.date.millisecondsSinceEpoch.toDouble()),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 8),
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: hit
                            ? const Color(0xFFEAF3DE)
                            : const Color(0xFFFAEEDA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.directions_walk_rounded,
                        color: hit
                            ? const Color(0xFF3B6D11)
                            : const Color(0xFF854F0B),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE').format(point.date),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMM').format(point.date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _fmt(point.steps),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3B6D11),
                          ),
                        ),
                        Text(
                          '${(pct * 100).round()}% of goal',
                          style: TextStyle(
                            fontSize: 11,
                            color: hit ? Colors.grey : const Color(0xFF854F0B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 4,
                              backgroundColor: const Color(0xFFEEEEEE),
                              valueColor: AlwaysStoppedAnimation(
                                hit
                                    ? const Color(0xFF639922)
                                    : const Color(0xFFEF9F27),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const HugeIcon(icon:HugeIcons.strokeRoundedArrowRight01, color: Color(0xFFBDBDBD), size: 20,),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
