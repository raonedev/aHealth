import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _channel = MethodChannel('dev.raone.ahealth/tracking');

Future<void> startTracking() async {
  if (Platform.isAndroid) {
    final intent = AndroidIntent(
      action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
      data: 'package:dev.raone.ahealth',
    );
    await intent.launch();
  }
  await _channel.invokeMethod('startTracking');
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('step_tracking_enabled', true);
}

Future<void> stopTracking() async {
  await _channel.invokeMethod('stopTracking');
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('step_tracking_enabled', false);
}

Future<bool> syncStepsNow() async {
  try {
    final result = await _channel.invokeMethod<bool>('syncStepsNow');
    return result ?? false;
  } catch (e) {
    return false;
  }
}