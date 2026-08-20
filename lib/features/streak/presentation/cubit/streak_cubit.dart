import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/streak_entity.dart';
import '../../domain/usecases/get_streak_usecase.dart';
import '../../domain/usecases/log_activity_usecase.dart';
import 'streak_state.dart';

class StreakCubit extends Cubit<StreakState> {
  final GetStreakUsecase getStreakUsecase;
  final LogActivityUsecase logActivityUsecase;

  StreakCubit({required this.getStreakUsecase, required this.logActivityUsecase}) : super(StreakInitial());

  Future<void> loadStreak() async {
    emit(StreakLoading());
    try {
      final streak = await getStreakUsecase();
      emit(StreakLoaded(streak));
    } catch (e) {
      emit(StreakError(e.toString()));
    }
  }

  Future<void> logActivityAndRefresh(StreakActivityType type) async {
    try {
      final isFirstToday = await logActivityUsecase(type);
  await loadStreak();
  if (isFirstToday) emit(StreakCelebration((state as StreakLoaded).streak));
    } catch (e) {
      emit(StreakError(e.toString()));
    }
  }
}
