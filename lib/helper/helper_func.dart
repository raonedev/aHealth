import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/height/height_cubit.dart';
import '../blocs/nutrition/nutrition_cubit.dart';
import '../blocs/sleep/sleep_cubit.dart';
import '../blocs/step/step_cubit.dart';
import '../blocs/water/water_cubit.dart';
import '../blocs/weight/weight_cubit.dart';

Future<void> loadData(BuildContext context) async {
  context.read<StepsCubit>().getStepData();
  context.read<SleepCubit>().getSleepData();
  context.read<WaterCubit>().getWaterData();
  context.read<WeightCubit>().getWeightData();
  context.read<HeightCubit>().getHeight();
  context.read<NutritionCubit>().getNutritionData();
}

void showCustomDialog({
  required BuildContext context,
  required String title,
  required String message,
  Future<void> Function()? onPressed,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title), // Title of the dialog
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              // If onPressed is provided, await its execution
              if (onPressed != null) {
                await onPressed();
              }
              if (context.mounted) {
                Navigator.of(context).pop(); // Closes the dialog
              }
            },
            child: const Text('ok'),
          ),
        ],
      );
    },
  );
}

Future showWeightDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      double? weight;
      return CupertinoAlertDialog(
        title: const Text("Enter Weight"),
        content: CupertinoTextField(
          keyboardType: const TextInputType.numberWithOptions(
              signed: false, decimal: true),
          suffix: const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Text("kg"),
          ),
          onChanged: (value) {
            weight = double.tryParse(value);
          },
        ),
        actions: [
          CupertinoDialogAction(
            // isDefaultAction: true,
            child: const Text("Done"),
            onPressed: () {
              if (weight != null) {
                context.read<WeightCubit>().addWeight(wrightInKg: weight!);
              }
              Navigator.pop(context);
            },
          )
        ],
      );
    },
  );
}

Future<DateTime?> selectTime(BuildContext context) async {
  final DateTime? picked = await showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (BuildContext context) {
      DateTime tempPickedDate = DateTime.now();
      return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: tempPickedDate,
                onDateTimeChanged: (DateTime newTime) {
                  tempPickedDate = newTime;
                },
              ),
            ),
            CupertinoButton(
              child: const Text("Select"),
              onPressed: () {
                Navigator.of(context).pop(tempPickedDate);
              },
            )
          ],
        ),
      );
    },
  );

  return picked;
}

Future showSleepDialog(BuildContext context) {
  DateTime? from;
  DateTime? to;

  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return CupertinoAlertDialog(
            title: const Text("Enter Time of Sleep Session"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton.filled(
                  onPressed: () async {
                    from = await selectTime(context);
                    setState(() {});
                  },
                  child: Text(
                    from == null ? "From" : from!.toIso8601String(),
                  ),
                ),
                const SizedBox(height: 20),
                CupertinoButton.filled(
                    onPressed: () async {
                      to = await selectTime(context);
                      setState(() {});
                    },
                    child: Text(to == null ? "To" : to!.toIso8601String())),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text("Done"),
                onPressed: () async {
                  if (from != null && to != null) {
                    if (from!.isBefore(to!)) {
                      Duration difference = to!.difference(from!);
                      int minutesDifference = difference.inMinutes.abs();
                      log("minutesDifference: $minutesDifference");
                      context
                          .read<SleepCubit>()
                          .addSleep(startingTime: from!, endTime: to!);
                      Navigator.pop(context);
                    } else {
                      log("from should be less than to");
                    }
                  }
                  // log("fromTime :${from.toString()} , toTime :${to.toString()}");
                },
              ),
            ],
          );
        },
      );
    },
  );
}

Future showHeightDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (context) {
      double? enteredValue;
      int unit = 0; // 0 = cm, 1 = ft

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter Height",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Enter your height to keep your metrics accurate.",
                    style: TextStyle(fontSize: 17, color: Colors.black87, height: 1.3),
                  ),
                  const SizedBox(height: 20),
                  CupertinoSlidingSegmentedControl<int>(
                    groupValue: unit,
                    children: const {
                      0: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Text("cm"),
                      ),
                      1: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Text("ft"),
                      ),
                    },
                    onValueChanged: (value) {
                      setState(() => unit = value ?? 0);
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Value",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withValues(alpha: 0.85),
                          ),
                        ),
                        const Divider(height: 20, color: Colors.black26),
                        CupertinoTextField(
                          autofocus: true,
                          decoration: const BoxDecoration(),
                          padding: EdgeInsets.zero,
                          placeholder: unit == 0 ? "e.g. 178" : "e.g. 5.9",
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: false, decimal: true),
                          onChanged: (value) {
                            enteredValue = double.tryParse(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _dialogButton(
                          label: "Cancel",
                          background: const Color(0xFFE0E0E0),
                          textColor: Colors.black,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dialogButton(
                          label: "Done",
                          background: const Color(0xFF3B82F6),
                          textColor: Colors.white,
                          onTap: () {
                            if (enteredValue != null) {
                              final heightInMeter = unit == 0
                                  ? enteredValue! / 100
                                  : enteredValue! * 0.3048;
                              context
                                  .read<HeightCubit>()
                                  .addHeight(heightInMeter: heightInMeter);
                            }
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _dialogButton({
  required String label,
  required Color background,
  required Color textColor,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    ),
  );
}
