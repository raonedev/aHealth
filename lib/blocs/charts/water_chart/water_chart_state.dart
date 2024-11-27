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

final class WaterChartWeekSuccess extends WaterChartState{
  final List<double> data;

  const WaterChartWeekSuccess({required this.data});
  @override
  List<Object?> get props => [data];
}

///month data
final class WaterChartMonthSuccess extends WaterChartState{
  final List<double> data;

  const WaterChartMonthSuccess({required this.data});
  @override
  List<Object?> get props => [data];
}
