import 'dart:developer';
import 'dart:io';

import 'package:ahealth/constants.dart';
import 'package:ahealth/utils.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'init_app_state.dart';

class InitAppCubit extends Cubit<InitAppState> {
  InitAppCubit() : super(InitAppLoading());



  late SharedPreferences prefs;
  // All types available depending on platform (iOS ot Android).
  List<HealthDataType> get types => (Platform.isAndroid)
      ? dataTypesAndroid
      : (Platform.isIOS)
          ? dataTypesIOS
          : [];

  //  both READ and WRITE
  List<HealthDataAccess> get permissions => types
      .map((type) => [
            HealthDataType.WALKING_HEART_RATE,
            HealthDataType.ELECTROCARDIOGRAM,
            HealthDataType.HIGH_HEART_RATE_EVENT,
            HealthDataType.LOW_HEART_RATE_EVENT,
            HealthDataType.IRREGULAR_HEART_RATE_EVENT,
            HealthDataType.EXERCISE_TIME,
            HealthDataType.ATRIAL_FIBRILLATION_BURDEN,
          ].contains(type)
              ? HealthDataAccess.READ
              : HealthDataAccess.READ_WRITE)
      .toList();

  Future<void> initializeHealthSdk() async {
    await Health().configure();
    HealthConnectSdkStatus? healthSdkStatus = await Health().getHealthConnectSdkStatus();
    prefs = await SharedPreferences.getInstance();

    if (healthSdkStatus == HealthConnectSdkStatus.sdkUnavailable) {
      emit(InitAppSdkUnavailable());
      //await Health().installHealthConnect();
    } else if (Platform.isIOS ||healthSdkStatus == HealthConnectSdkStatus.sdkAvailable) {
      await Permission.activityRecognition.request();

      ///sdk available now we will check for health permission from user
      final bool? hasPermission = prefs.getBool(healthSdkSharedPreferenceKey);
      if (hasPermission == null || !hasPermission) {
        emit(InitAppPermissionNotAvailable());
        //here we call checkPermissions method using this cubit by showing some ui
        // await checkPermissions();
      } else {
        // getAllHealthData();
        emit(InitAppSuccess());
      }
    }else{
      emit(InitAppSdkUnavailable());
      log('healthSdkStatus',error: healthSdkStatus);
    }
  }

  Future<void> installHealthConnect() async => await Health().installHealthConnect();

  Future<void> checkPermissions() async {
    // Check if we have health permissions
    bool? hasPermissions = await Health().hasPermissions(types, permissions: permissions);
    hasPermissions = false;
    bool authorized = false;
    if (!hasPermissions) {
      // requesting access to the data types before reading them
      try {
        authorized = await Health().requestAuthorization(types, permissions: permissions);
        await prefs.setBool(healthSdkSharedPreferenceKey, authorized);
        if (authorized) {
          // await getAllHealthData();
          log('InitAppSuccess');
          emit(InitAppSuccess());
        }
      } catch (error) {
        log("Exception in authorize: $error");
        emit(InitAppFailed());
      }
    }
  }
}
