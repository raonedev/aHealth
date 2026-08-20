part of 'nutrient_chart_cubit.dart';

abstract class NutrientChartState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NutrientChartLoading extends NutrientChartState {}

class NutrientChartFailed extends NutrientChartState {
  final String errorMessage;
  NutrientChartFailed({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}

class NutrientChartSuccess extends NutrientChartState {
  final DateTime weekStartDate;
  final Map<NutrientType, List<double>> weekData;
  NutrientChartSuccess({required this.weekStartDate, required this.weekData});
  @override
  List<Object?> get props => [weekStartDate, weekData];
}