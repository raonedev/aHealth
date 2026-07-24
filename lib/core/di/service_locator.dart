import 'package:get_it/get_it.dart';

import '../../features/step_tracking/data/datasources/tracking_local_datasource.dart';
import '../../features/step_tracking/data/repositories/tracking_repository_impl.dart';
import '../../features/step_tracking/domain/repositories/tracking_repository.dart';
import '../../features/step_tracking/domain/usecases/calculate_distance.dart';
import '../../features/step_tracking/domain/usecases/get_location_stream.dart';
import '../../features/step_tracking/domain/usecases/save_activity.dart';
import '../../features/step_tracking/presentation/viewmodels/tracking_cubit.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {

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
}