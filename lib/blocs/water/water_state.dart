part of 'water_cubit.dart';

sealed class WaterState extends Equatable {
  const WaterState();
}

//loading State
final class WaterLoadingState extends WaterState{
  @override
  List<Object?> get props => [];
}

//success state
final class WaterSuccessState extends WaterState{
  final List<WaterModel> waterModel;
  const WaterSuccessState({required this.waterModel});
  @override
  List<Object?> get props =>[waterModel];

}

//failed state
final class WaterFailed extends WaterState{
  final String errorMessage;
  const WaterFailed({required this.errorMessage});
  @override
  // TODO: implement props
  List<Object?> get props => [errorMessage];
}