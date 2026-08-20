import 'package:get_it/get_it.dart';

import '../../blocs/weight/weight_cubit.dart';
import '../../features/step_tracking/data/datasources/tracking_local_datasource.dart';
import '../../features/step_tracking/data/repositories/tracking_repository_impl.dart';
import '../../features/step_tracking/domain/repositories/tracking_repository.dart';
import '../../features/step_tracking/domain/usecases/calculate_distance.dart';
import '../../features/step_tracking/domain/usecases/get_location_stream.dart';
import '../../features/step_tracking/domain/usecases/save_activity.dart';
import '../../features/step_tracking/presentation/viewmodels/tracking_cubit.dart';
import '../../features/streak/data/datasources/streak_local_datasource.dart';
import '../../features/streak/data/repositories/streak_repository_impl.dart';
import '../../features/streak/domain/repositories/streak_repository.dart';
import '../../features/streak/domain/usecases/get_streak_usecase.dart';
import '../../features/streak/domain/usecases/log_activity_usecase.dart';
import '../../features/streak/presentation/cubit/streak_cubit.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {

  sl.registerLazySingleton(() => WeightCubit());
  final localDataSource = TrackingLocalDataSourceImpl();
  final repository = TrackingRepositoryImpl(localDataSource);
  sl.registerLazySingleton<TrackingRepository>(() => repository);
  sl.registerLazySingleton(() => GetLocationStream(sl()));
  sl.registerLazySingleton(() => CalculateDistance());
  sl.registerLazySingleton(() => SaveActivity(sl()));
  sl.registerFactory(() => TrackingCubit(
        getLocationStream: sl(),
        calculateDistance: sl(),
        saveActivity: sl(),
        repository: sl(),
      ));
  final streakLocalDataSource = StreakLocalDataSourceImpl();
  final streakRepository = StreakRepositoryImpl(streakLocalDataSource);
  sl.registerLazySingleton<StreakRepository>(() => streakRepository);
  sl.registerLazySingleton(() => GetStreakUsecase(sl()));
  sl.registerLazySingleton(() => LogActivityUsecase(sl()));
  sl.registerLazySingleton(() => StreakCubit(
        getStreakUsecase: sl(),
        logActivityUsecase: sl(),
      ));
}
