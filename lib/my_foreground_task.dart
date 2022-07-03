import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shadowban_alert/status.dart';

import 'db_provider.dart';
import 'http_service.dart';
import 'my_settings.dart';
import 'notification.dart';
import 'shadowban_state.dart';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'com.uu.set.isolate';

Future<void> initForeGroundTask() async {
  await FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'notification_channel_id',
      channelName: 'Foreground Notification',
      channelDescription:
          'This notification appears when the foreground service is running.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher',
      ),
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 5000,
    ),
    printDevLog: true,
  );
}

Future<void> startForeGroundTask() async {
  if (await FlutterForegroundTask.isRunningService) {
    await FlutterForegroundTask.restartService();
  } else {
    await FlutterForegroundTask.startService(
      notificationTitle: '通信中',
      notificationText: 'シャドウバン状態を確認中です',
      callback: startCallback,
    );
  }
}

Future<bool> stopForegroundTask() async {
  return await FlutterForegroundTask.stopService();
}

void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
}

class ForegroundTaskHandler extends TaskHandler {
  SendPort? _sendPort;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    debugPrint('ForegroundTaskHandler.onStart');
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    debugPrint('customData: $customData');
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    debugPrint('ForegroundTaskHandler.onEvent');

    ShadowbanState state = await DBProvider.getLatestState();
    if (state.status == Status.nothing) {
      return;
    }

    ShadowbanState newState = await HttpService().getPosts(state.userId);
    await DBProvider.createState(newState);

    if (state.isSameState(newState)) {
      if (!await MySettings.isChangedOnly) {
        MyNotification.notify('状態に変化はありません。');
      }
    } else {
      MyNotification.notify('状態に変化がありました。');
    }

    // This will be null if we're running in the background.
    SendPort? uiSendPort = IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
    // Send data to the main isolate.
    sendPort?.send(timestamp);
    stopForegroundTask();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    debugPrint('ForegroundTaskHandler.onDestroy');
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    debugPrint('onButtonPressed >> $id');
  }

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}
