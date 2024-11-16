import 'dart:developer';

import 'package:ahealth/presentation/chatscreen.dart';
import 'package:ahealth/presentation/nutritionpage.dart';

import '../blocs/height/height_cubit.dart';
import '../blocs/initialized/init_app_cubit.dart';
import '../blocs/nutrition/nutrition_cubit.dart';
import '../blocs/sleep/sleep_cubit.dart';
import '../blocs/water/water_cubit.dart';
import '../blocs/weight/weight_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/step/step_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> loadData(BuildContext context) async {
    context.read<StepsCubit>().getStepData();
    context.read<SleepCubit>().getSleepData();
    context.read<WaterCubit>().getWaterData();
    context.read<WeightCubit>().getWeightData();
    context.read<HeightCubit>().getHeight();
    context.read<NutritionCubit>().getNutritionData();
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
                if(weight!=null){
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
                  onPressed: () async{
                    if(from!=null && to!=null){
                      if(from!.isBefore(to!)){
                        Duration difference = to!.difference(from!);
                        int minutesDifference = difference.inMinutes.abs();
                        log("minutesDifference: $minutesDifference");
                        context.read<SleepCubit>().addSleep(startingTime: from!, endTime: to!);
                        Navigator.pop(context);
                      }else{
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
                if(height!=null){
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<InitAppCubit, InitAppState>(
        listener: (context, state) {
          if (state is InitAppLoading) {
            // Show loading dialog
            showCustomDialog(
              context: context,
              title: "Loading...",
              message: "Please wait while we load data.",
            );
          } else if (state is InitAppPermissionNotAvailable) {
            // Show permission dialog
            showCustomDialog(
              context: context,
              title: "Permission Error",
              message: "Required permissions are not available.",
              onPressed: () async {
                await context.read<InitAppCubit>().checkPermissions();
              },
            );
          } else if (state is InitAppSdkUnavailable) {
            // Show SDK unavailable dialog
            showCustomDialog(
                context: context,
                title: "SDK Unavailable",
                message:
                    "SDK is unavailable. Please install heath connect app.",
                onPressed: () async {
                  await context.read<InitAppCubit>().installHealthConnect();
                });
          } else if (state is InitAppFailed) {
            // Show failure dialog
            showCustomDialog(
                context: context,
                title: "Failed",
                message: "Initialization failed. Please try again.");
          } else if (state is InitAppSuccess) {
            loadData(context);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                //steps
                Container(
                  margin:const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  width: double.maxFinite,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color.fromARGB(255, 255, 242, 204),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Steps"),
                      BlocBuilder<StepsCubit, StepsState>(
                        builder: (context, state) {
                          if (state is StepLoadingState) {
                            return const CupertinoActivityIndicator(); // Default case
                          } else if (state is StepFailed) {
                            if (state.errorMessage == "NULL")
                              return const Text('0');
                            return Text(state.errorMessage);
                          } else if (state is StepSuccessState) {
                            num noOfSteps = 0;
                            for (final step in state.stepModel) {
                              if (step.value != null) {
                                // log("step "+step.value!.numericValue.toString());
                                noOfSteps += step.value!.numericValue ?? 0;
                              }
                            }
                            return Text(
                                "$noOfSteps  from platform ${state.stepModel.isNotEmpty ? state.stepModel[0].sourcePlatform : ''}");
                          } else {
                            return Text("unknown state ${state.toString()}");
                          }
                        },
                      )
                    ],
                  ),
                ),
                //sleep
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 242, 204),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: IconButton(onPressed: (){
                      context.read<SleepCubit>().deleteToadySleepData();
                    }, icon: const Icon(Icons.delete_outline_rounded,color: Colors.red,)),
                    title: const Text("Sleep"),
                    subtitle: BlocBuilder<SleepCubit, SleepState>(
                      builder: (context, state) {
                        if (state is SleepLoadingState) {
                          return const CupertinoActivityIndicator(); // Default case
                        } else if (state is SleepFailedState) {
                          return const Text('failed to load steps');
                        } else if (state is SleepSuccessState) {
                          num sleepTimeInMinutes = 0;
                          for (final step in state.sleepModel) {
                            if (step.value != null) {
                              sleepTimeInMinutes +=
                                  step.value!.numericValue ?? 0;
                            }
                          }
                          return Text(
                              "${(sleepTimeInMinutes / 60).toStringAsFixed(2)} hours");
                        } else {
                          return Text("unknown state ${state.toString()}");
                        }
                      },
                    ),
                    trailing: IconButton(
                        onPressed: () async {
                          showSleepDialog(context);
                          // bool isAdded = await context.read<WaterCubit>().addWater(waterInLiter: 0.25);
                          // if (isAdded) {
                          //   context.read<WaterCubit>().getWaterData();
                          // }
                        },
                        icon: const Icon(Icons.add)),
                  ),
                ),
                //water
                Container(
                  margin:const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 242, 204),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: IconButton(onPressed: (){
                      context.read<WaterCubit>().decreaseLastWaterData();
                    }, icon: const Icon(Icons.minimize_rounded)),
                    title: const Text("Water"),
                    subtitle: BlocBuilder<WaterCubit, WaterState>(
                      builder: (context, state) {
                        if (state is WaterLoadingState) {
                          return const CupertinoActivityIndicator(); // Default case
                        } else if (state is WaterFailed) {
                          // log('error in water load',error: state.errorMessage);
                          if (state.errorMessage == "NULL") {
                            return const Text('0 Liter');
                          } else {
                            return Text(state.errorMessage);
                          }
                        } else if (state is WaterSuccessState) {
                          num waterInLiter = 0;
                          for (final water in state.waterModel) {
                            if (water.value != null) {
                              waterInLiter += water.value!.numericValue ?? 0;
                            }
                          }
                          return Text(
                              "${(waterInLiter).toStringAsFixed(2)} Liter");
                        } else {
                          return Text("unknown state ${state.toString()}");
                        }
                      },
                    ),
                    trailing: IconButton(
                        onPressed: () {
                           context.read<WaterCubit>().addWater(waterInLiter: 0.25);
                        },
                        icon: const Icon(Icons.add)),
                  ),
                ),
                //weight
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 242, 204),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: const Text("Weight"),
                    subtitle: BlocBuilder<WeightCubit, WeightState>(
                      builder: (context, state) {
                        if (state is WeightLoading) {
                          return const CupertinoActivityIndicator(); // Default case
                        } else if (state is WeightFailed) {
                          // log('error in water load',error: state.errorMessage);

                          return Text(state.errorMessage);
                        } else if (state is WeightSuccess) {
                          // num weight=0;
                          // for(final water in state.weightModel){
                          //   if(water.value!=null){
                          //     waterInLiter+=water.value!.numericValue??0;
                          //   }
                          // }
                          log(state.weightModel[0].value!.numericValue
                              .toString());
                          if (state.weightModel.isNotEmpty) {
                            return Text(
                              state.weightModel[0].value != null
                                  ? ("${state.weightModel[0].value!.numericValue} ${state.weightModel[0].unit}")
                                  : '0 Kg',
                            );
                          }
                          return const Text("No Weight Data");
                        } else {
                          return Text("unknown state ${state.toString()}");
                        }
                      },
                    ),
                    trailing: IconButton(
                        onPressed: () async {
                          showWeightDialog(context);
                          // bool isAdded =await context.read<WeightCubit>().addWeight(wrightInKg: 0.25);
                          // if(isAdded){
                          //   context.read<WeightCubit>().getWeightData();
                          // }
                        },
                        icon: const Icon(Icons.add)),
                  ),
                ),
                // height
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 242, 204),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: const Text("Height"),
                    subtitle: BlocBuilder<HeightCubit, HeightState>(
                      builder: (context, state) {
                        if (state is HeightLoading) {
                          return const CupertinoActivityIndicator(); // Default case
                        } else if (state is HeightFailed) {
                          // log('error in water load',error: state.errorMessage);

                          return Text(state.errorMessage);
                        } else if (state is HeightSuccess) {
                          if (state.heightModel.isNotEmpty) {
                            return Text(state.heightModel[0].value != null
                                ? ("${(state.heightModel[0].value!.numericValue)?.toStringAsFixed(2)} ${state.heightModel[0].unit}")
                                : 'UNKNOWN');
                          }
                          return const Text("No Height Data");
                        } else {
                          return Text("unknown state ${state.toString()}");
                        }
                      },
                    ),
                    trailing: IconButton(
                        onPressed: () async {
                          showHeightDialog(context);
                          // bool isAdded =await context.read<WeightCubit>().addWeight(wrightInKg: 0.25);
                          // if(isAdded){
                          //   context.read<WeightCubit>().getWeightData();
                          // }
                        },
                        icon: const Icon(Icons.add)),
                  ),
                ),
                //Nutrition
                Container(
                  margin:const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 242, 204),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: const Text("Nutrition"),
                    subtitle: BlocBuilder<NutritionCubit, NutritionState>(
                      builder: (context, state) {
                        if (state is NutritionLoading) {
                          return const CupertinoActivityIndicator(); // Default case
                        } else if (state is NutritionFailed) {
                          // log('error in water load',error: state.errorMessage);
                          return Text(state.errorMessage);
                        } else if (state is NutritionSuccess) {
                          if (state.nutritionModel.isNotEmpty) {
                            return Column(
                              children: List.generate(
                                state.nutritionModel.length,
                                (index) {
                                  return Text(
                                      '${state.nutritionModel[index].value?.name ?? ""}\ncalories ${state.nutritionModel[index].value!.calories?.toStringAsFixed(2)}, protein ${state.nutritionModel[index].value!.protein?.toStringAsFixed(2)}, fat ${state.nutritionModel[index].value!.fat?.toStringAsFixed(2)}, carbs ${state.nutritionModel[index].value!.carbs?.toStringAsFixed(2)},');
                                },
                              ),
                            );
                          }
                          return const Text("No Weight Data");
                        } else {
                          return Text("unknown state ${state.toString()}");
                        }
                      },
                    ),
                    trailing: IconButton(
                        onPressed: ()  {
                          Navigator.push(context, MaterialPageRoute(builder: (_)=>const NutritionPage()));
                        },
                        icon: const Icon(Icons.add)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: IconButton.filledTonal(onPressed: (){}, icon: const Icon(CupertinoIcons.home)),label: "home"),
          BottomNavigationBarItem(icon: IconButton.filledTonal(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=>const ChatScreen()));
          }, icon: const Icon(CupertinoIcons.chat_bubble_fill)),label: "chat"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // final now = DateTime.now();
          // final midnight = DateTime(now.year, now.month, now.day);
          // List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
          //   types: [HealthDataType.NUTRITION],
          //   startTime: midnight,
          //   endTime: now,
          // );
          // if(healthData.isNotEmpty){
          //   log(healthData[0].toJson().toString());
          // }else{
          //   log("its empty");
          // }
          loadData(context);
        },
        child: const Icon(Icons.refresh),
      ),
    );
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
}
