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

final class SleepChartsSuccess extends SleepChartState{
  final List<double> dataWeek;
  final List<double> dataMonth;

  const SleepChartsSuccess({required this.dataWeek,required this.dataMonth});
  @override
  List<Object?> get props => [dataWeek,dataMonth];
}

