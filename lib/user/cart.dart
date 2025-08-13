// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';
//
// class BookingsScreen extends StatefulWidget {
//   const BookingsScreen({super.key});
//
//   @override
//   State<BookingsScreen> createState() => _BookingsScreenState();
// }
//
// class _BookingsScreenState extends State<BookingsScreen> {
//   final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
//   final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
//
//   bool isLoading = true;
//   List<Map<String, dynamic>> bookings = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchBookings();
//   }
//
//   Future<void> fetchBookings() async {
//     try {
//       // Get user's current position
//       Position userPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       final appointmentsSnap =
//       await dbRef.child('appointments').get();
//
//       final providersSnap = await dbRef.child('providers').get();
//
//       List<Map<String, dynamic>> tempBookings = [];
//
//       if (appointmentsSnap.exists) {
//         Map<dynamic, dynamic> appointmentsData =
//         appointmentsSnap.value as Map<dynamic, dynamic>;
//
//         appointmentsData.forEach((key, value) {
//           if (value['userId'] == currentUserId) {
//             final providerId = value['providerId'];
//
//             // Get provider data
//             final providerData = (providersSnap.value
//             as Map<dynamic, dynamic>)[providerId] ??
//                 {};
//
//             double providerLat =
//                 providerData['location']?['latitude'] ?? 0.0;
//             double providerLng =
//                 providerData['location']?['longitude'] ?? 0.0;
//
//             // Calculate distance in km
//             double distanceInMeters = Geolocator.distanceBetween(
//               userPosition.latitude,
//               userPosition.longitude,
//               providerLat,
//               providerLng,
//             );
//
//             double distanceInKm = distanceInMeters / 1000;
//
//             tempBookings.add({
//               'serviceName': value['serviceName'],
//               'price': value['price'],
//               'duration': value['duration'],
//               'providerName': providerData['name'] ?? '',
//               'providerImage': providerData['profileImage'] ?? '',
//               'distance': distanceInKm,
//               'providerLat': providerLat,
//               'providerLng': providerLng,
//             });
//           }
//         });
//       }
//
//       setState(() {
//         bookings = tempBookings;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching bookings: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   void goToMap(double lat, double lng) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ProviderLocationMap(
//           latitude: lat,
//           longitude: lng,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'My Bookings',
//           style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.black),
//         ),
//         centerTitle: true,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(15),
//           ),
//         ),
//         backgroundColor: Colors.white38,
//         iconTheme: const IconThemeData(
//           color: Colors.black,
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : bookings.isEmpty
//           ? const Center(child: Text("No bookings found."))
//           : ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: bookings.length,
//         itemBuilder: (context, index) {
//           final booking = bookings[index];
//           return Card(
//             elevation: 1,
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Row(
//                 children: [
//                   // Provider image
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: booking['providerImage'] != ''
//                         ? Image.memory(
//                       base64Decode(booking['providerImage']),
//                       width: 80,
//                       height: 80,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => const Icon(
//                           Icons.person,
//                           size: 50),
//                     )
//                         : const Icon(Icons.person, size: 50),
//                   ),
//                   const SizedBox(width: 16),
//
//                   // Details
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           booking['serviceName'],
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           "Provider: ${booking['providerName']}",
//                           style: const TextStyle(
//                               color: Colors.grey, fontSize: 14),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           '\$${booking['price']} - ${booking['duration']} hr(s)',
//                           style: const TextStyle(
//                             color: Colors.brown,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         GestureDetector(
//                           onTap: () => goToMap(
//                               booking['providerLat'],
//                               booking['providerLng']),
//                           child: Text(
//                             "${booking['distance'].toStringAsFixed(2)} km away",
//                             style: const TextStyle(
//                                 color: Colors.blue,
//                                 decoration: TextDecoration.underline),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// // Simple Map Screen to show provider location
//
//
// class ProviderLocationMap extends StatelessWidget {
//   final double latitude;
//   final double longitude;
//
//   const ProviderLocationMap({
//     super.key,
//     required this.latitude,
//     required this.longitude,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final LatLng providerLatLng = LatLng(latitude, longitude);
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Provider Location')),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: providerLatLng,
//           zoom: 15,
//         ),
//         markers: {
//           Marker(
//             markerId: const MarkerId('provider'),
//             position: providerLatLng,
//             infoWindow: const InfoWindow(title: "Provider's Location"),
//           ),
//         },
//       ),
//     );
//   }
// }








import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  bool isLoading = true;
  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final appointmentsSnap = await dbRef.child('appointments').get();
      final providersSnap = await dbRef.child('providers').get();

      List<Map<String, dynamic>> tempBookings = [];

      if (appointmentsSnap.exists) {
        Map<dynamic, dynamic> appointmentsData =
        appointmentsSnap.value as Map<dynamic, dynamic>;

        appointmentsData.forEach((key, value) {
          if (value['userId'] == currentUserId) {
            final providerId = value['providerId'];
            final providerData =
                (providersSnap.value as Map<dynamic, dynamic>)[providerId] ?? {};

            double providerLat = providerData['location']?['latitude'] ?? 0.0;
            double providerLng = providerData['location']?['longitude'] ?? 0.0;

            double distanceInKm = 0.0;
            if (providerLat != 0.0 && providerLng != 0.0) {
              double distanceInMeters = Geolocator.distanceBetween(
                userPosition.latitude,
                userPosition.longitude,
                providerLat,
                providerLng,
              );
              distanceInKm = distanceInMeters / 1000;
            }

            String imageString = providerData['profileImage'] ?? '';
            Uint8List? imageBytes;
            if (imageString.isNotEmpty && imageString != "aaa") {
              try {
                if (imageString.startsWith('data:image')) {
                  final parts = imageString.split(',');
                  if (parts.length > 1) {
                    imageBytes = base64Decode(parts[1]);
                  }
                } else {
                  imageBytes = base64Decode(imageString);
                }
              } catch (e) {
                print('Error decoding image: $e');
                imageBytes = null;
              }
            }

            tempBookings.add({
              'appointmentId': key,
              'serviceName': value['serviceName'] ?? 'Unknown Service',
              'price': value['price'] ?? 0.0,
              'duration': value['duration'] ?? 0,
              'providerName': providerData['name'] ?? 'Unknown Provider',
              'providerImageBytes': imageBytes,
              'distance': distanceInKm,
              'providerLat': providerLat,
              'providerLng': providerLng,
              'appointmentTime': value['appointmentTime'] ?? 0,
              'status': value['status'] ?? 'Unknown',
            });
          }
        });
      }

      tempBookings.sort(
              (a, b) => b['appointmentTime'].compareTo(a['appointmentTime']));

      setState(() {
        bookings = tempBookings;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching bookings: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> completeBooking(String appointmentId, int index) async {
    try {
      // Get the appointment data
      final appointmentSnapshot =
      await dbRef.child('appointments').child(appointmentId).get();

      if (!appointmentSnapshot.exists) {
        throw Exception('Appointment not found');
      }

      // Create a map for the multi-location update
      Map<String, dynamic> updates = {};

      // Remove from appointments
      updates['appointments/$appointmentId'] = null;

      // Add to completedAppointments
      updates['completedAppointments/$appointmentId'] = {
        ...appointmentSnapshot.value as Map<dynamic, dynamic>,
        'completedTime': DateTime.now().millisecondsSinceEpoch,
      };

      // Perform the atomic update
      await dbRef.update(updates);

      // Remove from local list
      setState(() {
        bookings.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking marked as completed!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error completing booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void goToMap(double lat, double lng) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderLocationMap(
          latitude: lat,
          longitude: lng,
        ),
      ),
    );
  }

  String _formatDateTime(int timestamp) {
    if (timestamp == 0) return 'No date';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildProviderImage(Uint8List? imageBytes) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: imageBytes != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.person, size: 40),
        ),
      )
          : const Icon(Icons.person, size: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Bookings',
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
        backgroundColor: Colors.white38,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
          ? const Center(child: Text("No bookings found."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: booking['status'] == 'pending'
                    ? Colors.orange
                    : Colors.green,
                width: 2,
              ),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: booking['status'] == 'pending'
                              ? Colors.orange
                              : Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking['status'].toString().toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDateTime(booking['appointmentTime']),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildProviderImage(booking['providerImageBytes']),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['serviceName'],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Provider: ${booking['providerName']}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${booking['price']}',
                              style: const TextStyle(
                                color: Colors.brown,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => goToMap(
                                booking['providerLat'],
                                booking['providerLng'],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 16, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text(
                                    booking['distance'] > 0
                                        ? "${booking['distance'].toStringAsFixed(2)} km away"
                                        : "Distance unavailable",
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (booking['status'] == 'pending')
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => completeBooking(
                            booking['appointmentId'],
                            index,
                          ),
                          child: const Text(
                            'MARK AS COMPLETED',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProviderLocationMap extends StatelessWidget {
  final double latitude;
  final double longitude;

  const ProviderLocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng providerLatLng = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(title: const Text('Provider Location')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: providerLatLng,
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: providerLatLng,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}