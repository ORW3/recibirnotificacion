import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:async';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  FirebaseApi() {
// Initialize the FlutterLocalNotificationsPlugin
    _initializeLocalNotifications();

    _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static String? mensaje;

  static final StreamController<void> _notificationController =
      StreamController<void>.broadcast();

  static Stream<void> get notificationStream => _notificationController.stream;

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _localNotifications.initialize(initializationSettings);
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token:  $fCMToken');

    FirebaseMessaging.onMessage.listen(handleFirebaseMessage);
  }

  Future handleFirebaseMessage(RemoteMessage message) async {
    var notification = message.notification;
    if (notification == null) return;
    mensaje = notification.body;

    final AndroidNotificationDetails androidChannel =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    final notificationDetails = NotificationDetails(android: androidChannel);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: jsonEncode(message.toMap()),
    );

    _notificationController.add(null);
  }
}
