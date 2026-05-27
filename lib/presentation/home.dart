import 'dart:developer';
import 'dart:ui';
import 'package:ahealth/app_routes.dart';
import 'package:ahealth/appcolors.dart';
import 'package:ahealth/presentation/chartscreen.dart';
import 'package:go_router/go_router.dart';
import 'package:health/health.dart';
import 'package:hugeicons/hugeicons.dart';

import '../helper/helper_func.dart';
import 'chatscreen.dart';
import 'nitritiondetailscreen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import '../blocs/height/height_cubit.dart';
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

  static const String pathName = "/home";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => context.push(AppRoutes.searchScreen),
              icon: const Icon(CupertinoIcons.search))
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: MasonryGridView(
                gridDelegate:
                    const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  healthCard(
                    healthType: HealthDataType.STEPS,
                    context: context,
                    title: 'Steps',
                    lottieString: 'assets/lottieanimations/walkingmen.json',
                    cubit: BlocBuilder<StepsCubit, StepsState>(
                      builder: (context, state) {
                        if (state is StepLoadingState) {
                          return const CupertinoActivityIndicator();
                        } else if (state is StepFailed) {
                          if (state.errorMessage == "NULL") {
                            return const Text('0');
                          }
                          return Text(state.errorMessage);
                        } else if (state is StepSuccessState) {
                          num noOfSteps = 0;
                          for (final step in state.stepModel) {
                            if (step.value != null) {
                              noOfSteps += step.value!.numericValue ?? 0;
                            }
                          }

                          return Text('$noOfSteps');
                        } else {
                          return Text("unknown state ${state.toString()}");
                        }
                      },
                    ),
                  ),
                  healthCard(
                    healthType: HealthDataType.NUTRITION,
                    context: context,
                    title: 'Nutrition',
                    lottieString: 'assets/lottieanimations/food.json',
                    cubit: BlocBuilder<NutritionCubit, NutritionState>(
                      builder: (context, state) {
                        if (state is NutritionLoading) {
                          return const CupertinoActivityIndicator();
                        } else if (state is NutritionFailed) {
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
                                          builder: (context) =>
                                              NutritionDetailScreen(
                                                  nutritionModel: state
                                                      .nutritionModel[index]),
                                        ),
                                      );
                                    },
                                    title: Text(state.nutritionModel[index]
                                            .value?.name ??
                                        ""),
                                    subtitle: Text(
                                        "calories ${state.nutritionModel[index].value!.calories?.toStringAsFixed(2)}"),
                                  );
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
                    onAdd: () => context.push(AppRoutes.nutritionPage),
                  ),
                  healthCard(
                    healthType: HealthDataType.WATER,
                    context: context,
                    title: "Water",
                    lottieString:
                        'assets/lottieanimations/girl_drinking_water.json',
                    cubit: BlocBuilder<WaterCubit, WaterState>(
                      builder: (context, state) {
                        if (state is WaterLoadingState) {
                          return const CupertinoActivityIndicator();
                        } else if (state is WaterFailed) {
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
                  healthCard(
                    healthType: HealthDataType.WEIGHT,
                    context: context,
                    title: 'Weight',
                    lottieString: 'assets/lottieanimations/weightscale.json',
                    cubit: BlocBuilder<WeightCubit, WeightState>(
                      builder: (context, state) {
                        if (state is WeightLoading) {
                          return const CupertinoActivityIndicator();
                        } else if (state is WeightFailed) {
                          return Text(state.errorMessage);
                        } else if (state is WeightSuccess) {
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
                  healthCard(
                    healthType: HealthDataType.HEIGHT,
                    context: context,
                    title: 'Height',
                    lottieString: 'assets/lottieanimations/pullup.json',
                    cubit: BlocBuilder<HeightCubit, HeightState>(
                      builder: (context, state) {
                        if (state is HeightLoading) {
                          return const CupertinoActivityIndicator();
                        } else if (state is HeightFailed) {
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
                  healthCard(
                    healthType: HealthDataType.SLEEP_SESSION,
                    context: context,
                    title: "Sleep Session",
                    lottieString: 'assets/lottieanimations/sleep.json',
                    cubit: BlocBuilder<SleepCubit, SleepState>(
                      builder: (context, state) {
                        if (state is SleepLoadingState) {
                          return const CupertinoActivityIndicator();
                        } else if (state is SleepFailedState) {
                          return const Text('failed to load steps');
                        } else if (state is SleepSuccessState) {
                          num sleepTimeInMinutes =
                              state.sleepModel[0].value?.numericValue ?? 0;

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

          /// bottom navigationbar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: BottomNavigationBar(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        type: BottomNavigationBarType.fixed,
                        selectedItemColor: CupertinoColors.activeBlue,
                        unselectedItemColor: CupertinoColors.systemGrey,
                        showSelectedLabels: true,
                        showUnselectedLabels: true,
                        items: const [
                          BottomNavigationBarItem(
                             icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedHome01,
                            ),
                            label: 'Home',
                          ),
                          BottomNavigationBarItem(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedSoftDrink01,
                            ),
                            label: 'Water',
                          ),
                          BottomNavigationBarItem(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedRiceBowl01,
                            ),
                            label: 'Nutrition',
                          ),
                          BottomNavigationBarItem(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedChat01,
                            ),
                            label: 'Chat',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      // floatingActionButton: SizedBox(
      //   width: 70,
      //   height: 70,
      //   child: GestureDetector(
      //     onTap: () => context.push(AppRoutes.chatScreen),
      //     child: CircleAvatar(
      //       backgroundColor: Colors.white,
      //       child: Image.asset('assets/icons/img_1.png', width: 50),
      //     ),
      //   ),
      // ),
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
              color: white,
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
}
