import 'package:ahealth/appcolors.dart';

import '../blocs/food_search/food_search_cubit.dart';
import '../config/appconstants.dart';
import 'fooddetailscreen.dart';
import 'package:ahealth/models/FoodSearchModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;

import 'package:hive/hive.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Box<dynamic>? searchFoodBox;

  @override
  void initState() {
    initialized();
    super.initState();
  }

  Future<void> initialized() async {
    await Hive.openBox(searchFoodLocationHive);
    setState(() {
      searchFoodBox = Hive.box(searchFoodLocationHive);
    });
  }

  bool isTextEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CupertinoSearchTextField(
          placeholder: "Apple",
          onChanged: (value) {
            if (value.isEmpty) {
              setState(() {
                isTextEmpty = true;
              });
            }
          },
          onSubmitted: (value) {
            setState(() {
              isTextEmpty = false;
            });
            dev.log(value);
            context.read<FoodSearchCubit>().searchFood(value);
          },
        ),
      ),
      body: (isTextEmpty)
          ? (searchFoodBox != null) ?ListView.builder(
              itemCount: searchFoodBox!.length,
              itemBuilder: (context, index) {
                return searchFoodCard(searchFoodBox!.getAt(index), context);
              },
            ):const Center(child: Text("Seach Food Here"))
          : BlocBuilder<FoodSearchCubit, FoodSearchState>(
              builder: (context, state) {
                if (state is FoodSearchInitailize) {
                  if (searchFoodBox != null) {
                    return ListView.builder(
                      itemCount: searchFoodBox!.length,
                      itemBuilder: (context, index) {
                        return searchFoodCard(
                            searchFoodBox!.getAt(index), context);
                      },
                    );
                  } else {
                    return const Center(child: Text("Seach Food Here"));
                  }
                } else if (state is FoodSearchLoading) {
                  return const Center(child: CupertinoActivityIndicator());
                } else if (state is FoodSearchFailed) {
                  return Text(state.errorMessage);
                } else if (state is FoodSearchSuccess) {
                  if (state.foodSearchModel.foods == null ||
                      state.foodSearchModel.foods!.isEmpty) {
                    return const Center(
                        child: Text('no food found with these keyword'));
                  } else {
                    return ListView.builder(
                      itemCount: state.foodSearchModel.foods!.length,
                      itemBuilder: (context, index) {
                        final food = state.foodSearchModel.foods![index];
                        return searchFoodCard(food, context);
                      },
                    );
                  }
                } else {
                  return Center(
                    child: Text(state.toString()),
                  );
                }
              },
            ),
    );
  }

  Container searchFoodCard(Foods food, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CupertinoListTile(
        onTap: () {
          if (food.foodId != null && searchFoodBox != null) {

            if(searchFoodBox?.get(food.foodId)==null){
              searchFoodBox!.put(food.foodId!, food);
              dev.log("food is put in local");
            }
            Navigator.push(context,MaterialPageRoute(builder: (_) => FoodDetailScreen(foodId: food.foodId!)));
          } else {
            dev.log("unable to get foodId");
          }
        },
        title: Text(food.foodName ?? 'null',style: Theme.of(context).textTheme.titleSmall,),
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
  }
}
