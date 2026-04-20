import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/core/utils/global.dart';
import 'package:dariziflow_app/features/notifications/controllers/notification_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final _localNotif = FlutterLocalNotificationsPlugin();

  Future<NotificationService> init() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    await _localNotif.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundClick);

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      // Delay to let the app's navigation stack settle before routing
      Future.delayed(const Duration(milliseconds: 800), () {
        _handleBackgroundClick(initialMessage);
      });
    }

    return this;
  }

  Future<String?> getDeviceToken() async => await _fcm.getToken();

  void _showForegroundNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      _localNotif.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance',
          ),
        ),
        payload: message.data['screen'],
      );
      
      // Refresh notifications to update badges instantly in foreground
      try {
        Get.find<NotificationController>().fetchNotifications();
      } catch (e) {
        // controller might not be initialized yet
      }
    }
  }

  /// Routes the user to the screen specified in the notification payload,
  /// or saves it as a pending route if the user is not authenticated.
  Future<void> _navigateOrSavePendingRoute(String screen) async {
    final token = await AppStorage.getAccessToken();
    if (token != null) {
      Get.toNamed(screen);
    } else {
      box.write('pending_route', screen);
      Get.offAllNamed('/login');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      _navigateOrSavePendingRoute(response.payload!);
    }
  }

  void _handleBackgroundClick(RemoteMessage message) {
    final screen = message.data['screen'];
    if (screen != null) _navigateOrSavePendingRoute(screen);
  }
}
