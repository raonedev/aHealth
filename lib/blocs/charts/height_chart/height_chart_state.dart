part of 'height_chart_cubit.dart';

sealed class HeightChartState extends Equatable {
  const HeightChartState();
}



final class HeightChartsLoading extends HeightChartState{
  @override
  List<Object?> get props => [];
}

final class HeightChartsFailed extends HeightChartState{
  final String errorMessage;
  const HeightChartsFailed({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}

final class HeightChartsWeekSuccess extends HeightChartState{
  final List<double> data;

  const HeightChartsWeekSuccess({required this.data});
  @override
  List<Object?> get props => [data];
}

///month data
final class HeightChartsMonthSuccess extends HeightChartState{
  final List<double> data;

  const HeightChartsMonthSuccess({required this.data});
  @override
  List<Object?> get props => [data];
}