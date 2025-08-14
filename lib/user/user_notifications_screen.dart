// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';
// import 'package:sewamitra/notificationService.dart';
//
// class UserNotificationsScreen extends StatefulWidget {
//   const UserNotificationsScreen({super.key});
//
//   @override
//   State<UserNotificationsScreen> createState() =>
//       _UserNotificationsScreenState();
// }
//
// class _UserNotificationsScreenState extends State<UserNotificationsScreen> {
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
//         title: const Text('Notifications'),
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
//             return const Center(child: Text('No notifications'));
//           }
//
//           final notificationsMap =
//           snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
//           final notifications = notificationsMap.entries.toList();
//
//           notifications.sort((a, b) {
//             final aTime = a.value['timestamp'] ?? 0;
//             final bTime = b.value['timestamp'] ?? 0;
//             return bTime.compareTo(aTime); // Newest first
//           });
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
//                   subtitle: Text(data['body']),
//                   trailing: data['status'] == 'accepted'
//                       ? const Icon(Icons.check_circle, color: Colors.green)
//                       : data['status'] == 'rejected'
//                       ? const Icon(Icons.cancel, color: Colors.red)
//                       : const Icon(Icons.access_time, color: Colors.orange),
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
// }




import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sewamitra/notificationService.dart';
import 'package:audioplayers/audioplayers.dart';

class UserNotificationsScreen extends StatefulWidget {
  const UserNotificationsScreen({super.key});

  @override
  State<UserNotificationsScreen> createState() =>
      _UserNotificationsScreenState();
}

class _UserNotificationsScreenState extends State<UserNotificationsScreen> {
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
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () => NotificationService.markAllAsRead(),
          ),
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
            return const Center(child: Text('No notifications'));
          }

          final notificationsMap =
          snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final notifications = notificationsMap.entries.toList()
            ..sort((a, b) {
              final aTime = a.value['timestamp'] ?? 0;
              final bTime = b.value['timestamp'] ?? 0;
              return bTime.compareTo(aTime); // Newest first
            });

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
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
                    leading: _getNotificationIcon(data['type']),
                    title: Text(data['title'] ?? 'No title'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['body'] ?? ''),
                        if (data['appointmentTime'] != null)
                          Text('Time: ${_formatDate(data['appointmentTime'])}'),
                      ],
                    ),
                    trailing: data['status'] == 'accepted'
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : data['status'] == 'rejected'
                        ? const Icon(Icons.cancel, color: Colors.red)
                        : const Icon(Icons.access_time, color: Colors.orange),
                    onTap: () async {
                      // Play a sound when a notification is opened
                      await _audioPlayer
                          .play(AssetSource('sounds/notification.mp3'));
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

  Widget _getNotificationIcon(String? type) {
    switch (type) {
      case 'booking_request':
        return const Icon(Icons.book_online, color: Colors.blue);
      case 'booking_response':
        return const Icon(Icons.notifications_active, color: Colors.green);
      default:
        return const Icon(Icons.notifications, color: Colors.blue);
    }
  }

  String _formatDate(dynamic timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
      final twoDigits = (int n) => n.toString().padLeft(2, '0');
      return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} ${twoDigits(date.hour)}:${twoDigits(date.minute)}';
    } catch (e) {
      return 'Unknown date';
    }
  }
}
