import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _plugin.initialize(const InitializationSettings(android: android));

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestExactAlarmsPermission();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'todo_channel',
        'Todo Updates',
        description: 'Notifications for todo state changes',
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  NotificationDetails get _silent => const NotificationDetails(
    android: AndroidNotificationDetails(
      'todo_channel',
      'Todo Updates',
      channelDescription: 'Notifications for todo state changes',
      importance: Importance.high,
      priority: Priority.high,
      silent: true,
      enableVibration: false,
      playSound: false,
    ),
  );

  Future<void> showStarted(String title) async {
    await _plugin.show(
      title.hashCode,
      'Task Started',
      '$title is in progress',
      _silent,
    );
  }

  Future<void> showPaused(String title) async {
    await _plugin.show(
      title.hashCode,
      'Task Paused',
      '$title has paused',
      _silent,
    );
  }

  Future<void> showCompleted(String title) async {
    await _plugin.show(
      title.hashCode,
      'Task Completed',
      '$title has done',
      _silent,
    );
  }

  Future<void> showTimerExpired(String title) async {
    await _plugin.show(
      title.hashCode,
      'Time is Up',
      '$title timer has ended',
      _silent,
    );
  }
}
