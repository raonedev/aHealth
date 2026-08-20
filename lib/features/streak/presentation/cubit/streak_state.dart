import '../../domain/entities/streak_entity.dart';

abstract class StreakState {}

class StreakInitial extends StreakState {}

class StreakLoading extends StreakState {}

class StreakLoaded extends StreakState {
  final StreakEntity streak;
  StreakLoaded(this.streak);
}

class StreakError extends StreakState {
  final String message;
  StreakError(this.message);
}
