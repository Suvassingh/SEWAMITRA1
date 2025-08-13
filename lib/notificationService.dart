// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:badges/badges.dart' as badges;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:overlay_support/overlay_support.dart';
//
// class NotificationService {
//   static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _localNotifications =
//   FlutterLocalNotificationsPlugin();
//
//   static StreamController<Map<String, dynamic>> _notificationStreamController =
//   StreamController.broadcast();
//
//   static Stream<Map<String, dynamic>> get notificationStream =>
//       _notificationStreamController.stream;
//
//   static Future<void> initialize() async {
//     // Request permissions
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission');
//     } else {
//       print('User declined or has not accepted permission');
//     }
//
//     // Initialize local notifications
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const DarwinInitializationSettings initializationSettingsIOS =
//     DarwinInitializationSettings();
//
//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//
//     await _localNotifications.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (details) {
//         if (details.payload != null) {
//           _notificationStreamController.add(json.decode(details.payload!));
//         }
//       },
//     );
//
//     // Get FCM token
//     String? token = await _firebaseMessaging.getToken();
//     print("FCM Token: $token");
//
//     // Save token to user profile
//     saveTokenToUserProfile(token);
//
//     // Handle token refresh
//     _firebaseMessaging.onTokenRefresh.listen(saveTokenToUserProfile);
//
//     // Handle messages in different states
//     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
//     FirebaseMessaging.instance.getInitialMessage().then(_handleTerminatedMessage);
//
//     // Create notification channel for Android
//     if (Platform.isAndroid) {
//       const AndroidNotificationChannel channel = AndroidNotificationChannel(
//         'sewamitra_channel',
//         'SewaMitra Notifications',
//         importance: Importance.max,
//       );
//
//       await _localNotifications
//           .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//           ?.createNotificationChannel(channel);
//     }
//   }
//
//   static Future<void> saveTokenToUserProfile(String? token) async {
//     if (token == null) return;
//
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       await FirebaseFirestore.instance
//           .collection('providers')
//           .doc(user.uid)
//           .update({'fcmToken': token});
//     }
//   }
//
//   static Future<void> _showLocalNotification(RemoteMessage message) async {
//     final notification = message.notification;
//     final data = message.data;
//
//     AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
//       'sewamitra_channel',
//       'SewaMitra Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//
//     DarwinNotificationDetails iosDetails = const DarwinNotificationDetails();
//
//     NotificationDetails platformDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     await _localNotifications.show(
//       notification?.hashCode ?? 0,
//       notification?.title,
//       notification?.body,
//       platformDetails,
//       payload: json.encode(data),
//     );
//   }
//
//   static void _handleForegroundMessage(RemoteMessage message) {
//     print('Foreground message: ${message.messageId}');
//     _showLocalNotification(message);
//     _saveNotificationToFirestore(message);
//   }
//
//   static void _handleBackgroundMessage(RemoteMessage message) {
//     print('Background message: ${message.messageId}');
//     _notificationStreamController.add(message.data);
//   }
//
//   static void _handleTerminatedMessage(RemoteMessage? message) {
//     if (message != null) {
//       print('Terminated message: ${message.messageId}');
//       _notificationStreamController.add(message.data);
//     }
//   }
//
//   static Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//
//     final notification = message.notification;
//     final data = message.data;
//
//     await FirebaseFirestore.instance
//         .collection('notifications')
//         .doc(user.uid)
//         .collection('user_notifications')
//         .add({
//       'title': notification?.title ?? 'New Notification',
//       'body': notification?.body ?? '',
//       'type': data['type'] ?? 'general',
//       'payload': data,
//       'timestamp': FieldValue.serverTimestamp(),
//       'read': false,
//     });
//   }
//
//   static Future<void> subscribeToTopics() async {
//     await _firebaseMessaging.subscribeToTopic('providers');
//     await _firebaseMessaging.subscribeToTopic('notifications');
//   }
//
//   static Widget notificationBadge() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('notifications')
//           .doc(FirebaseAuth.instance.currentUser?.uid)
//           .collection('user_notifications')
//           .where('read', isEqualTo: false)
//           .snapshots(),
//       builder: (context, snapshot) {
//         int count = snapshot.data?.docs.length ?? 0;
//         return badges.Badge(
//           showBadge: count > 0, // Show only if count > 0
//           badgeContent: Text(
//             count.toString(),
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           badgeStyle: badges.BadgeStyle(
//             badgeColor: Colors.red,
//             padding: const EdgeInsets.all(6),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: IconButton(
//             icon: const Icon(Icons.notifications),
//             onPressed: () => Navigator.pushNamed(context, '/notifications'),
//           ),
//         );
//       },
//     );
//   }
// }