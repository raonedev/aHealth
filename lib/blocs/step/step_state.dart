part of 'step_cubit.dart';

sealed class StepsState extends Equatable {
  const StepsState();
}

final class StepLoadingState extends StepsState {
  @override
  List<Object> get props => [];
}

final class StepFailed extends StepsState {
  final String errorMessage;

  const StepFailed({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}

final class StepSuccessState extends StepsState {
  final List<StepModel> stepModel;

  const StepSuccessState({required this.stepModel});
  @override
  List<Object> get props => [stepModel];
}
