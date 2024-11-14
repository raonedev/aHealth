part of 'height_cubit.dart';

sealed class HeightState extends Equatable {
  const HeightState();
}

final class HeightLoading extends HeightState {
  @override
  List<Object> get props => [];
}

final class HeightFailed extends HeightState{
  final String errorMessage;
  const HeightFailed({required this.errorMessage});
  @override
  List<Object?> get props => [];
}

final class HeightSuccess extends HeightState{
  final List<HeightModel> heightModel;
  const HeightSuccess({required this.heightModel});
  @override
  List<Object?> get props => [];
}
