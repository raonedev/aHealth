part of 'water_chart_cubit.dart';

sealed class WaterChartState extends Equatable {
  const WaterChartState();
}

final class WaterChartLoading extends WaterChartState{
  @override
  List<Object?> get props => [];
}

final class WaterChartFailed extends WaterChartState{
  final String errorMessage;
  const WaterChartFailed({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}

final class WaterChartSuccess extends WaterChartState{
  final List<double> dataWeek;
  final List<double> dataMonth;

  const WaterChartSuccess({required this.dataWeek,required this.dataMonth});
  @override
  List<Object?> get props => [dataWeek,dataMonth];
}


