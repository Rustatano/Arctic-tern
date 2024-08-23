import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ShowNotification {
  String channel;

  ShowNotification(
    this.channel,
  );

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotificationPlugin() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('icon3');

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) async {},
    );
  }

  NotificationDetails notificationDetails(String channel) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel,
        channel,
        importance: Importance.max,
      ),
    );
  }
}
