// // provider_notifications_screen.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:audioplayers/audioplayers.dart';
//
// import '../services/send_notification_service.dart';
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
//     _audioPlayer.setSource(AssetSource('sounds/notification.mp3'));
//   }
//
//   Future<String?> getUserToken(String userId) async {
//     try {
//       final snapshot =
//           await _dbRef.child("users").child(userId).child("token").get();
//
//       if (snapshot.exists) {
//         return snapshot.value as String;
//       } else {
//         debugPrint(" No token found for user $userId");
//         return null;
//       }
//     } catch (e) {
//       debugPrint(" Error fetching user token: $e");
//       return null;
//     }
//   }
//
//   Future<String?> getUserName(String userId) async {
//     try {
//       final snapshot =
//           await _dbRef.child("users").child(userId).child("name").get();
//       if (snapshot.exists) {
//         return snapshot.value as String;
//       } else {
//         debugPrint("error fetching name $userId");
//         return null;
//       }
//     } catch (e) {
//       debugPrint("error fetching user name ");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = _auth.currentUser;
//     if (user == null) {
//       return const Scaffold(body: Center(child: Text('Please login first')));
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Booking Requests',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         centerTitle: true,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
//         ),
//         backgroundColor: Colors.white38,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: StreamBuilder<DatabaseEvent>(
//         stream:
//             _dbRef
//                 .child('appointments')
//                 .orderByChild('providerId')
//                 .equalTo(user.uid)
//                 .onValue,
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
//           // Filter unconfirmed appointments
//           final appointmentsMap =
//               snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
//           final pendingAppointments =
//               appointmentsMap.entries
//                   .where(
//                     (entry) =>
//                         entry.value['isConfirmed'] == false &&
//                         entry.value['status'] != 'rejected',
//                   )
//                   .toList()
//                   .reversed; // latest first
//
//           return ListView.builder(
//             itemCount: pendingAppointments.length,
//             itemBuilder: (context, index) {
//               final appointment = pendingAppointments.elementAt(index);
//               final data = appointment.value as Map<dynamic, dynamic>;
//
//               return Card(
//                 margin: const EdgeInsets.all(8.0),
//                 child: ListTile(
//                   leading: const Icon(Icons.event, color: Colors.blue),
//                   title: Text('Booking for ${data['serviceName']}',style: TextStyle(color: Colors.redAccent,fontSize: 17,fontWeight: FontWeight.bold)),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//
//                     children: [
//                       Text('Customer: ${data['customerName']}',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black ),),
//                       const SizedBox(height: 4),
//                       Text('Service: ${data['serviceName']}',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black ),),
//                       const SizedBox(height: 4),
//
//                       Text('Problem: ${data['problemDescription']}',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black ),),
//                       const SizedBox(height: 4),
//
//                       Text(
//                         'Time: ${_formatTimestamp(data['appointmentTime'])}',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black ),
//
//                       ),
//                       const SizedBox(height: 4),
//
//                       GestureDetector(
//                         onTap: () {
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(Icons.account_balance_wallet, color: Colors.green, size: 24),
//                               SizedBox(width: 8), // spacing between icon and text
//                               Text('Price: Rs.${data['price']}',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.green),),
//
//                             ],
//                           ),
//                         ),
//                       )
//
//                     ],
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.verified, color: Colors.green),
//                         onPressed: () async {
//                           _handleBookingResponse(
//                             appointment.key.toString(),
//                             data,
//                             'accepted',
//                           );
//                           await SendNotificationService.sendNotificationUsingApi(
//                             token: await getUserToken(data['userId']),
//                             title: "Booking Accepted",
//                             body: "Your Booking For : ${data['serviceName']} has been accepted ",
//                             data: {
//                               "click_action": "To go to booking",
//                             },
//                           );
//                           EasyLoading.dismiss();
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.highlight_off, color: Colors.red),
//                         onPressed: () async {
//                           _handleBookingResponse(
//                             appointment.key.toString(),
//                             data,
//                             'rejected',
//                           );
//                           await SendNotificationService.sendNotificationUsingApi(
//                             token: await getUserToken(data['userId']),
//                             title: "Booking Rejected",
//                             body: "Your Booking For : ${data['serviceName']} has been rejected",
//                             data: {
//                               "click_action": "To go to booking",
//                             },
//                           );
//                           EasyLoading.dismiss();
//                         },
//                       ),
//                     ],
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
//     String appointmentId,
//     Map<dynamic, dynamic> data,
//     String status,
//   ) async {
//     try {
//       // Play response sound
//       await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
//
//       // Update appointment status
//       await _dbRef.child('appointments').child(appointmentId).update({
//         'status': status,
//         'isConfirmed': status == 'accepted',
//       });
//
//       // Send notification to user
//       final userToken = await getUserToken(data['userId']);
//       if (userToken != null) {
//         await SendNotificationService.sendNotificationUsingApi(
//           token: userToken,
//           title:
//               status == 'accepted' ? "Booking Confirmed!" : "Booking Declined",
//           body:
//               status == 'accepted'
//                   ? "Your ${data['serviceName']} booking has been confirmed"
//                   : "Your ${data['serviceName']} booking was declined",
//           data: {
//             "click_action": "FLUTTER_NOTIFICATION_CLICK",
//             "appointmentId": appointmentId,
//             "status": status,
//           },
//         );
//       }
//
//       // Show confirmation
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Booking ${status == 'accepted' ? 'accepted' : 'rejected'}!',
//           ),
//           backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
//         ),
//       );
//
//       // Update UI immediately
//       setState(() {});
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to update booking: $e')));
//     }
//   }
//
//   String _formatTimestamp(dynamic timestamp) {
//     try {
//       final date = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
//       return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
//     } catch (e) {
//       return 'Invalid date';
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:audioplayers/audioplayers.dart';

