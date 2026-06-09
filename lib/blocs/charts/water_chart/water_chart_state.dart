part of 'water_chart_cubit.dart';

sealed class WaterChartState extends Equatable {
  const WaterChartState();
}

final class WaterChartLoading extends WaterChartState {
  @override List<Object?> get props => [];
}

final class WaterChartFailed extends WaterChartState {
  final String errorMessage;
  const WaterChartFailed({required this.errorMessage});
  @override List<Object?> get props => [errorMessage];
}

final class WaterChartSuccess extends WaterChartState {
  final List<double> weekData;   // liters per day, index 0 = 6 days ago
  final List<double> monthData;  // liters per day, index 0 = 29 days ago
  final bool monthLoaded;
  
  final DateTime weekStartDate;
  const WaterChartSuccess({
    required this.weekData,
    required this.monthData,
    this.monthLoaded = false, required this.weekStartDate,
  });
  @override List<Object?> get props => [weekData, monthData, monthLoaded,weekStartDate];
}


