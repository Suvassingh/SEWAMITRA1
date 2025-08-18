// //
//
//
// // notificationService.dart
// import 'dart:async';
// import 'dart:convert';
//
// import 'package:audioplayers/audioplayers.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class NotificationService {
//   static final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
//   static final FirebaseAuth _auth = FirebaseAuth.instance;
//   static final AudioPlayer _audioPlayer = AudioPlayer();
//
//   static StreamController<int> _unreadCountController = StreamController<int>.broadcast();
//   static Stream<int> get unreadCountStream => _unreadCountController.stream;
//
//   static StreamController<Map<String, dynamic>> _notificationController =
//   StreamController<Map<String, dynamic>>.broadcast();
//   static Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
//
//   static void initialize() {
//     final user = _auth.currentUser;
//     if (user != null) {
//       _setupNotificationListener(user.uid);
//       _updateUnreadCount(user.uid);
//     }
//
//     _auth.authStateChanges().listen((user) {
//       if (user != null) {
//         _setupNotificationListener(user.uid);
//         _updateUnreadCount(user.uid);
//       }
//     });
//   }
//
//   static void _setupNotificationListener(String userId) {
//     _dbRef.child('notifications/$userId').orderByChild('timestamp').onChildAdded.listen((event) {
//       final data = event.snapshot.value as Map<dynamic, dynamic>;
//       final notification = Map<String, dynamic>.from(data);
//
//       // Play sound for new notification
//       _audioPlayer.play(AssetSource('sounds/notification.mp3'));
//
//       // Add to stream for UI updates
//       _notificationController.add(notification);
//
//       // Update unread count
//       _updateUnreadCount(userId);
//     });
//   }
//
//   static Future<void> _updateUnreadCount(String userId) async {
//     final snapshot = await _dbRef.child('notifications/$userId')
//         .orderByChild('read')
//         .equalTo(false)
//         .once();
//
//     final count = snapshot.snapshot.children.length;
//     _unreadCountController.add(count);
//   }
//
//   static Future<void> sendBookingNotification(
//       String providerId, Map<String, dynamic> bookingData) async {
//     final notificationRef = _dbRef
//         .child('notifications')
//         .child(providerId)
//         .push();
//
//     await notificationRef.set({
//       'id': notificationRef.key,
//       'type': 'booking_request',
//       'title': 'New Booking Request',
//       'body': 'You have a new booking request for ${bookingData['serviceName']}',
//       'appointmentId': bookingData['appointmentId'],
//       'userId': bookingData['userId'],
//       'providerId': providerId,
//       'serviceName': bookingData['serviceName'],
//       'problemDescription': bookingData['problemDescription'],
//       'appointmentTime': bookingData['appointmentTime'],
//       'status': 'pending',
//       'timestamp': ServerValue.timestamp,
//       'read': false,
//     });
//   }
//
//   static Future<void> sendBookingResponse(
//       String userId, String appointmentId, String status) async {
//     final notificationRef = _dbRef
//         .child('notifications')
//         .child(userId)
//         .push();
//
//     await notificationRef.set({
//       'id': notificationRef.key,
//       'type': 'booking_response',
//       'title': status == 'accepted'
//           ? 'Booking Accepted'
//           : 'Booking Rejected',
//       'body': status == 'accepted'
//           ? 'Your booking has been accepted!'
//           : 'Your booking has been rejected.',
//       'appointmentId': appointmentId,
//       'status': status,
//       'read': false,
//       'timestamp': ServerValue.timestamp,
//     });
//   }
//
//   static Future<void> markAsRead(String notificationId) async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     await _dbRef
//         .child('notifications/${user.uid}/$notificationId')
//         .update({'read': true});
//
//     _updateUnreadCount(user.uid);
//   }
//
//   static Future<void> markAllAsRead() async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     final snapshot = await _dbRef
//         .child('notifications/${user.uid}')
//         .once();
//
//     if (snapshot.snapshot.value == null) return;
//
//     final Map<dynamic, dynamic> notifications =
//     snapshot.snapshot.value as Map<dynamic, dynamic>;
//
//     final updates = <String, dynamic>{};
//     notifications.forEach((key, value) {
//       if (value is Map && (value['read'] == false || value['read'] == null)) {
//         updates['$key/read'] = true;
//       }
//     });
//
//     if (updates.isNotEmpty) {
//       await _dbRef.child('notifications/${user.uid}').update(updates);
//       _updateUnreadCount(user.uid);
//     }
//   }
// }