import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void backgroundNotificationHandler(NotificationResponse response) async {
  debugPrint(
    "Background Notification tapped (in background): ${response.payload}",
  );
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //* Navigation: Global navigator key for navigation on tap
  static GlobalKey<NavigatorState>? navigatorKey;

  static const _instantChannelId = 'instant_notification_channel_id';
  static const _scheduledChannelId = 'daily_reminder_channel_id';

  Future<void> initNotification() async {
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            defaultPresentAlert: true,
            defaultPresentSound: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidSettings, iOS: iosSettings);

      await notificationsPlugin.initialize(
        initializationSettings,
        // * Additional for Notification tapped
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint("Notification tapped: ${response.payload}");
          // * navigation Logic
          // Use payload to navigate using navigatorKey
          // navigatorKey?.currentState?.pushNamed('/details', arguments: response.payload);
        },
        onDidReceiveBackgroundNotificationResponse:
            backgroundNotificationHandler,
      );
    } catch (e) {
      debugPrint("Error initializing notifications: $e");
    }
  }

  // * Instant Notification

  Future<void> instantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await notificationsPlugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _instantChannelId,
            'Instant Notification',
            channelDescription: 'Instant Notification Channel',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } catch (e) {
      debugPrint("❌ Instant Notification Error: $e");
    }
  }

  // * Scheduled notifications
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
  }) async {
    try {
      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _scheduledChannelId,
            'Scheduled Reminders',
            channelDescription: 'Used for daily/weekly reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        // matchDateTimeComponents:
        //     DateTimeComponents.dayOfWeekAndTime, // or dateAndTime
        payload: payload,
      );
    } catch (e) {
      debugPrint("❌ Schedule Notification Error: $e");
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

}
