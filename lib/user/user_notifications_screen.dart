import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login first')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Confirmed Appointments',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _dbRef
            .child('appointments')
            .orderByChild('userId')
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
            return const Center(child: Text('No confirmed appointments'));
          }

          final appointmentsMap =
          snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          // Convert to list, filter confirmed appointments, and sort
          final appointments = appointmentsMap.entries
              .where((entry) {
            final data = entry.value as Map<dynamic, dynamic>;
            return data['isConfirmed'] == true;
          })
              .toList()
            ..sort((a, b) {
              final aTime = a.value['appointmentTime'] ?? 0;
              final bTime = b.value['appointmentTime'] ?? 0;
              return bTime.compareTo(aTime); // Newest first
            });

          if (appointments.isEmpty) {
            return const Center(child: Text('No confirmed appointments'));
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final data = appointment.value as Map<dynamic, dynamic>;
              final status = data['status'] ?? 'pending';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: _getStatusIcon(status),
                  title: Text(
                    data['serviceName'] ?? 'Unknown Service',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Provider: ${data['providerName'] ?? 'Unknown'}'),
                      const SizedBox(height: 4),
                      Text('Time: ${_formatDate(data['appointmentTime'])}'),
                      const SizedBox(height: 4),
                      Text('Status: ${status.toUpperCase()}'),
                      if (data['problemDescription'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Issue: ${data['problemDescription']}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                  trailing: Text(
                    'Rs.${data['price']?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'accepted':
        return const Icon(Icons.check_circle, color: Colors.green, size: 30);
      case 'rejected':
        return const Icon(Icons.cancel, color: Colors.red, size: 30);
      default:
        return const Icon(Icons.access_time, color: Colors.orange, size: 30);
    }
  }

  String _formatDate(dynamic timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
      return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year} ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}