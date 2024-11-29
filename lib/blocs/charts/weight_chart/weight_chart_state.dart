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

final class WeightChartsSuccess extends WeightChartState{
  final List<double> dataWeek;
  final List<double> dataMonth;

  const WeightChartsSuccess({required this.dataWeek,required this.dataMonth});
  @override
  List<Object?> get props => [dataWeek,dataMonth];
}
