part of 'step_chart_cubit.dart';

sealed class StepChartState extends Equatable {
  const StepChartState();
}


final class StepChartsLoading extends StepChartState{
  @override
  List<Object?> get props => [];
}

final class StepChartsFailed extends StepChartState{
  final String errorMessage;
  const StepChartsFailed({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}

final class StepChartsSuccess extends StepChartState{
  final List<double> weekData;
  final List<double> monthData;
    final bool monthLoaded;

  const StepChartsSuccess({required this.weekData, required this.monthData, required this.monthLoaded});
  @override
  List<Object?> get props => [weekData,monthData,monthLoaded];
}

