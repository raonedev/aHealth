import 'package:ahealth/app_routes.dart';
import 'package:ahealth/apptheme.dart';
import 'package:ahealth/presentation/onboarding/permissionerror.dart';
import 'package:go_router/go_router.dart';
import 'blocs/charts/sleep_chart/sleep_chart_cubit.dart';
import 'blocs/charts/step_chart/step_chart_cubit.dart';
import 'blocs/charts/water_chart/water_chart_cubit.dart';
import 'blocs/charts/weight_chart/weight_chart_cubit.dart';
import 'blocs/food_search/food_search_cubit.dart';
import 'package:flutter/services.dart';
import 'blocs/charts/height_chart/height_chart_cubit.dart';
import 'blocs/fooddetail/food_detail_cubit.dart';
import 'blocs/nutrition/nutrition_cubit.dart';
import 'models/FoodSearchModel.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'blocs/height/height_cubit.dart';
import 'blocs/initialized/init_app_cubit.dart';
import 'blocs/sleep/sleep_cubit.dart';
import 'blocs/step/step_cubit.dart';
import 'blocs/water/water_cubit.dart';
import 'blocs/weight/weight_cubit.dart';
import 'models/FoodWithServingsModel.dart';
// import 'presentation/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './helper/helper_func.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Initialize Hive for Flutter
  Hive.registerAdapter(FoodsAdapter()); // Register the Foods adapter
  Hive.registerAdapter(FoodWithServingsModelAdapter());
  Hive.registerAdapter(FoodAdapter());
  Hive.registerAdapter(ServingsAdapter());
  Hive.registerAdapter(ServingAdapter());

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors
        .transparent, // Make the status bar transparent (or use your preferred color)
    statusBarIconBrightness: Brightness.dark, // Makes the icons black
    statusBarBrightness: Brightness.light, // For iOS: ensures compatibility
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => InitAppCubit()..initializeHealthSdk(),
          lazy: false,
        ),
        BlocProvider<StepsCubit>(
          create: (context) => StepsCubit(),
        ),
        BlocProvider(
          create: (context) => SleepCubit(),
        ),
        BlocProvider(
          create: (context) => WaterCubit(),
        ),
        BlocProvider(
          create: (context) => WeightCubit(),
        ),
        BlocProvider(
          create: (context) => HeightCubit(),
        ),
        BlocProvider(
          create: (context) => NutritionCubit(),
        ),
        BlocProvider(
          create: (context) => FoodSearchCubit(),
        ),
        BlocProvider(
          create: (context) => FoodDetailCubit(),
        ),
        BlocProvider(
          create: (context) => StepChartCubit(),
        ),
        BlocProvider(
          create: (context) => HeightChartCubit(),
        ),
        BlocProvider(
          create: (context) => SleepChartCubit(),
        ),
        BlocProvider(
          create: (context) => WaterChartCubit(),
        ),
        BlocProvider(
          create: (context) => WeightChartCubit(),
        ),
      ],
      child: MaterialApp.router(
        title: 'A-HealthApp',
        theme: appTheme,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}
