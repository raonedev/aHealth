part of 'nutrition_cubit.dart';

sealed class NutritionState extends Equatable {
  const NutritionState();
}

final class NutritionEmpty extends NutritionState {
  final DateTime date;
  const NutritionEmpty({required this.date});
  @override
  List<Object> get props => [date];
}

final class NutritionLoading extends NutritionState {
  @override
  List<Object> get props => [];
}

final class NutritionFailed extends NutritionState {
  final String errorMessage;
  const NutritionFailed({required this.errorMessage});
  @override
  List<Object?> get props => [];
}

final class NutritionSuccess extends NutritionState {
  final List<NutritionModel> nutritionModel;
  final DateTime date;

  const NutritionSuccess({required this.nutritionModel, required this.date});

  @override
  List<Object?> get props => [nutritionModel, date];
}
