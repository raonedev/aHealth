import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SleepPickerBottomSheet extends StatefulWidget {
  const SleepPickerBottomSheet({super.key});

  @override
  State<SleepPickerBottomSheet> createState() => _SleepPickerBottomSheetState();
}

class _SleepPickerBottomSheetState extends State<SleepPickerBottomSheet> {
  double _startTime = 20.916;
  double _endTime = 7.166;

  String _formatTimeText(double value) {
    int totalMinutes = (value * 60).round();
    int hours = (totalMinutes ~/ 60) % 24;
    int minutes = totalMinutes % 60;

    String period = hours >= 12 ? 'PM' : 'AM';
    int displayHour = hours % 12;
    if (displayHour == 0) displayHour = 12;

    String minuteStr = minutes < 10 ? '0$minutes' : '$minutes';
    return '$displayHour:$minuteStr $period';
  }

  String _calculateTotalSleep() {
    double duration;
    if (_endTime >= _startTime) {
      duration = _endTime - _startTime;
    } else {
      duration = (24.0 - _startTime) + _endTime;
    }

    int totalMinutes = (duration * 60).round();
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    return '$hours hr $minutes min';
  }

  @override
  Widget build(BuildContext context) {
    // --- FIX: Wrap widget forces the sheet to only take its required space ---
    return Wrap(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Hugs content vertically
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header actions row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: Color(0xff0A84FF), fontSize: 16)),
                      ),
                      const Text(
                        'Edit Your Schedule',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done', style: TextStyle(color: Color(0xff0A84FF), fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Bedtime and Wake Up',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Container containing both dynamic texts and YOUR UNCHANGED gauge layout
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xff1C1C1E),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- Dynamic Top Time Headers ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTimeHeader(Icons.single_bed_rounded, 'BEDTIME', _formatTimeText(_startTime), const Color(0xff63E6E2)),
                            _buildTimeHeader(Icons.alarm_rounded, 'WAKE UP - NO ALARM', _formatTimeText(_endTime), const Color(0xffAEAEB2)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // --- YOUR EXACT UNCHANGED SfRadialGauge UI ---
                        SizedBox(
                          height: 400,
                          width: 400,
                          child: SfRadialGauge(
                            axes: [
                              RadialAxis(
                                minimum: 0,
                                maximum: 24,
                                startAngle: 270,
                                endAngle: 270,
                                showLabels: true,
                                onLabelCreated: (label) {
                                  final int v = int.tryParse(label.text) ?? -1;
                                  if (v == 0 || v == 24) {
                                    label.text = '12AM';
                                  } else if (v == 6) {
                                    label.text = '6AM  ';
                                  } else if (v == 12) {
                                    label.text = '12PM';
                                  } else if (v == 18) {
                                    label.text = '  6PM';
                                  } else {
                                    if (v > 12) {
                                      label.text = (v - 12).toString();
                                    } else {
                                      label.text = v.toString();
                                    }
                                  }
                                },
                                axisLabelStyle: const GaugeTextStyle(color: Colors.white),
                                axisLineStyle: const AxisLineStyle(
                                    thickness: 42, color: Colors.black),
                                minorTicksPerInterval: 3,
                                majorTickStyle: const MajorTickStyle(
                                  length: 5,
                                  thickness: 2,
                                  color: Colors.grey,
                                ),
                                minorTickStyle: const MinorTickStyle(
                                    length: 2, thickness: 1.5, color: Colors.grey),
                                tickOffset: 0,
                                ranges: [
                                  GaugeRange(
                                    startValue: _startTime,
                                    endValue: _endTime,
                                    sizeUnit: GaugeSizeUnit.logicalPixel,
                                    startWidth: 30,
                                    endWidth: 30,
                                    rangeOffset: 6,
                                    color: const Color(0xff2C2C2E),
                                  ),
                                  GaugeRange(
                                    startValue: _startTime,
                                    endValue: _endTime,
                                    sizeUnit: GaugeSizeUnit.logicalPixel,
                                    startWidth: 10,
                                    endWidth: 10,
                                    rangeOffset: 16,
                                    gradient: SweepGradient(
                                      colors: List.generate(
                                          180,
                                              (index) => index % 2 == 0
                                              ? Colors.black
                                              : Colors.transparent
                                      ),
                                      stops: List.generate(180, (index) => index / 179),
                                    ),
                                  ),
                                ],
                                pointers: [
                                  MarkerPointer(
                                    value: _startTime,
                                    markerType: MarkerType.circle,
                                    markerHeight: 30,
                                    markerWidth: 30,
                                    color: const Color(0xff1C1C1E),
                                    enableDragging: true,
                                    onValueChanged: (val) {
                                      setState(() {
                                        _startTime = (val * 12).round() / 12;
                                      });
                                      HapticFeedback.selectionClick();
                                    },
                                  ),
                                  MarkerPointer(
                                    value: _endTime,
                                    markerType: MarkerType.circle,
                                    markerHeight: 30,
                                    markerWidth: 30,
                                    color: const Color(0xff1C1C1E),
                                    enableDragging: true,
                                    onValueChanged: (val) {
                                      setState(() {
                                        _endTime = (val * 12).round() / 12;
                                      });
                                      HapticFeedback.selectionClick();
                                    },
                                  ),
                                ],
                                annotations: [
                                  const GaugeAnnotation(
                                    positionFactor: 0.35,
                                    angle: 90,
                                    widget: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.wb_sunny, color: Colors.amber, size: 18),
                                      ],
                                    ),
                                  ),
                                  const GaugeAnnotation(
                                    positionFactor: 0.35,
                                    angle: 270,
                                    widget: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star, color: Colors.cyan, size: 18),
                                      ],
                                    ),
                                  ),
                                  GaugeAnnotation(
                                    positionFactor: 0.85,
                                    angle: (_endTime * 15) - 90,
                                    widget: Image.asset(
                                      'assets/icons/bed.png',
                                      width: 16,
                                      height: 16,
                                      color: Colors.grey,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.king_bed, color: Colors.grey, size: 16),
                                    ),
                                  ),
                                  GaugeAnnotation(
                                    positionFactor: 0.85,
                                    angle: (_startTime * 15) - 90,
                                    widget: Image.asset(
                                      'assets/icons/alarm.png',
                                      width: 16,
                                      height: 16,
                                      color: Colors.grey,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.alarm, color: Colors.grey, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- Dynamic Bold Total Duration Readout ---
                        Text(
                          _calculateTotalSleep(),
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'This schedule meets your sleep goal.',
                          style: TextStyle(color: Color(0xff8E8E93), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeHeader(IconData icon, String label, String value, Color themeColor) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: themeColor, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(color: Color(0xff8E8E93), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.4),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: themeColor == const Color(0xffAEAEB2) ? const Color(0xffAEAEB2) : Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}