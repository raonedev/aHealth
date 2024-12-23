
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
                Navigator.of(context).pop(); // Closes the dialog
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
      builder: (context) {
        double? height;
        return CupertinoAlertDialog(
          title: const Text("Enter Height"),
          content: CupertinoTextField(
            keyboardType: const TextInputType.numberWithOptions(
                signed: false, decimal: true),
            suffix: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Text("Meter"),
            ),
            onChanged: (value) {
              height = double.tryParse(value);
            },
          ),
          actions: [
            CupertinoDialogAction(
              // isDefaultAction: true,
              child: const Text("Done"),
              onPressed: () {
                if (height != null) {
                  context.read<HeightCubit>().addHeight(heightInMeter: height!);
                }
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
