// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';
// import 'package:sewamitra/notificationService.dart';
//
// class ProviderNotificationsScreen extends StatefulWidget {
//   const ProviderNotificationsScreen({super.key});
//
//   @override
//   State<ProviderNotificationsScreen> createState() =>
//       _ProviderNotificationsScreenState();
// }
//
// class _ProviderNotificationsScreenState
//     extends State<ProviderNotificationsScreen> {
//   final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     final user = _auth.currentUser;
//     if (user == null) {
//       return const Scaffold(
//         body: Center(child: Text('Please login first')),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Booking Requests'),
//       ),
//       body: StreamBuilder<DatabaseEvent>(
//         stream: NotificationService.getNotificationsStream(user.uid),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
//             return const Center(child: Text('No booking requests'));
//           }
//
//           final notificationsMap =
//           snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
//           final notifications = notificationsMap.entries
//               .where((entry) => entry.value['type'] == 'booking_request')
//               .toList();
//
//           return ListView.builder(
//             itemCount: notifications.length,
//             itemBuilder: (context, index) {
//               final notification = notifications[index];
//               final data = notification.value as Map<dynamic, dynamic>;
//               final isRead = data['read'] ?? false;
//
//               return Card(
//                 color: isRead ? Colors.grey[200] : Colors.blue[50],
//                 margin: const EdgeInsets.all(8.0),
//                 child: ListTile(
//                   title: Text(data['title']),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(data['body']),
//                       Text('Service: ${data['serviceName']}'),
//                       Text('Problem: ${data['problemDescription']}'),
//                     ],
//                   ),
//                   trailing: data['status'] == 'pending'
//                       ? Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.check, color: Colors.green),
//                         onPressed: () => _handleBookingResponse(
//                             notification.key, data, 'accepted'),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.close, color: Colors.red),
//                         onPressed: () => _handleBookingResponse(
//                             notification.key, data, 'rejected'),
//                       ),
//                     ],
//                   )
//                       : Text(
//                     data['status'] == 'accepted'
//                         ? 'Accepted'
//                         : 'Rejected',
//                     style: TextStyle(
//                       color: data['status'] == 'accepted'
//                           ? Colors.green
//                           : Colors.red,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   onTap: () {
//                     NotificationService.markAsRead(
//                         user.uid, notification.key);
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> _handleBookingResponse(
//       String notificationId, Map<dynamic, dynamic> data, String status) async {
//     try {
//       // Update appointment status
//       await _dbRef
//           .child('appointments')
//           .child(data['appointmentId'])
//           .update({'status': status});
//
//       // Update notification status
//       await _dbRef
//           .child('notifications')
//           .child(_auth.currentUser!.uid)
//           .child(notificationId)
//           .update({'status': status});
//
//       // Send response to user
//       await NotificationService.sendBookingResponse(
//         data['userId'],
//         data['appointmentId'],
//         status,
//       );
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Booking $status successfully!'),
//           backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update booking: $e')),
//       );
//     }
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:sewamitra/notificationService.dart';
// import 'package:audioplayers/audioplayers.dart';
//
// class ProviderNotificationsScreen extends StatefulWidget {
//   const ProviderNotificationsScreen({super.key});
//
//   @override
//   State<ProviderNotificationsScreen> createState() =>
//       _ProviderNotificationsScreenState();
// }
//
// class _ProviderNotificationsScreenState
//     extends State<ProviderNotificationsScreen> {
//   final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final AudioPlayer _audioPlayer = AudioPlayer();
//
//   @override
//   void initState() {
//     super.initState();
//     // Mark all notifications as read when screen opens
//     NotificationService.markAllAsRead();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = _auth.currentUser;
//     if (user == null) {
//       return const Scaffold(
//         body: Center(child: Text('Please login first')),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Booking Requests'),
//         actions: [
//           StreamBuilder<int>(
//             stream: NotificationService.unreadCountStream,
//             builder: (context, snapshot) {
//               final count = snapshot.data ?? 0;
//               return Badge(
//                 label: Text('$count'),
//                 isLabelVisible: count > 0,
//                 child: IconButton(
//                   icon: const Icon(Icons.notifications),
//                   onPressed: () {},
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<DatabaseEvent>(
//         stream: _dbRef
//             .child('notifications/${user.uid}')
//             .orderByChild('timestamp')
//             .onValue,
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
//             return const Center(child: Text('No booking requests'));
//           }
//
//           final notificationsMap =
//           snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
//           final notifications = notificationsMap.entries
//               .where((entry) => entry.value['type'] == 'booking_request')
//               .toList()
//               .reversed; // latest first
//
//           return ListView.builder(
//             itemCount: notifications.length,
//             itemBuilder: (context, index) {
//               final notification = notifications.elementAt(index);
//               final data = notification.value as Map<dynamic, dynamic>;
//               final isRead = data['read'] ?? false;
//
//               return Dismissible(
//                 key: Key(notification.key!),
//                 background: Container(color: Colors.red),
//                 onDismissed: (direction) {
//                   _dbRef
//                       .child('notifications/${user.uid}/${notification.key}')
//                       .remove();
//                 },
//                 child: Card(
//                   color: isRead ? Colors.grey[200] : Colors.blue[50],
//                   margin: const EdgeInsets.all(8.0),
//                   child: ListTile(
//                     leading: const Icon(
//                       Icons.notifications_active,
//                       color: Colors.blue,
//                     ),
//                     title: Text(data['title']),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(data['body']),
//                         const SizedBox(height: 4),
//                         Text('Service: ${data['serviceName']}'),
//                         Text('Problem: ${data['problemDescription']}'),
//                       ],
//                     ),
//                     trailing: data['status'] == 'pending'
//                         ? Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.check,
//                               color: Colors.green),
//                           onPressed: () => _handleBookingResponse(
//                               notification.key, data, 'accepted'),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.close, color: Colors.red),
//                           onPressed: () => _handleBookingResponse(
//                               notification.key, data, 'rejected'),
//                         ),
//                       ],
//                     )
//                         : Text(
//                       data['status'] == 'accepted'
//                           ? 'Accepted'
//                           : 'Rejected',
//                       style: TextStyle(
//                         color: data['status'] == 'accepted'
//                             ? Colors.green
//                             : Colors.red,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     onTap: () {
//                       NotificationService.markAsRead(notification.key!);
//                     },
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> _handleBookingResponse(
//       String? notificationId, Map<dynamic, dynamic> data, String status) async {
//     if (notificationId == null) return;
//
//     try {
//       // Play response sound
//       await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
//
//       // Update appointment status
//       await _dbRef
//           .child('appointments')
//           .child(data['appointmentId'])
//           .update({'status': status});
//
//       // Update notification status
//       await _dbRef
//           .child('notifications/${_auth.currentUser!.uid}/$notificationId')
//           .update({'status': status});
//
//       // Mark as read
//       await NotificationService.markAsRead(notificationId);
//
//       // Send response to user
//       await NotificationService.sendBookingResponse(
//         data['userId'],
//         data['appointmentId'],
//         status,
//       );
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Booking $status successfully!'),
//           backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update booking: $e')),
//       );
//     }
//   }
// }




// provider_notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sewamitra/notificationService.dart';
import 'package:audioplayers/audioplayers.dart';

class ProviderNotificationsScreen extends StatefulWidget {
  const ProviderNotificationsScreen({super.key});

  @override
  State<ProviderNotificationsScreen> createState() =>
      _ProviderNotificationsScreenState();
}

class _ProviderNotificationsScreenState
    extends State<ProviderNotificationsScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Mark all notifications as read when screen opens
    NotificationService.markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login first')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests'),
        actions: [
          StreamBuilder<int>(
            stream: NotificationService.unreadCountStream,
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Badge(
                label: Text('$count'),
                isLabelVisible: count > 0,
                child: IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {},
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _dbRef
            .child('notifications/${user.uid}')
            .orderByChild('timestamp')
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('No booking requests'));
          }

          final notificationsMap =
          snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final notifications = notificationsMap.entries
              .where((entry) => entry.value['type'] == 'booking_request')
              .toList()
              .reversed; // latest first

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications.elementAt(index);
              final data = notification.value as Map<dynamic, dynamic>;
              final isRead = data['read'] ?? false;

              return Dismissible(
                key: Key(notification.key!),
                background: Container(color: Colors.red),
                onDismissed: (direction) {
                  _dbRef
                      .child('notifications/${user.uid}/${notification.key}')
                      .remove();
                },
                child: Card(
                  color: isRead ? Colors.grey[200] : Colors.blue[50],
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(
                      Icons.notifications_active,
                      color: Colors.blue,
                    ),
                    title: Text(data['title']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['body']),
                        const SizedBox(height: 4),
                        Text('Service: ${data['serviceName']}'),
                        Text('Problem: ${data['problemDescription']}'),
                      ],
                    ),
                    trailing: data['status'] == 'pending'
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check,
                              color: Colors.green),
                          onPressed: () => _handleBookingResponse(
                              notification.key, data, 'accepted'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _handleBookingResponse(
                              notification.key, data, 'rejected'),
                        ),
                      ],
                    )
                        : Text(
                      data['status'] == 'accepted'
                          ? 'Accepted'
                          : 'Rejected',
                      style: TextStyle(
                        color: data['status'] == 'accepted'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      NotificationService.markAsRead(notification.key!);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleBookingResponse(
      String? notificationId, Map<dynamic, dynamic> data, String status) async {
    if (notificationId == null) return;

    try {
      // Play response sound
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));

      // Update appointment status
      await _dbRef
          .child('appointments')
          .child(data['appointmentId'])
          .update({'status': status});

      // Update notification status
      await _dbRef
          .child('notifications/${_auth.currentUser!.uid}/$notificationId')
          .update({'status': status});

      // Mark as read
      await NotificationService.markAsRead(notificationId);

      // Send response to user
      await NotificationService.sendBookingResponse(
        data['userId'],
        data['appointmentId'],
        status,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking $status successfully!'),
          backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update booking: $e')),
      );
    }
  }
}