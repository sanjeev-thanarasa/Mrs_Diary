import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kFcmChannelId = 'mrs_diary_alerts';
const String _badgeKey = 'fcm_badge_count';

final AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
  kFcmChannelId,
  'MRS Alerts',
  description: 'Due and expiry alerts',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await FcmService.showLocalNotification(message);
}

class FcmService {
  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_defaultChannel);

    FirebaseMessaging.onMessage.listen(showLocalNotification);

    await _syncBadgeOnLaunch();

    final token = await messaging.getToken();
    await _saveToken(token);
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);
  }

  static Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _defaultChannel.id,
      _defaultChannel.name,
      channelDescription: _defaultChannel.description,
      importance: Importance.high,
      priority: Priority.high,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title ?? 'MRS Diary',
      notification.body ?? '',
      notificationDetails,
    );

    await _incrementBadge();
  }

  static Future<void> clearBadge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_badgeKey, 0);
    if (await FlutterAppBadger.isAppBadgeSupported()) {
      FlutterAppBadger.removeBadge();
    }
  }

  static Future<void> _incrementBadge() async {
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt(_badgeKey) ?? 0) + 1;
    await prefs.setInt(_badgeKey, next);
    if (await FlutterAppBadger.isAppBadgeSupported()) {
      FlutterAppBadger.updateBadgeCount(next);
    }
  }

  static Future<void> _syncBadgeOnLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_badgeKey) ?? 0;
    if (count <= 0) return;
    if (await FlutterAppBadger.isAppBadgeSupported()) {
      FlutterAppBadger.updateBadgeCount(count);
    }
  }

  static Future<void> _saveToken(String? token) async {
    if (token == null || token.isEmpty) return;
    final ownerId = currentOwnerId();
    if (ownerId == null || ownerId.isEmpty) return;

    final doc =
        FirebaseFirestore.instance.collection('UserTokens').doc(ownerId);
    await doc.set({
      'ownerId': ownerId,
      'tokens': FieldValue.arrayUnion([token]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
