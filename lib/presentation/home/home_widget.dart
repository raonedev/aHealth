import 'dart:developer' as dev;

import 'package:ahealth/common/spring_button_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:health/health.dart';
import 'package:lottie/lottie.dart';

import '../../app_routes.dart';
import '../../appcolors.dart';
import '../../blocs/height/height_cubit.dart';
import '../../blocs/nutrition/nutrition_cubit.dart';
import '../../blocs/sleep/sleep_cubit.dart';
import '../../blocs/step/step_cubit.dart';
import '../../blocs/water/water_cubit.dart';
import '../../blocs/weight/weight_cubit.dart';
import '../../helper/helper_func.dart';
import '../chartscreen.dart';
import '../nitritiondetailscreen.dart';
import '../nutririon/widgets/nutrition_card_summary.dart';
import '../water/widgets/water_summary_card.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: MasonryGridView(
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              SpringButton(
                SpringButtonType.withOpacity,
                onTap: () => context.go('/shell/nutrition'),
                uiChild: const NutritionSummaryCard(),
              ),
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
              SpringButton(
                SpringButtonType.withOpacity,
                onTap: () => context.go('/shell/water'),
                uiChild: const WaterSummaryCard(),
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
                  dev.log("sleep");
                  showSleepDialog(context);
                },
              ),
            ],
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
      onTap: () {
        dev.log("/chart/${healthType.name}");
        context.push('/chart/${healthType.name}');
      },
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
                        dev.log("onADD");
                        onAdd();
                      },
                      icon: const Icon(Icons.add)))
              : const SizedBox(),
        ],
      ),
    );
  }
}
