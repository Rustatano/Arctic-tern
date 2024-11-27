import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:arctic_tern/db_objects/note.dart';
import 'package:workmanager/workmanager.dart';

class Notification {
  String channel = 'Notification';

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotificationPlugin() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('launcher_icon');

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

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    await initializeNotificationPlugin();
    await notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails(channel),
      payload: payload,
    );
  }
}

Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  required String initialDate,
}) async {
  DateTime initDate;
  if (initialDate.isNotEmpty) {
    initDate = DateTime.parse(initialDate);
  } else {
    initDate = DateTime.now();
  }
  DateTime firstDate = DateTime.now();
  DateTime lastDate = firstDate.add(const Duration(days: 365));

  final DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: initDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (selectedDate == null) return null;

  if (!context.mounted) return selectedDate;

  final TimeOfDay? selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initDate),
  );

  return selectedTime == null
      ? null
      : DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask(
    (task, _) async {
      List<Note> notes = await Note.getNotes({'active': 'true'});

      for (var note in notes) {
        if (note.from == '' && note.to == '') continue;
        if (note.location == '') {
          // timed notification
          int from = (DateTime.parse(note.from).millisecondsSinceEpoch / 1000).floor();
          int to = (DateTime.parse(note.to).millisecondsSinceEpoch / 1000).floor();
          int now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();

          if (!(from - 30 < now && now < from + (to - from) + 30)) continue;

          await Notification().showNotification(title: note.title);
        } else {
          // timed location notification
          final currentPosition = await Geolocator.getCurrentPosition(
            // ignore: deprecated_member_use
            forceAndroidLocationManager: true,
          );
          if (Geolocator.distanceBetween(
                jsonDecode(note.location)['lat'] as double,
                jsonDecode(note.location)['long'] as double,
                currentPosition.latitude,
                currentPosition.longitude,
              ) >
              jsonDecode(note.location)['radius']) {
          } else {
            await Notification().showNotification(title: note.title);
          }
        }
      }
      return Future.value(true);
    },
  );
}
