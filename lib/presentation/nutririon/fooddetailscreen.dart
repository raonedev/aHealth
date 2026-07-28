import 'package:ahealth/appcolors.dart';
import 'package:ahealth/blocs/fooddetail/food_detail_cubit.dart';
import 'package:ahealth/blocs/nutrition/nutrition_cubit.dart';
import 'package:ahealth/common/spring_button_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/nutrition_model.dart';
// import 'dart:developer' as dev;

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
  double multiplier = 1.0;

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
                    if (state.foodWithServingsModel.food != null &&
                        state.foodWithServingsModel.food!.servings != null &&
                        state.foodWithServingsModel.food!.servings!.serving !=
                            null &&
                        state.foodWithServingsModel.food!.servings!.serving!
                            .isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.foodWithServingsModel.food!.servings!
                              .serving!.length,
                          itemBuilder: (context, index) {
                            final serving = state.foodWithServingsModel.food!
                                .servings!.serving![index];
                            return SpringButton(
                              SpringButtonType.withOpacity,
                              onTap: () {
                                if (selectIndex == index) {
                                  setState(() {
                                    selectIndex = null;
                                    multiplier = 1.0;
                                  });
                                } else {
                                  setState(() {
                                    selectIndex = index;
                                    multiplier = 1.0;
                                  });
                                }
                              },
                              uiChild: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: (selectIndex == null)
                                      ? white
                                      : (selectIndex == index)
                                          ? primary
                                          : white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  title: Text(
                                    serving.servingDescription ?? 'decs',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: (selectIndex == index)
                                              ? white
                                              : black,
                                        ),
                                  ),
                                  subtitle: Text(
                                    "${serving.metricServingAmount} ${serving.metricServingUnit}\ncalories : ${serving.calories} | carbohydrate : ${serving.carbohydrate} | protein : ${serving.protein} | \nfat : ${serving.fat} | saturated_fat : ${serving.saturatedFat} | polyunsaturated_fat : ${serving.polyunsaturatedFat} | \ncholesterol : ${serving.cholesterol} | sodium : ${serving.sodium} | potassium : ${serving.potassium} | fiber : ${serving.fiber}\n Calcium : ${serving.calcium}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: (selectIndex == index)
                                              ? white
                                              : black,
                                        ),
                                  ),
                                ),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () => setState(() => multiplier =
                                    (multiplier - 0.5).clamp(0.5, 10)),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(
                                  '${multiplier.toStringAsFixed(multiplier % 1 == 0 ? 0 : 1)}x serving',
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                              IconButton(
                                onPressed: () => setState(() => multiplier =
                                    (multiplier + 0.5).clamp(0.5, 10)),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ),
                        SpringButton(
                          SpringButtonType.onlyScale,
                          onTap: () {
                            final serving = state.foodWithServingsModel.food
                                ?.servings?.serving?[selectIndex!];
                            valueFood = ValueFood(
                              name: '${state.foodWithServingsModel.food!.foodName ?? "NULL Name"} (${multiplier.toStringAsFixed(multiplier % 1 == 0 ? 0 : 1)} ${serving?.measurementDescription ?? "serving"}${multiplier != 1 ? "s" : ""})',
                              unit: serving?.metricServingUnit,
                              quantity: double.parse(
                                      serving?.metricServingAmount ?? '0') *
                                  multiplier,
                              calcium: double.parse(serving?.calcium ?? '0') /
                                  1000 *
                                  multiplier,
                              calories: double.parse(serving?.calories ?? '0') *
                                  multiplier,
                              carbs:
                                  double.parse(serving?.carbohydrate ?? '0') *
                                      multiplier,
                              cholesterol:
                                  double.parse(serving?.cholesterol ?? '0') /
                                      1000 *
                                      multiplier,
                              fat: double.parse(serving?.fat ?? '0') *
                                  multiplier,
                              fiber: double.parse(serving?.fiber ?? '0') *
                                  multiplier,
                              iron: double.parse(serving?.iron ?? '0') /
                                  1000 *
                                  multiplier,
                              measurementDescription:
                                  serving?.measurementDescription,
                              metricServingAmount: serving?.metricServingAmount,
                              metricServingUnit: serving?.metricServingUnit,
                              monounsaturatedFat: double.parse(
                                      serving?.monounsaturatedFat ?? '0') *
                                  multiplier,
                              numberOfUnits: serving?.numberOfUnits,
                              polyunsaturatedFat: double.parse(
                                      serving?.polyunsaturatedFat ?? '0') *
                                  multiplier,
                              potassium:
                                  double.parse(serving?.potassium ?? '0') /
                                      1000 *
                                      multiplier,
                              protein: double.parse(serving?.protein ?? '0') *
                                  multiplier,
                              saturatedFat:
                                  double.parse(serving?.saturatedFat ?? '0') *
                                      multiplier,
                              servingDescription:
                                  '${multiplier}x ${serving?.servingDescription ?? ''}',
                              sodium: double.parse(serving?.sodium ?? '0') /
                                  1000 *
                                  multiplier,
                              sugar: double.parse(serving?.sugar ?? '0') *
                                  multiplier,
                              vitaminA: double.parse(serving?.vitaminA ?? '0') /
                                  1000 *
                                  multiplier,
                              vitaminC: double.parse(serving?.vitaminC ?? '0') /
                                  1000 *
                                  multiplier,
                            );
                            if (valueFood != null) {
                              context
                                  .read<NutritionCubit>()
                                  .addNutritionData(valueFood: valueFood!);
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                            }
                          },
                          uiChild: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.all(16.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Add Meal",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
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
