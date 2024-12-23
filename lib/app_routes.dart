import 'package:ahealth/appcolors.dart';
import 'package:ahealth/constants.dart';
import 'package:ahealth/presentation/home.dart';
import 'package:ahealth/presentation/onboarding/getstartingscreen.dart';
import 'package:ahealth/presentation/onboarding/onboardingscreen.dart';
import 'package:ahealth/presentation/onboarding/permissionerror.dart';
import 'package:ahealth/presentation/onboarding/sdk_error.dart';
import 'package:ahealth/presentation/profileinfo/health_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/initialized/init_app_cubit.dart';
import 'helper/helper_func.dart';

class AppRoutes {
  static const String getStart = "/getStart";
  static const String permissionError = "/permissionError";
  static const String sdkError = "/sdkError";
  static const String onBoarding = "/onBoarding";
  static const String heathDetail = "/heathDetail";
  static const String home = "/home";

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
                Future<bool> _checkOnboardingStatus() async {
                  final prefs = await SharedPreferences.getInstance();
                  return prefs.getBool(isOnBoardingSharedPreferenceKey) ??
                      false;
                }

                return FutureBuilder<bool>(
                  future: _checkOnboardingStatus(),
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
                        // Navigate to the HomeScreen
                        return const HomeScreen(); // Replace with your HomeScreen widget
                      } else {
                        // Show the GetStartingScreen
                        return const GetStartingScreen(); // Replace with your GetStartingScreen widget
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
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    // redirect: (context, state) {
    //   final state = context.watch<InitAppCubit>().state;
    //   if (state is InitAppLoading) {
    //     return '/loading';
    //   } else
    //   if (state is InitAppPermissionNotAvailable) {
    //     return permissionError;
    //   } else if (state is InitAppSdkUnavailable) {
    //     return sdkError;
    //   } else if (state is InitAppFailed) {
    //     return null;
    //   } else if (state is InitAppSuccess) {
    //     loadData(context);
    //     return getStart;
    //   } else {
    //     return null;
    //   }
    // },
  );
}
/*

BlocListener<InitAppCubit, InitAppState>(
        listener: (context, state) {
          // if (state is InitAppLoading) {
          //   // Show loading dialog
          //   showCustomDialog(
          //     context: context,
          //     title: "Loading...",
          //     message: "Please wait while we load data.",
          //   );
          // } else 
          if (state is InitAppPermissionNotAvailable) {
            context.go(AppRoutes.permissionError);
          } else if (state is InitAppSdkUnavailable) {
            // Show SDK unavailable dialog
            // showCustomDialog(
            //     context: context,
            //     title: "SDK Unavailable",
            //     message:
            //         "SDK is unavailable. Please install heath connect app.",
            //     onPressed: () async {
            //       await context.read<InitAppCubit>().installHealthConnect();
            //     });
            context.go(AppRoutes.sdkError);
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

*/
