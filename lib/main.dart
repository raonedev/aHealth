import 'package:ahealth/blocs/food_search/food_search_cubit.dart';
import 'package:ahealth/blocs/nutrition/nutrition_cubit.dart';

import 'blocs/height/height_cubit.dart';
import 'blocs/initialized/init_app_cubit.dart';
import 'blocs/sleep/sleep_cubit.dart';
import 'blocs/step/step_cubit.dart';
import 'blocs/water/water_cubit.dart';
import 'blocs/weight/weight_cubit.dart';
import 'presentation/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
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
        BlocProvider(
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

      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
