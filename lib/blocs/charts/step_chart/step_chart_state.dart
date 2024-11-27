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

final class StepChartsWeekSuccess extends StepChartState{
  final List<double> data;

  const StepChartsWeekSuccess({required this.data});
  @override
  List<Object?> get props => [data];
}

///month data
final class StepChartsMonthSuccess extends StepChartState{
  final List<double> data;

  const StepChartsMonthSuccess({required this.data});
  @override
  List<Object?> get props => [data];
}
