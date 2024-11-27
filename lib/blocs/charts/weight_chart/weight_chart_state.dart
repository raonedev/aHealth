part of 'weight_chart_cubit.dart';

sealed class WeightChartState extends Equatable {
  const WeightChartState();
}


final class WeightChartsLoading extends WeightChartState{
  @override
  List<Object?> get props => [];
}

final class WeightChartsFailed extends WeightChartState{
  final String errorMessage;
  const WeightChartsFailed({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}

final class WeightChartsWeekSuccess extends WeightChartState{
  final List<double> data;

  const WeightChartsWeekSuccess({required this.data});
  @override
  List<Object?> get props => [data];
}

///month data
final class WeightChartsMonthSuccess extends WeightChartState{
  final List<double> data;

  const WeightChartsMonthSuccess({required this.data});
  @override
  List<Object?> get props => [data];
}