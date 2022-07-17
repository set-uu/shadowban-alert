import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyNotification {
  static FlutterLocalNotificationsPlugin? _plugin;

  static Future<FlutterLocalNotificationsPlugin> get plugin async {
    if (_plugin != null) {
      return _plugin!;
    }
    _plugin = FlutterLocalNotificationsPlugin();
    _plugin?.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    return _plugin!;
  }

  static void notify(String message) {
    plugin.then((p) => p.show(
          0,
          'シャドウバンアラート',
          message,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'checked_notify',
              'changed notify',
              importance: Importance.max,
              priority: Priority.max,
              ongoing: true,
              playSound: false,
              enableLights: true,
              visibility: NotificationVisibility.public
            ),
          ),
        ));
  }
}