import '../services/send_notification_service.dart';

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

  @override
  void initState() {
    super.initState();
  }

  Future<String?> getUserToken(String userId) async {
    try {
      final snapshot =
          await _dbRef.child("users").child(userId).child("token").get();

      if (snapshot.exists) {
        return snapshot.value as String;
      }
      return null;
    } catch (e) {
      debugPrint(" Error fetching user token: $e");
      return null;
    }
  }

  Future<String?> getUserName(String userId) async {
    try {
      final snapshot =
          await _dbRef.child("users").child(userId).child("name").get();
      if (snapshot.exists) {
        return snapshot.value as String;
      } else {
        debugPrint("error fetching name $userId");
        return null;
      }
    } catch (e) {
      debugPrint("error fetching user name ");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Booking Requests',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,

        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream:
            _dbRef
                .child('appointments')
                .orderByChild('providerId')
                .equalTo(user.uid)
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

          // Filter unconfirmed appointments
          final appointmentsMap =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final pendingAppointments =
              appointmentsMap.entries
                  .where(
                    (entry) =>
                        entry.value['isConfirmed'] == false &&
                        entry.value['status'] != 'rejected',
                  )
                  .toList()
                  .reversed; // latest first

          return ListView.builder(
            itemCount: pendingAppointments.length,
            itemBuilder: (context, index) {
              final appointment = pendingAppointments.elementAt(index);
              final data = appointment.value as Map<dynamic, dynamic>;
              final userId = data['userId'] as String? ?? '';

              return FutureBuilder<String?>(
                future: getUserName(userId),
                builder: (context, nameSnapshot) {
                  String customerName = 'Loading...';
                  if (nameSnapshot.connectionState == ConnectionState.done) {
                    customerName = nameSnapshot.data ?? 'Unknown Customer';
                  }

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: const Icon(Icons.event, color: Colors.blue),
                      title: Text(
                        'Booking for ${data['serviceName']}',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer: $customerName',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Service: ${data['serviceName']}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Problem: ${data['problemDescription']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Time: ${_formatTimestamp(data['appointmentTime'])}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Price: Rs.${data['price']}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.verified,
                              color: Colors.green,
                            ),
                            onPressed: () async {
                              _handleBookingResponse(
                                appointment.key.toString(),
                                data,
                                'accepted',
                              );
                              await SendNotificationService.sendNotificationUsingApi(
                                token: await getUserToken(data['userId']),
                                title: "Booking Accepted",
                                body:
                                    "Your Booking For : ${data['serviceName']} has been accepted ",
                                data: {"click_action": "To go to booking"},
                              );
                              EasyLoading.dismiss();
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.highlight_off,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              _handleBookingResponse(
                                appointment.key.toString(),
                                data,
                                'rejected',
                              );
                              await SendNotificationService.sendNotificationUsingApi(
                                token: await getUserToken(data['userId']),
                                title: "Booking Rejected",
                                body:
                                    "Your Booking For : ${data['serviceName']} has been rejected",
                                data: {"click_action": "To go to booking"},
                              );
                              EasyLoading.dismiss();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleBookingResponse(
    String appointmentId,
    Map<dynamic, dynamic> data,
    String status,
  ) async {
    try {
      // Update appointment status
      await _dbRef.child('appointments').child(appointmentId).update({
        'status': status,
        'isConfirmed': status == 'accepted',
      });

      // Send notification to user
      final userToken = await getUserToken(data['userId']);
      if (userToken != null) {
        await SendNotificationService.sendNotificationUsingApi(
          token: userToken,
          title:
              status == 'accepted' ? "Booking Confirmed!" : "Booking Declined",
          body:
              status == 'accepted'
                  ? "Your ${data['serviceName']} booking has been confirmed"
                  : "Your ${data['serviceName']} booking was declined",
          data: {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "appointmentId": appointmentId,
            "status": status,
          },
        );
      }

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking ${status == 'accepted' ? 'accepted' : 'rejected'}!',
          ),
          backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
        ),
      );

      // Update UI immediately
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update booking: $e')));
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
