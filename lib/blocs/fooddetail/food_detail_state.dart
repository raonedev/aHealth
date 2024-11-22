part of 'food_detail_cubit.dart';

sealed class FoodDetailState extends Equatable {
  const FoodDetailState();
}
///initialState
final class FoodDetailInitial extends FoodDetailState {
  @override
  List<Object> get props => [];
}

///loading state
final class FoodDetailLoading extends FoodDetailState {
  @override
  List<Object> get props => [];
}

///failed state
final class FoodDetailFailed extends FoodDetailState {
  final String errorMessage;

  const FoodDetailFailed({required this.errorMessage});
  @override
  List<Object> get props => [];
}


///success state
final class FoodDetailSuccess extends FoodDetailState {
  final FoodWithServingsModel foodWithServingsModel;

  const FoodDetailSuccess({required this.foodWithServingsModel});
  @override
  List<Object> get props => [foodWithServingsModel];
}
