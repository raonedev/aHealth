import 'dart:developer';
// import 'package:ahealth/config/appenums.dart';
import 'package:ahealth/presentation/chartscreen.dart';
import 'package:ahealth/presentation/searchscreen.dart';
import 'package:health/health.dart';

import 'chatscreen.dart';
import 'nitritiondetailscreen.dart';
import 'nutritionpage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchScreen())),
              icon: const Icon(CupertinoIcons.search))
        ],
      ),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: MasonryGridView(
              gridDelegate:
                  const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns
              ),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                //steps
                healthCard(
                  healthType: HealthDataType.STEPS,
                  context: context,
                  title: 'Steps',
                  lottieString: 'assets/lottieanimations/walkingmen.json',
                  cubit: BlocBuilder<StepsCubit, StepsState>(
                    builder: (context, state) {
                      if (state is StepLoadingState) {
                        return const CupertinoActivityIndicator(); // Default case
                      } else if (state is StepFailed) {
                        if (state.errorMessage == "NULL") {
                          return const Text('0');
                        }
                        return Text(state.errorMessage);
                      } else if (state is StepSuccessState) {
                        num noOfSteps = 0;
                        for (final step in state.stepModel) {
                          if (step.value != null) {
                            // log("step "+step.value!.numericValue.toString());
                            noOfSteps += step.value!.numericValue ?? 0;
                          }
                        }
                        // return Text("$noOfSteps  from platform ${state.stepModel.isNotEmpty ? state.stepModel[0].sourcePlatform : ''}");
                        return Text('$noOfSteps');
                      } else {
                        return Text("unknown state ${state.toString()}");
                      }
                    },
                  ),
                ),
                //Nutrition

                healthCard(
                  healthType: HealthDataType.NUTRITION,
                  context: context,
                  title: 'Nutrition',
                  lottieString: 'assets/lottieanimations/food.json',
                  cubit: BlocBuilder<NutritionCubit, NutritionState>(
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
                                return ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NutritionDetailScreen(nutritionModel: state.nutritionModel[index]),
                                      ),
                                    );
                                  },
                                  title: Text(state.nutritionModel[index].value?.name ?? ""),
                                  subtitle: Text("calories ${state.nutritionModel[index].value!.calories?.toStringAsFixed(2)}"),
                                );
                                //return Text('${state.nutritionModel[index].value?.name ?? ""}\ncalories ${state.nutritionModel[index].value!.calories?.toStringAsFixed(2)}, protein ${state.nutritionModel[index].value!.protein?.toStringAsFixed(2)}, fat ${state.nutritionModel[index].value!.fat?.toStringAsFixed(2)}, carbs ${state.nutritionModel[index].value!.carbs?.toStringAsFixed(2)},');
                              },
                            ),
                          );
                        }
                        return const Text("No Nutrition Data");
                      } else {
                        return Text("unknown state ${state.toString()}");
                      }
                    },
                  ),
                  onAdd: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const NutritionPage())),
                ),

                //water
                healthCard(
                  healthType: HealthDataType.WATER,
                  context: context,
                  title: "Water",
                  lottieString:
                      'assets/lottieanimations/girl_drinking_water.json',
                  cubit: BlocBuilder<WaterCubit, WaterState>(
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
                  onAdd: () {
                    context.read<WaterCubit>().addWater(waterInLiter: 0.25);
                  },
                ),

                //weight
                healthCard(
                  healthType: HealthDataType.WEIGHT,
                  context: context,
                  title: 'Weight',
                  lottieString: 'assets/lottieanimations/weightscale.json',
                  cubit: BlocBuilder<WeightCubit, WeightState>(
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
                                ? ("${state.weightModel[0].value!.numericValue} Kg")
                                : '0 Kg',
                          );
                        }
                        return const Text("No Weight Data");
                      } else {
                        return Text("unknown state ${state.toString()}");
                      }
                    },
                  ),
                  onAdd: () => showWeightDialog(context),
                ),

                // height
                healthCard(
                  healthType: HealthDataType.HEIGHT,
                  context: context,
                  title: 'Height',
                  lottieString: 'assets/lottieanimations/pullup.json',
                  cubit: BlocBuilder<HeightCubit, HeightState>(
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
                  onAdd: () => showHeightDialog(context),
                ),
                //sleep
                healthCard(
                  healthType: HealthDataType.SLEEP_SESSION,
                  context: context,
                  title: "Sleep Session",
                  lottieString: 'assets/lottieanimations/sleep.json',
                  cubit: BlocBuilder<SleepCubit, SleepState>(
                    builder: (context, state) {
                      if (state is SleepLoadingState) {
                        return const CupertinoActivityIndicator(); // Default case
                      } else if (state is SleepFailedState) {
                        return const Text('failed to load steps');
                      } else if (state is SleepSuccessState) {
                        num sleepTimeInMinutes =
                            state.sleepModel[0].value?.numericValue ?? 0;
                        // for (final step in state.sleepModel) {
                        //   log(step.value!.numericValue.toString());
                        //   if (step.value != null) {
                        //     sleepTimeInMinutes += step.value!.numericValue ?? 0;
                        //   }
                        // }
                        return Text(
                            "${(sleepTimeInMinutes / 60).toStringAsFixed(2)} hours");
                      } else {
                        return Text("unknown state ${state.toString()}");
                      }
                    },
                  ),
                  onAdd: () {
                    log("sleep");
                    showSleepDialog(context);
                  },
                ),
                //WORKOUT
                healthCard(
                    healthType: HealthDataType.WORKOUT,
                    title: 'Workout',
                    lottieString: 'assets/lottieanimations/workout.json',
                    cubit: const Text("Comming Soon"),
                    context: context)
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ChatScreen())),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Image.asset('assets/icons/img_1.png', width: 50),
          ),
        ),
      ),
    );
  }

  Widget healthCard({
    required String title,
    required String lottieString,
    required Widget cubit,
    required BuildContext context,
    required HealthDataType healthType,
    VoidCallback? onAdd,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ChartScreen(
                    healthType: healthType,
                  ))),
      child: Stack(
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 200, minWidth: 400),
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 242, 204),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Lottie.asset(
                    lottieString,
                  ),
                ),
                Text(title),
                cubit,
              ],
            ),
          ),
          onAdd != null
              ? Positioned(
                  bottom: 10,
                  right: 0,
                  child: IconButton(
                      onPressed: () {
                        log("onADD");
                        onAdd();
                      },
                      icon: const Icon(Icons.add)))
              : const SizedBox(),
        ],
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
