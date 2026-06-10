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
  final String groupUuid;
  final String imagePath;
  const FoodScanSuccess({
    required this.foods,
    required this.thinkingText,
    required this.groupUuid,
    required this.imagePath,
  });
  @override
  List<Object> get props => [foods, thinkingText, groupUuid, imagePath];
}

class FoodScanThinking extends FoodScanState {
  final String thinkingText;
  const FoodScanThinking({required this.thinkingText});
  @override
  List<Object> get props => [thinkingText];
}

class FoodScanError extends FoodScanState {
  final String message;
  const FoodScanError({required this.message});
  @override
  List<Object> get props => [message];
}
