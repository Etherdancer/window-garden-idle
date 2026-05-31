import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/plant.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle tapping notification
      },
    );

    // Setup Notification Channels for Android 8.0+
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Alerts Channel
      const AndroidNotificationChannel alertsChannel = AndroidNotificationChannel(
        'window_garden_alerts',
        'Plant Care Alerts',
        description: 'Notifications regarding plant moisture levels and fact unlocks.',
        importance: Importance.high,
      );

      // Timers Channel
      const AndroidNotificationChannel timersChannel = AndroidNotificationChannel(
        'window_garden_timers',
        'Scheduled Plant Care',
        description: 'Reminders for plant watering and pruning.',
        importance: Importance.defaultImportance,
      );

      await androidImplementation.createNotificationChannel(alertsChannel);
      await androidImplementation.createNotificationChannel(timersChannel);
    }
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'window_garden_alerts',
      'Plant Care Alerts',
      channelDescription: 'Notifications regarding plant moisture levels and fact unlocks.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(id, title, body, platformDetails);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'window_garden_timers',
      'Scheduled Plant Care',
      channelDescription: 'Reminders for plant watering and pruning.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(delay),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotificationsForPlant(int id) async {
    await _notificationsPlugin.cancel(id);
    // Also cancel the secondary id (e.g., id + 1000 for growth events) if needed
    await _notificationsPlugin.cancel(id + 10000);
  }

  Future<void> scheduleDehydrationWarning(Plant plant, Duration timeUntilDry) async {
    if (timeUntilDry.isNegative) return;
    
    // Create a stable integer ID for the dehydration warning
    final int baseId = plant.id.hashCode;
    
    await scheduleNotification(
      id: baseId,
      title: '${plant.nickname} is thirsty!',
      body: 'Your ${plant.species?.name ?? "plant"} needs water soon. Tap to check on it.',
      delay: timeUntilDry,
    );
  }

  Future<void> scheduleGrowthEvent(Plant plant, Duration timeUntilNextStage) async {
    if (timeUntilNextStage.isNegative) return;
    
    // Create a different stable ID for the growth event to avoid colliding with dehydration warning
    final int growthId = plant.id.hashCode + 10000;
    
    await scheduleNotification(
      id: growthId,
      title: '${plant.nickname} is growing!',
      body: 'Your ${plant.species?.name ?? "plant"} just reached a new growth stage. Come see!',
      delay: timeUntilNextStage,
    );
  }
}
