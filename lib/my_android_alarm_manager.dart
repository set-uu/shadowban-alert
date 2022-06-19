import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:shadowban_alert/http_service.dart';
import 'package:shadowban_alert/shadowban_state.dart';

import 'db_provider.dart';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'com.uu.set.isolate';
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

    // This will be null if we're running in the background.
    uiSendPort = IsolateNameServer.lookupPortByName(isolateName);
    debugPrint(uiSendPort?.toString());
    uiSendPort?.send(null);

    MyAndroidAlarmManager.setAlarm();
  }

  static void setAlarm() {
    debugPrint('### Set Alarm');
    AndroidAlarmManager.oneShot(
      const Duration(/*hours: 12, */ seconds: 10),
      // Ensure we have a unique alarm ID.
      Random().nextInt(31),
      callback,
      exact: true,
      wakeup: true,
    );
  }
}
