import 'package:ahealth/appcolors.dart';
import 'package:ahealth/constants.dart';
import 'package:ahealth/presentation/chartscreen.dart';
import 'package:ahealth/presentation/chat/chat.dart';
import 'package:ahealth/presentation/chatscreen.dart';
import 'package:ahealth/presentation/fooddetailscreen.dart';
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
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/initialized/init_app_cubit.dart';
import 'helper/helper_func.dart';
import 'presentation/nutritionpage.dart';
import 'presentation/steps/step_chart_screen.dart';

class AppRoutes {
  static const String getStart = "/";
  static const String permissionError = "/permissionError";
  static const String sdkError = "/sdkError";
  static const String onBoarding = "/onBoarding";
  static const String heathDetail = "/heathDetail";
  static const String home = "/home";
  static const String searchScreen = "/searchFood";
  static const String nutritionPage = "/nutritionPage";
  static const String chatScreen = "/ChatScreen";
  static const String stepChartScreen = "/chart/step";

  static final GoRouter router = GoRouter(
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
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(
                            color: primary,
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      // return Text('Error loading onboarding status: ${snapshot.error}');
                      return const GetStartingScreen();
                    } else {
                      final hasSeenOnboarding = snapshot.data ?? false;
                      if (hasSeenOnboarding) {
                        WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/shell/home'));
                        return const Scaffold(body: Center(child: CircularProgressIndicator(color: primary)));
                      } else {
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
            // routes: [
            //   GoRoute(
            //     path: 'chart/:type',
            //     builder: (c, s) => ChartScreen(
            //       healthType: HealthDataType.values.firstWhere(
            //             (e) => e.name == s.pathParameters['type'],
            //       ),
            //     ),
            //   ),
            // ],
          ),
          GoRoute(path: '/shell/water', pageBuilder: (c, s) => const NoTransitionPage(child: WaterWidget())),
          GoRoute(
            path: '/shell/nutrition',
            pageBuilder: (c, s) => const NoTransitionPage(child: Nutrition()),
            routes: [
              GoRoute(path: 'search', builder: (c, s) => const SearchScreen()),
              GoRoute(path: 'foodDetail/:foodId', builder: (c, s) => FoodDetailScreen(foodId: s.pathParameters['foodId']!)),
            ],
          ),
          GoRoute(path: '/shell/chat', pageBuilder: (c, s) => const NoTransitionPage(child: ChatWidget())),
        ],
      ),
      GoRoute(
        path: searchScreen,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: nutritionPage,
        builder: (context, state) => const NutritionPage(),
      ),
      GoRoute(
        path: '/foodDetail/:foodId',
        builder: (context, state) => FoodDetailScreen(
          foodId: state.pathParameters['foodId']!,
        ),
      ),
      GoRoute(
        path: chatScreen,
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: stepChartScreen,
        builder: (context, state) => const StepChartScreen(),
      ),

      GoRoute(
        path: '/chart/:type',
        builder: (c, s) => ChartScreen(
          healthType: HealthDataType.values.firstWhere(
                (e) => e.name == s.pathParameters['type'],
          ),
        ),
      ),
    ],
  );
}