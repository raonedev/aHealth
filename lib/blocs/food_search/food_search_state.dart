part of 'food_search_cubit.dart';

sealed class FoodSearchState extends Equatable {
  const FoodSearchState();
}

final class FoodSearchInitailize extends FoodSearchState {
  @override
  List<Object> get props => [];
}


final class FoodSearchLoading extends FoodSearchState {
  @override
  List<Object> get props => [];
}

final class FoodSearchFailed extends FoodSearchState {
  final String errorMessage;

  const FoodSearchFailed({required this.errorMessage});
  @override
  List<Object> get props => [];
}

final class FoodSearchSuccess extends FoodSearchState {
  final FoodSearchModel foodSearchModel;

   const FoodSearchSuccess({required this.foodSearchModel});
  @override
  List<Object> get props => [foodSearchModel];
}

