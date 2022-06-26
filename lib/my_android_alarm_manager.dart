import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:shadowban_alert/http_service.dart';
import 'package:shadowban_alert/shadowban_state.dart';

import 'db_provider.dart';
import 'my_settings.dart';
import 'notification.dart';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'com.uu.set.isolate';
const int alarmId = 0;
// The background To foreground
SendPort? uiSendPort;

class MyAndroidAlarmManager {
  static void init() {
    AndroidAlarmManager.initialize();
  }

  // The callback for our alarm
  static Future<void> callback() async {
    debugPrint('### Alarm fired!');

    ShadowbanState state = await DBProvider.getLatestState();
    ShadowbanState newState = await HttpService().getPosts(state.userId);
    await DBProvider.createState(newState);

    String notifyStr = '';
    if (state.isSameState(newState)) {
      notifyStr = '状態に変化はありません。';
    } else {
      notifyStr = '状態に変化がありました。';
    }
    debugPrint(notifyStr);
    MyNotification.notify(notifyStr);

    // This will be null if we're running in the background.
    uiSendPort = IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);

    MyAndroidAlarmManager.setAlarm();
  }

  /// アラームを開始する
  static Future<void> setAlarm() async {
    debugPrint('### Set Alarm');
    bool isCheck = await MySettings.isCheck;
    if (!isCheck) return;

    int duration = await MySettings.duration;
    AndroidAlarmManager.oneShot(
      Duration(hours: duration),
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
