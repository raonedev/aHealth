import 'package:ahealth/blocs/fooddetail/food_detail_cubit.dart';
import 'package:ahealth/blocs/nutrition/nutrition_cubit.dart';

// import 'package:ahealth/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';

import '../models/NutritionModel.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({super.key, required this.foodId});

  final String foodId;

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  @override
  void initState() {
    context.read<FoodDetailCubit>().fetchFoodDetails(widget.foodId);
    super.initState();
  }

  int? selectIndex;
  ValueFood? valueFood;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Serving"),
      ),
      body: BlocBuilder<FoodDetailCubit, FoodDetailState>(
        builder: (context, state) {
          if (state is FoodDetailLoading) {
            return const Center(child: CupertinoActivityIndicator());
          } else if (state is FoodDetailFailed) {
            return Center(child: Text(state.errorMessage));
          } else if (state is FoodDetailSuccess) {
            return Stack(
              children: [
                Column(
                  children: [
                    if (state.foodWithServingsModel.food != null)
                      Text(state.foodWithServingsModel.food!.foodName ??
                          "NULL Name"),
                    if (state.foodWithServingsModel.food != null ||
                        state.foodWithServingsModel.food!.servings != null ||
                        state.foodWithServingsModel.food!.servings!.serving !=
                            null ||
                        state.foodWithServingsModel.food!.servings!.serving!
                            .isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.foodWithServingsModel.food!.servings!
                              .serving!.length,
                          itemBuilder: (context, index) {
                            final serving = state.foodWithServingsModel.food!
                                .servings!.serving![index];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: (selectIndex == null)
                                    ? const Color(0xffe1d4c1)
                                    : (selectIndex == index)
                                        ? Colors.blue
                                        : const Color(0xffe1d4c1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                onTap: () {
                                  if (selectIndex == index) {
                                    setState(() {
                                      selectIndex = null;
                                    });
                                  } else {
                                    setState(() {
                                      selectIndex = index;
                                    });
                                  }
                                },
                                title:
                                    Text(serving.servingDescription ?? 'decs'),
                                subtitle: Text(
                                    "${serving.metricServingAmount} ${serving.metricServingUnit}\ncalories : ${serving.calories} | carbohydrate : ${serving.carbohydrate} | protein : 0.${serving.protein} | \nfat : ${serving.fat} | saturated_fat : ${serving.saturatedFat} | polyunsaturated_fat : ${serving.polyunsaturatedFat} | \ncholesterol : ${serving.cholesterol} | sodium : ${serving.sodium} | potassium : ${serving.potassium} | fiber : ${serving.fiber}"),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
                if (selectIndex != null)
                  Positioned(
                    bottom: 10,
                    right: 0,
                    left: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CupertinoButton.filled(
                        child: const Text(
                          "Add Meal",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          final serving = state.foodWithServingsModel.food!.servings!.serving![selectIndex!];
                          valueFood = ValueFood(
                            name: state.foodWithServingsModel.food!.foodName ??"NULL Name",
                            unit: serving.metricServingUnit,
                            quantity: double.parse(serving.metricServingAmount ?? '0'),
                            calcium: double.parse(serving.calcium ?? '0')/1000,
                            calories: double.parse(serving.calories ?? '0'),
                            carbs: double.parse(serving.carbohydrate ?? '0'),
                            cholesterol:double.parse(serving.cholesterol ?? '0'),
                            fat: double.parse(serving.fat ?? '0'),
                            fiber: double.parse(serving.fiber ?? '0'),
                            iron: double.parse(serving.iron ?? '0')/1000,
                            measurementDescription:serving.measurementDescription,
                            metricServingAmount: serving.metricServingAmount,
                            metricServingUnit: serving.metricServingUnit,
                            monounsaturatedFat:double.parse(serving.monounsaturatedFat ?? '0'),
                            numberOfUnits: serving.numberOfUnits,
                            polyunsaturatedFat:double.parse(serving.polyunsaturatedFat ?? '0'),
                            potassium: double.parse(serving.potassium ?? '0')/1000,
                            protein: double.parse(serving.protein ?? '0'),
                            saturatedFat:double.parse(serving.saturatedFat ?? '0'),
                            servingDescription: serving.servingDescription,
                            sodium: double.parse(serving.sodium ?? '0')/1000,
                            sugar: double.parse(serving.sugar ?? '0'),
                            vitaminA: double.parse(serving.vitaminA ?? '0'),
                            vitaminC: double.parse(serving.vitaminC ?? '0')/1000,
                          );
                          if(valueFood!=null){
                            context.read<NutritionCubit>().addNutritionData( valueFood: valueFood!);
                            Navigator.popUntil(context, (route) => route.isFirst);
                          }
                        },
                      ),
                    ),
                  ),
              ],
            );
          } else {
            return Center(child: Text(state.toString()));
          }
        },
      ),
    );
  }
}
