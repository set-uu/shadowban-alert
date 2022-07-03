import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';

import 'my_foreground_task.dart';
import 'my_settings.dart';

const int alarmId = 0;

class MyAndroidAlarmManager {
  static void init() {
    AndroidAlarmManager.initialize();
  }

  // The callback for our alarm
  static Future<void> callback() async {
    debugPrint('### Alarm fired!');

    await initForeGroundTask();
    startForeGroundTask();

    MyAndroidAlarmManager.setAlarm();
  }

  /// アラームを開始する
  static Future<void> setAlarm() async {
    debugPrint('### Set Alarm');
    bool isCheck = await MySettings.isCheck;
    if (!isCheck) return;

    int duration = await MySettings.duration;
    AndroidAlarmManager.oneShot(
      Duration(seconds: duration),
      // Ensure we have a unique alarm ID.
      alarmId,
      callback,
      exact: true,
      wakeup: true,
    );
  }

  /// アラームを止める
  static Future<void> cancelAlarm() async {
    debugPrint('### Cancel Alarm');
    AndroidAlarmManager.cancel(alarmId);
  }
}
