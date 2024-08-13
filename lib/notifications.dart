import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static const String _channelId = 'plant_care_channel';

  NotificationService() {
    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title, String body) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Plant Care Notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
Future<void> scheduleDailyNotification() async {
  const notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'Plant Care Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    ),
  );

  tz.initializeTimeZones(); // Initialize timezone data

  final now = tz.TZDateTime.now(tz.local);
  final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9, 0);
  final scheduleTime = scheduledDate.isBefore(now) ? scheduledDate.add(Duration(days: 1)) : scheduledDate;

  await _flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    '🌿 Daily Plant Care Reminder',
    '🌟 Time to give your green friends some love! Don\'t forget to check in on your plants and make sure they\'re thriving. 🌱💧',
    scheduleTime,
    notificationDetails,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}


Future<void> checkAndNotifyUploadDate() async {
  final prefs = await SharedPreferences.getInstance();
  final lastUploadDateStr = prefs.getString('lastUploadDate') ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
  final lastUploadDate = DateFormat('yyyy-MM-dd').parse(lastUploadDateStr);

  final currentDate = DateTime.now();
  final difference = currentDate.difference(lastUploadDate).inDays;

  if (difference >= 6) {
    await showNotification(
      '📸 Time to Update Your Plant Photos!',
      '🌟 It\'s been a while since you updated your plant photos. 📅✨ Show off your plants\' progress and keep your collection fresh! 🌿📷',
    );
  }
}

}
