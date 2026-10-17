import 'package:ahealth/appcolors.dart';
import 'package:ahealth/common/spring_button_widget.dart';

import '../blocs/food_search/food_search_cubit.dart';
import '../blocs/fooddetail/food_detail_cubit.dart';
import '../config/appconstants.dart';
import 'nutririon/fooddetailscreen.dart';
import 'package:ahealth/models/food_search_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;

import 'package:hive/hive.dart';

class SearchFoodScreen extends StatefulWidget {
  const SearchFoodScreen({super.key});

  @override
  State<SearchFoodScreen> createState() => _SearchFoodScreenState();
}

class _SearchFoodScreenState extends State<SearchFoodScreen> {
  Box<dynamic>? searchFoodBox;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FoodSearchCubit>().clearSearch();
    initialized();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> initialized() async {
    await Hive.openBox(searchFoodLocationHive);
    if (!mounted) return;
    setState(() {
      searchFoodBox = Hive.box(searchFoodLocationHive);
    });
  }

  bool isTextEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CupertinoSearchTextField(
          controller: _searchController,
          placeholder: "Apple",
          onChanged: (value) {
            if (value.isEmpty) {
              context.read<FoodSearchCubit>().clearSearch();
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
          ? (searchFoodBox != null)
                ? ListView.builder(
                    itemCount: searchFoodBox!.length,
                    itemBuilder: (context, index) {
                      final food = _savedFoodAt(index);
                      return _savedFoodCard(food);
                    },
                  )
                : const Center(child: Text("Seach Food Here"))
          : BlocBuilder<FoodSearchCubit, FoodSearchState>(
              builder: (context, state) {
                if (state is FoodSearchInitailize) {
                  if (searchFoodBox != null) {
                    return ListView.builder(
                      itemCount: searchFoodBox!.length,
                      itemBuilder: (context, index) {
                        final food = _savedFoodAt(index);
                        return _savedFoodCard(food);
                      },
                    );
                  } else {
                    return const Center(child: Text("Seach Food Here"));
                  }
                } else if (state is FoodSearchLoading) {
                  return const Center(child: CupertinoActivityIndicator());
                } else if (state is FoodSearchFailed) {
                  return _SearchErrorView(
                    message: state.errorMessage,
                    isNoInternet: state.isNoInternet,
                  );
                } else if (state is FoodSearchSuccess) {
                  if (state.foodSearchModel.foods == null ||
                      state.foodSearchModel.foods!.isEmpty) {
                    return const Center(
                      child: Text('no food found with these keyword'),
                    );
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
                  return Center(child: Text(state.toString()));
                }
              },
            ),
    );
  }

  Foods _savedFoodAt(int index) {
    final box = searchFoodBox!;
    final reverseIndex = box.length - index - 1;
    return box.getAt(reverseIndex) as Foods;
  }

  Widget _savedFoodCard(Foods food) {
    final foodId = food.foodId;
    if (foodId == null) return searchFoodCard(food, context);

    return Dismissible(
      key: ValueKey(foodId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _deleteSavedFood(foodId),
      onDismissed: (_) {
        if (mounted) setState(() {});
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 24),
        child: const Icon(
          Icons.delete_outline,
          color: white,
          semanticLabel: 'Delete saved food',
        ),
      ),
      child: searchFoodCard(food, context),
    );
  }

  Future<bool> _deleteSavedFood(String foodId) async {
    final box = searchFoodBox;
    if (box == null) return false;

    try {
      await box.delete(foodId);
      return true;
    } catch (error, stackTrace) {
      dev.log(
        'Unable to delete saved food',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete saved food.')),
        );
      }
      return false;
    }
  }

  Widget searchFoodCard(Foods food, BuildContext context) {
    return SpringButton(
      SpringButtonType.onlyScale,
      onTap: () async {
        final foodId = food.foodId;
        final box = searchFoodBox;
        if (foodId != null && box != null) {
          if (box.get(foodId) == null) {
            await box.put(foodId, food);
            dev.log("food is put in local");
          }
          if (!mounted) return;
          dev.log(foodId);
          await _openFoodDetails(foodId, context);
        } else {
          dev.log("unable to get foodId");
        }
      },
      uiChild: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: CupertinoListTile(
          title: Row(
            children: [
              Flexible(
                child: Text(
                  food.foodName ?? 'Unknown food',
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (food.foodType != null) _foodTypeBadge(food.foodType!),
            ],
          ),
          subtitle: Text(
            food.foodDescription ?? 'null',
            style: const TextStyle(fontSize: 11.0),
            maxLines: 2, // Allows the text to expand to multiple lines
            overflow: TextOverflow.visible, // Prevents text clipping
          ),
        ),
      ),
    );
  }

  Future<void> _openFoodDetails(String foodId, BuildContext context) async {
    final foodDetailCubit = context.read<FoodDetailCubit>();
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: foodDetailCubit,
          child: FoodDetailScreen(foodId: foodId),
        ),
      ),
    );
    if (!mounted) return;

    _searchController.clear();
    context.read<FoodSearchCubit>().clearSearch();
    setState(() {
      isTextEmpty = true;
    });
  }

  Widget _foodTypeBadge(String type) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        border: Border.all(color: Colors.green, width: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: const TextStyle(fontSize: 10, color: Colors.green, height: 1.2),
      ),
    );
  }
}

class _SearchErrorView extends StatelessWidget {
  const _SearchErrorView({required this.message, required this.isNoInternet});

  final String message;
  final bool isNoInternet;

  @override
  Widget build(BuildContext context) {
    final icon = isNoInternet ? Icons.wifi_off_rounded : Icons.error_outline;
    return Center(
      child: Semantics(
        liveRegion: true,
        label: message,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, semanticLabel: message),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
