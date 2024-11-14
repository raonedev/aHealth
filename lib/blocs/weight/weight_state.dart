part of 'weight_cubit.dart';

sealed class WeightState extends Equatable {
  const WeightState();
}

final class WeightLoading extends WeightState {
  @override
  List<Object> get props => [];
}

final class WeightFailed extends WeightState {
  final String errorMessage;

  const WeightFailed({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}

final class WeightSuccess extends WeightState {
  final List<WeightModel> weightModel;

  const WeightSuccess({required this.weightModel});
  @override
  List<Object> get props => [weightModel];
}
