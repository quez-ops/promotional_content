import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Stream controller to broadcast UI updates to our widgets
  final _messageStreamController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get messageStream => _messageStreamController.stream;

  Future<NotificationSettings> requestPermission() async {
    return await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<String?> getToken() async {
    // ignore: deprecated_member_use
    return await _fcm.getToken(
      vapidKey: 'BIck4pEmTkm_h83jYnVX841_7ZtcmTWSuZ__S8bcg4mPuhQ7ITQXjMCeGXQslAxQrvTdYG8ga2pu6uLGeK414Ok',
    );
  }

  void initializeListeners({
    required Function(RemoteMessage) onMessageReceived,
    required Function(RemoteMessage) onMessageOpened,
  }) {
    // 1. Foreground message receipt
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      onMessageReceived(message);
      _messageStreamController.add(message);
    });

    // 2. Background message tapped / opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onMessageOpened(message);
      _messageStreamController.add(message);
    });
  }

  // 3. Terminated cold-start check
  Future<RemoteMessage?> checkInitialMessage() async {
    return await _fcm.getInitialMessage();
  }

  void dispose() {
    _messageStreamController.close();
  }
}