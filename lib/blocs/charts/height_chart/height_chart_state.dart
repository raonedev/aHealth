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

final class HeightChartsSuccess extends HeightChartState{
  final List<double> dataWeek;
  final List<double> dataMonth;

  const HeightChartsSuccess({required this.dataWeek,required this.dataMonth});
  @override
  List<Object?> get props => [dataWeek,dataMonth];
}
