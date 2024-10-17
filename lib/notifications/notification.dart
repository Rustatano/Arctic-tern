import 'dart:convert';
import 'dart:math';

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
    (task, inputData) async {
      WidgetsFlutterBinding.ensureInitialized();
      Map<String, dynamic> input = inputData!; // removing null check
      if (input['notificationPeriod'] == '') {
        if (input['locationNotification'] == '') {
          if (input['weatherNotification'] == '') {
            // timed notification
            input['timeNotification'] = '';
            Note note = Note.fromMap(input);
            await Note.removeNote(input['title']);
            await note.insert();
            await Notification().showNotification(title: input['title']);
          } else {
            // timed weather notification
          }
        } else {
          if (input['weatherNotification'] == '') {
            // timed location notification
            final currentPosition = await Geolocator.getCurrentPosition();
            if (sqrt(pow(currentPosition.latitude, 2) +
                    pow(currentPosition.longitude, 2)) >
                jsonDecode(input['locationNotification'])['deviation']) {
              input['timeNotification'] = '';
              input['locationNotification'] = '';
              await Note.removeNote(input['title']);
              Note note = Note.fromMap(input);
              await note.insert();
              await Workmanager().cancelByUniqueName(input['title']);
            } else {
              await Notification().showNotification(title: input['title']);
            }
          } else {
            // timed location + weather notification
          }
        }
      } else {
        if (input['locationNotification'] == '') {
          if (input['weatherNotification'] == '') {
            // timed repeated notification
            await Notification().showNotification(title: input['title']);
          } else {
            // timed repeated weather notification
          }
        } else {
          if (input['weatherNotification'] == '') {
            // timed repeated location notification
            final currentPosition = await Geolocator.getCurrentPosition();
            if (sqrt(pow(currentPosition.latitude, 2) +
                    pow(currentPosition.longitude, 2)) <
                jsonDecode(input['locationNotification'])['deviation']) {
              await Notification().showNotification(title: input['title']);
            }
          } else {
            // timed repeated location + weather notification
          }
        }
      }
      return Future.value(true);
    },
  );
}
