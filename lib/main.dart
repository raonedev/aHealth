import 'package:ahealth/app_routes.dart';
import 'package:ahealth/apptheme.dart';
import 'package:ahealth/services/chat_hive_service.dart';
import 'package:ahealth/services/notification_services.dart';
import 'package:ahealth/services/nutrition_service.dart';
import 'blocs/charts/sleep_chart/sleep_chart_cubit.dart';
import 'blocs/charts/step_chart/step_chart_cubit.dart';
import 'blocs/charts/water_chart/water_chart_cubit.dart';
import 'blocs/charts/weight_chart/weight_chart_cubit.dart';
import 'blocs/chat/chat_cubit.dart';
import 'blocs/food_scan/food_scan_cubit.dart';
import 'blocs/food_search/food_search_cubit.dart';
import 'package:flutter/services.dart';
import 'blocs/charts/height_chart/height_chart_cubit.dart';
import 'blocs/fooddetail/food_detail_cubit.dart';
import 'blocs/nutrition/nutrition_cubit.dart';
import 'models/chat/chat_message_model.dart';
import 'models/chat/chat_session_model.dart';
import 'models/food_search_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'blocs/height/height_cubit.dart';
import 'blocs/initialized/init_app_cubit.dart';
import 'blocs/sleep/sleep_cubit.dart';
import 'blocs/step/step_cubit.dart';
import 'blocs/water/water_cubit.dart';
import 'blocs/weight/weight_cubit.dart';
import 'models/food_with_servings_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/nutririon/nutrition_group/models/food_scan_group_model.dart'
    show FoodScanGroupAdapter, ValueFoodHiveAdapter;

///dart run build_runner build --delete-conflicting-outputs
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Initialize Hive for Flutter
  Hive.registerAdapter(FoodsAdapter()); // Register the Foods adapter
  Hive.registerAdapter(FoodWithServingsModelAdapter());
  Hive.registerAdapter(FoodAdapter());
  Hive.registerAdapter(ServingsAdapter());
  Hive.registerAdapter(ServingAdapter());
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(ChatSessionAdapter());
  await ChatHiveService.instance.openBoxes();
  // init once in main.dart
  await HealthNotificationService().init();

// Water reminders: 8 AM → 10 PM, every 2 hours
  await HealthNotificationService().scheduleWaterReminders(
    startTime: TimeOfDay(hour: 8, minute: 0),
    endTime: TimeOfDay(hour: 22, minute: 0),
    frequencyHours: 2, // customizable
  );

// Meal reminders (pass null to disable any meal)
  await HealthNotificationService().scheduleMealReminders(
    breakfastTime: TimeOfDay(hour: 8, minute: 0),
    lunchTime: TimeOfDay(hour: 13, minute: 0),
    dinnerTime: TimeOfDay(hour: 19, minute: 30),
  );

  Hive.registerAdapter(FoodScanGroupAdapter());
  Hive.registerAdapter(ValueFoodHiveAdapter());
  await NutritionService.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    // Make the status bar transparent (or use your preferred color)
    statusBarIconBrightness: Brightness.dark,
    // Makes the icons black
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
        BlocProvider(create: (_) => ChatCubit()),
        BlocProvider(create: (_) => FoodScanCubit()),
      ],
      child: MaterialApp.router(
        title: 'A-HealthApp',
        theme: appTheme,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}
