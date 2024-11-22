import 'package:ahealth/blocs/food_search/food_search_cubit.dart';
import 'package:ahealth/presentation/fooddetailscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  CupertinoSearchTextField(
          placeholder: "Apple",
          onSubmitted: (value) {
              dev.log(value);
              context.read<FoodSearchCubit>().searchFood(value);

          },
        ),
      ),
      body: BlocBuilder<FoodSearchCubit, FoodSearchState>(
        builder: (context, state) {
          if(state is FoodSearchInitailize){
            return const Center(
              child: Text("Seach Food Here"),
            );
          }else if(state is FoodSearchLoading){
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }else if(state is FoodSearchFailed){
            return Center(
              child: Text(state.errorMessage),
            );
          }else if(state is FoodSearchSuccess){
            if(state.foodSearchModel.foods==null || state.foodSearchModel.foods!.isEmpty){
              return const Center(
                child: Text('no food found with these keyword'),
              );
            }else{
              return ListView.builder(
                itemCount: state.foodSearchModel.foods!.length,
                itemBuilder: (context, index) {
                  final food = state.foodSearchModel.foods![index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 8),
                    decoration:  BoxDecoration(
                       color: const Color(0xffe1d4c1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CupertinoListTile(
                      onTap: () {
                        if(food.foodId!=null){
                          Navigator.push(context, MaterialPageRoute(builder: (_)=>FoodDetailScreen(foodId: food.foodId!)));
                        }else{
                          dev.log("unable to get foodId");
                        }
                      },
                      title: Text(food.foodName??'null'),
                      subtitle: Text(
                        food.foodDescription ?? 'null',
                        style: const TextStyle(
                          fontSize: 11.0,
                        ),
                        maxLines: null, // Allows the text to expand to multiple lines
                        overflow: TextOverflow.visible, // Prevents text clipping
                      ),
                    ),
                  );
                },
              );
            }
          }else{
            return Center(
              child: Text(state.toString()),
            );
          }
        },
      ),
    );
  }
}
