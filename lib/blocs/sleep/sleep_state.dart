part of 'sleep_cubit.dart';

sealed class SleepState extends Equatable {
  const SleepState();
}

//loading State
final class SleepLoadingState extends SleepState{
  @override
  List<Object?> get props => [];
}

//success state
final class SleepSuccessState extends SleepState{
  final List<SleepModel> sleepModel;
  const SleepSuccessState({required this.sleepModel});
  @override
  List<Object?> get props =>[sleepModel];
}

//failed state
final class SleepFailedState extends SleepState{
  final String errorMessage;
  const SleepFailedState({required this.errorMessage});
  @override
  List<Object?> get props => [errorMessage];
}
