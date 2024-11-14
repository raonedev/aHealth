part of 'init_app_cubit.dart';

sealed class InitAppState extends Equatable {
  const InitAppState();
}

final class InitAppLoading extends InitAppState{
  @override
  List<Object?> get props => [];
}

final class InitAppSuccess extends InitAppState{
  @override
  List<Object?> get props => [];
}

final class InitAppFailed extends InitAppState{
  @override
  List<Object?> get props => [];
}

final class InitAppSdkUnavailable extends InitAppState{
  @override
  List<Object?> get props => [];
}

final class InitAppPermissionNotAvailable extends InitAppState{
  @override
  List<Object?> get props => [];

}
