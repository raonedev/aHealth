import 'package:ahealth/blocs/fooddetail/food_detail_cubit.dart';
// import 'package:ahealth/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FoodDetailCubit, FoodDetailState>(
        builder: (context, state) {
          if (state is FoodDetailLoading) {
            return const Center(child: CupertinoActivityIndicator());
          } else if (state is FoodDetailFailed) {
            return Center(child: Text(state.errorMessage));
          } else if (state is FoodDetailSuccess) {
            return Column(
              children: [
                if (state.foodWithServingsModel.food != null)Text(state.foodWithServingsModel.food!.foodName ??
                    "NULL Name"),
                if (state.foodWithServingsModel.food != null ||
                    state.foodWithServingsModel.food!.servings != null ||
                    state.foodWithServingsModel.food!.servings!.serving !=null ||
                    state.foodWithServingsModel.food!.servings!.serving!.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                    itemCount: state.foodWithServingsModel.food!.servings!.serving!.length,
                    itemBuilder: (context, index) {
                      final serving = state.foodWithServingsModel.food!.servings!.serving![index];
                      return ListTile(
                        title: Text(serving.servingDescription??'decs'),
                        subtitle: Text("${serving.metricServingAmount} ${serving.metricServingUnit}\ncalories : ${serving.calories} | carbohydrate : ${serving.carbohydrate} | protein : 0.${serving.protein} | \nfat : ${serving.fat} | saturated_fat : ${serving.saturatedFat} | polyunsaturated_fat : ${serving.polyunsaturatedFat} | \ncholesterol : ${serving.cholesterol} | sodium : ${serving.sodium} | potassium : ${serving.potassium} | fiber : ${serving.fiber}"),
                        
                      );
                    },
                  ),
                  )
              ],
            );
          }else{
            return Center(child: Text(state.toString()));
          }
        },
      ),
    );
  }
}
