import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SleepPicker extends StatefulWidget {
  const SleepPicker({super.key});

  @override
  State<SleepPicker> createState() => _SleepPickerState();
}

class _SleepPickerState extends State<SleepPicker> {
  double _startTime = 22.0;
  double _endTime = 6.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1C1C1E),
      appBar: AppBar(
        title: const Text(
          'Sleep',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _startTime.toStringAsFixed(2),
            style: TextStyle(color: Colors.white),
          ),
          Text(
            _endTime.toStringAsFixed(2),
            style: TextStyle(color: Colors.white),
          ),
          Card(
            margin: EdgeInsetsGeometry.all(20),
            color: Color(0xff2C2C2E),
            child: Padding(
              padding: EdgeInsetsGeometry.all(20),
              child: SizedBox(
                height: 400,
                width: 200,
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
                      axisLabelStyle: GaugeTextStyle(color: Colors.white),
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
                      // ranges: [
                      //   GaugeRange(
                      //     startValue: _startTime,
                      //     endValue: _endTime,
                      //     sizeUnit: GaugeSizeUnit.logicalPixel,
                      //     startWidth: 30,
                      //     endWidth: 30,
                      //     rangeOffset: 6,
                      //     color: Color(0xff2C2C2E),
                      //   ),
                      // ],
                      ranges: [
                        // 1. The Background Track (Solid Dark Layer)
                        GaugeRange(
                          startValue: _startTime,
                          endValue: _endTime,
                          sizeUnit: GaugeSizeUnit.logicalPixel,
                          startWidth: 30,
                          endWidth: 30,
                          rangeOffset: 6,
                          color: Color(0xff2C2C2E),
                        ),

                        // 2. The Foreground Track (Your Existing Dashed Layer)
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
                                    ? Colors.black // Stripe color
                                    : Colors
                                        .transparent // Let's the background color show through
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
                          color:  Color(0xff1C1C1E),
                          enableDragging: true,
                          onValueChanged: (val) =>
                              setState(() => _startTime = val),
                        ),
                        MarkerPointer(
                          value: _endTime,
                          markerType: MarkerType.circle,
                          markerHeight: 30,
                          markerWidth: 30,
                          color:  Color(0xff1C1C1E),
                          enableDragging: true,
                          onValueChanged: (val) =>
                              setState(() => _endTime = val),
                        ),
                      ],
                      annotations: [
                        GaugeAnnotation(
                          positionFactor: 0.35,
                          angle: 90,
                          widget: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.wb_sunny,
                                  color: Colors.amber, size: 18),
                            ],
                          ),
                        ),
                        GaugeAnnotation(
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
                          ),
                        ),
                        GaugeAnnotation(
                          positionFactor: 0.85, // Must match your _endTime annotation position
                          angle: (_startTime * 15) - 90, // Dynamically tracks the bedtime handle
                          widget: Image.asset(
                            'assets/icons/alarm.png',
                            width: 16,
                            height: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
