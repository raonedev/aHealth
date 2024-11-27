part of 'sleep_chart_cubit.dart';

sealed class SleepChartState extends Equatable {
  const SleepChartState();
}



final class SleepChartsLoading extends SleepChartState{
  @override
  List<Object?> get props => [];
}

final class SleepChartsFailed extends SleepChartState{
  final String errorMessage;
  const SleepChartsFailed({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}

final class SleepChartsWeekSuccess extends SleepChartState{
  final List<double> data;

  const SleepChartsWeekSuccess({required this.data});
  @override
  List<Object?> get props => [data];
}

///month data
final class SleepChartsMonthSuccess extends SleepChartState{
  final List<double> data;

  const SleepChartsMonthSuccess({required this.data});
  @override
  List<Object?> get props => [data];
}
