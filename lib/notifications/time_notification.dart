import 'package:flutter/material.dart';
import 'package:weatherNote/notifications/show_notification.dart';

class TimeNotification extends ShowNotification {
  TimeNotification(
    super.channel,
  );

  Future<void> showTimeNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    await initializeNotificationPlugin();
    await notificationsPlugin
        .show(id, title, body, notificationDetails(channel), payload: payload);
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
