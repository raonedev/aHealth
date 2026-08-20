part of 'calorie_chart_cubit.dart';

abstract class CalorieChartState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CalorieChartLoading extends CalorieChartState {}

class CalorieChartFailed extends CalorieChartState {
  final String errorMessage;
  CalorieChartFailed({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}

class CalorieChartSuccess extends CalorieChartState {
  final DateTime weekStartDate;
  final List<double> consumed;
  final double target;
  final double tdee;
  CalorieChartSuccess({
    required this.weekStartDate,
    required this.consumed,
    required this.target,
    required this.tdee,
  });
  @override
  List<Object?> get props => [weekStartDate, consumed, target, tdee];
}