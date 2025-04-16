import 'dart:async';
import 'dart:convert';

//import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jiffy/jiffy.dart';
import 'package:workmanager/workmanager.dart';

import 'package:arctic_tern/main.dart';
import 'package:arctic_tern/db_objects/note.dart';

class Notification {
  String channel = 'Notification';

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotificationPlugin() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('launcher_icon_full');

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      //onDidReceiveNotificationResponse: (payload) async {},
    );
  }

  NotificationDetails notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel,
        channel,
        icon: 'launcher_icon_full',
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
    await notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails(),
      payload: payload,
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask(
    (task, inputData) async {
      List<Note> notes = await Note.getNotes({
        'category': 'All Categories',
        'active': 1,
      });

      Notification notificationService = Notification();
      notificationService.initializeNotificationPlugin();

      for (var note in notes) {
        if (note.from == 0 && note.to == 0) continue;

        int from = note.from;
        int to = note.to;
        int now = DateTime.now().millisecondsSinceEpoch;
        if (!(from - 30000 <= now && now < from + (to - from) + 30000)) {
          continue;
        }

        if (note.location != '') {
          // timed location notification
          Position currentPosition;
          try {
            currentPosition = await Geolocator.getCurrentPosition(
              locationSettings:
                  LocationSettings(timeLimit: Duration(seconds: 15)),
              // ignore: deprecated_member_use
              forceAndroidLocationManager: true,
            );
          } catch (e) {
            currentPosition = (await Geolocator.getLastKnownPosition(
              forceAndroidLocationManager: true,
            ))!;
          }
          if (Geolocator.distanceBetween(
                jsonDecode(note.location)['lat'] as double,
                jsonDecode(note.location)['long'] as double,
                currentPosition.latitude,
                currentPosition.longitude,
              ) <=
              jsonDecode(note.location)['radius']) {
            await notificationService.showNotification(title: note.title);
          }
        } else {
          // timed notification
          await notificationService.showNotification(title: note.title);
        }
        if (now + 30000 > to) {
          var newNote = note;
          switch (note.repeat) {
            case 'Daily':
              newNote.from += 86400000;
              newNote.to += 86400000;
              break;
            case 'Weekly':
              newNote.from += 7 * 86400000;
              newNote.to += 7 * 86400000;
              break;
            case 'Monthly':
              newNote.from = Jiffy.parseFromDateTime(
                      DateTime.fromMillisecondsSinceEpoch(note.from))
                  .add(months: 1)
                  .dateTime
                  .millisecondsSinceEpoch;
              newNote.to = Jiffy.parseFromDateTime(
                      DateTime.fromMillisecondsSinceEpoch(note.to))
                  .add(months: 1)
                  .dateTime
                  .millisecondsSinceEpoch;
              break;
            case 'Yearly':
              newNote.from = Jiffy.parseFromDateTime(
                      DateTime.fromMillisecondsSinceEpoch(note.from))
                  .add(years: 1)
                  .dateTime
                  .millisecondsSinceEpoch;
              newNote.to = Jiffy.parseFromDateTime(
                      DateTime.fromMillisecondsSinceEpoch(note.to))
                  .add(years: 1)
                  .dateTime
                  .millisecondsSinceEpoch;
              break;
            default:
              newNote.active = 0;
          }
          await note.update(newNote);
        }
      }
      await startBGTasks();
      return Future.value(true);
    },
  );
}
