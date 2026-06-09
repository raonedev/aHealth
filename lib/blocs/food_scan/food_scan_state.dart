part of 'food_scan_cubit.dart';

sealed class FoodScanState extends Equatable {
  const FoodScanState();

  @override
  List<Object> get props => [];
}

class FoodScanInitial extends FoodScanState {}

class FoodScanLoading extends FoodScanState {}

class FoodScanNoItems extends FoodScanState {}

class FoodScanSuccess extends FoodScanState {
  final List<ValueFood> foods;
  final String thinkingText;
  const FoodScanSuccess({required this.foods,required this.thinkingText});
  @override
  List<Object> get props => [foods, thinkingText];
}

class FoodScanError extends FoodScanState {
  final String message;
  const FoodScanError({required this.message});
  @override
  List<Object> get props => [message];
}