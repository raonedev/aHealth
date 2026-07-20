import 'dart:developer' as dev;
import 'dart:ui';

import 'package:ahealth/appcolors.dart';
import 'package:ahealth/constants.dart';
import 'package:ahealth/presentation/chat/chat.dart';
import 'package:ahealth/presentation/nutririon/fooddetailscreen.dart';
import 'package:ahealth/presentation/home.dart';
import 'package:ahealth/presentation/home/home_widget.dart';
import 'package:ahealth/presentation/nutririon/nutrition.dart';
import 'package:ahealth/presentation/onboarding/getstartingscreen.dart';
import 'package:ahealth/presentation/onboarding/onboardingscreen.dart';
import 'package:ahealth/presentation/onboarding/permissionerror.dart';
import 'package:ahealth/presentation/onboarding/sdk_error.dart';
import 'package:ahealth/presentation/profileinfo/health_detail.dart';
import 'package:ahealth/presentation/searchscreen.dart';
import 'package:ahealth/presentation/water/water.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/initialized/init_app_cubit.dart';
import 'features/step_tracking/presentation/views/tracking_view.dart';
import 'helper/helper_func.dart';
import 'helper/model_router.dart';
import 'models/nutrition_model.dart';
import 'presentation/nutririon/nitritiondetailscreen.dart';
import 'presentation/nutririon/widgets/nutrition_group_dialog.dart';
import 'presentation/steps/step_chart_screen.dart';
import 'presentation/water/charts/water_chart_screen.dart';

class AppRoutes {
  static const String getStart = "/";
  static const String permissionError = "/permissionError";
  static const String sdkError = "/sdkError";
  static const String onBoarding = "/onBoarding";
  static const String heathDetail = "/heathDetail";
  static const String home = "/home";
  static const String searchFoodScreen = "/searchFood";
  static const String stepChartScreen = "/chart/step";
  static const String waterChartScreen = "/chart/water";

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: getStart,
    routes: [
      GoRoute(
        path: getStart,
        builder: (context, state) {
          return BlocBuilder<InitAppCubit, InitAppState>(
            builder: (context, state) {
              if (state is InitAppLoading) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      color: primary,
                    ),
                  ),
                );
              } else if (state is InitAppPermissionNotAvailable) {
                return const PermissionErrorScreem();
              } else if (state is InitAppSdkUnavailable) {
                return const SdkErrorScreen();
              } else if (state is InitAppFailed) {
                return Scaffold(
                  body: Center(
                    child: Text(
                      'Permission Error : $state',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: red,
                          ),
                    ),
                  ),
                );
              } else if (state is InitAppSuccess) {
                loadData(context);
                Future<bool> checkOnboardingStatus() async {
                  final prefs = await SharedPreferences.getInstance();
                  return prefs.getBool(isOnBoardingSharedPreferenceKey) ??
                      false;
                }

                return FutureBuilder<bool>(
                  future: checkOnboardingStatus(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      dev.log(" checkOnboardingStatus waiting");
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(
                            color: primary,
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      dev.log(" checkOnboardingStatus hasError");
                      // return Text('Error loading onboarding status: ${snapshot.error}');
                      return const GetStartingScreen();
                    } else {
                      dev.log(" checkOnboardingStatus sucess");
                      final hasSeenOnboarding = snapshot.data ?? false;
                      if (hasSeenOnboarding) {
                        dev.log(" hasSeenOnboarding sucess");
                        WidgetsBinding.instance.addPostFrameCallback(
                            (_) => context.go('/shell/home'));
                        return const Scaffold(
                            body: Center(
                                child:
                                    CircularProgressIndicator(color: primary)));
                      } else {
                        dev.log(" hasSeenOnboarding fail");
                        return const GetStartingScreen();
                      }
                    }
                  },
                );
              } else {
                return const GetStartingScreen();
              }
            },
          );
        },
      ),
      GoRoute(
        path: permissionError,
        builder: (context, state) => const PermissionErrorScreem(),
      ),
      GoRoute(
        path: sdkError,
        builder: (context, state) => const SdkErrorScreen(),
      ),
      GoRoute(
        path: onBoarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: heathDetail,
        builder: (context, state) => const HeathDetailScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/shell/home',
            pageBuilder: (c, s) => const NoTransitionPage(child: HomeWidget()),
          ),
          GoRoute(
              path: '/shell/water',
              pageBuilder: (c, s) =>
                  const NoTransitionPage(child: WaterWidget())),
          GoRoute(
            path: '/shell/nutrition',
            pageBuilder: (c, s) => const NoTransitionPage(child: Nutrition()),
            routes: [
              GoRoute(
                  path: 'search', builder: (c, s) => const SearchFoodScreen()),
              GoRoute(
                  path: 'foodDetail/:foodId',
                  builder: (c, s) =>
                      FoodDetailScreen(foodId: s.pathParameters['foodId']!)),
            ],
          ),
          GoRoute(
              path: '/shell/chat',
              pageBuilder: (c, s) =>
                  const NoTransitionPage(child: ChatWidget())),
        ],
      ),
      GoRoute(
        path: '/nutrition/detail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (c, s) => NutritionDetailScreen(
          nutritionModel: s.extra as NutritionModel,
        ),
      ),
      GoRoute(
        path: searchFoodScreen,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SearchFoodScreen(),
      ),
      GoRoute(
        path: '/foodDetail/:foodId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => FoodDetailScreen(
          foodId: state.pathParameters['foodId']!,
        ),
      ),
      GoRoute(
        path: GroupFoodDialog.name,
        pageBuilder: (context, state) {
          final groupItems = state.extra as List<NutritionModel>;
          return ModalSheetPage(
            builder: (_) => BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: GroupFoodDialog(groupItems: groupItems)),
          );
        },
      ),
      GoRoute(
        path: stepChartScreen,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const StepChartScreen(),
      ),
      GoRoute(
        path: waterChartScreen,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const WaterChartScreen(),
      ),
      GoRoute(
        path: StepsTrackingView.name,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const StepsTrackingView(),
      ),
    ],
  );
}
