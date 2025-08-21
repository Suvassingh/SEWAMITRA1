// bookings_screen.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:sewamitra/notificationService.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sewamitra/user/user_notifications_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isLoading = true;
  List<Map<String, dynamic>> bookings = [];

  // Helper function to safely convert dynamic values to double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    fetchBookings();
    // _setupNotificationListener();
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

            // Use helper function for safe conversion
            double providerLat = _toDouble(providerData['location']?['latitude']);
            double providerLng = _toDouble(providerData['location']?['longitude']);

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
            if (imageString.isNotEmpty) {
              try {
                // Handle both data URL and plain base64 formats
                if (imageString.startsWith('data:image')) {
                  final base64Data = imageString.split(',').last;
                  imageBytes = base64Decode(base64Data);
                } else {
                  imageBytes = base64Decode(imageString);
                }
              } catch (e) {
                print('Error decoding image for provider ${providerData['name']}: $e');
                imageBytes = null;
              }
            }

            // Only add accepted appointments to the list
            if (value['status'] == 'accepted') {
              tempBookings.add({
                'appointmentId': key,
                'serviceName': value['serviceName'] ?? 'Unknown Service',
                'price': _toDouble(value['price']), // Convert price to double
                'duration': value['duration'] ?? 0,
                'providerName': providerData['name'] ?? 'Unknown Provider',
                'providerImageBytes': imageBytes,
                'distance': distanceInKm,
                'providerLat': providerLat,
                'providerLng': providerLng,
                'appointmentTime': value['appointmentTime'] ?? 0,
                'status': value['status'] ?? 'Unknown',
                'providerId': providerId, // Added providerId for rating
              });
            }
          }
        });
      }

      // Sort by appointment time (newest first)
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load bookings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> completeBooking(String appointmentId, int index, double rating) async {
    try {
      final booking = bookings[index];
      final providerId = booking['providerId'];

      final appointmentSnapshot =
      await dbRef.child('appointments').child(appointmentId).get();

      if (!appointmentSnapshot.exists) {
        throw Exception('Appointment not found');
      }

      Map<String, dynamic> updates = {};
      updates['appointments/$appointmentId'] = null;
      updates['completedAppointments/$appointmentId'] = {
        ...appointmentSnapshot.value as Map<dynamic, dynamic>,
        'completedTime': DateTime.now().millisecondsSinceEpoch,
        'rating': rating, // Store rating with completed appointment
      };

      // Update provider's rating
      final providerRef = dbRef.child('providers/$providerId');
      final providerData = (await providerRef.get()).value as Map<dynamic, dynamic>? ?? {};

      // Calculate new average rating
      double currentAverage = _toDouble(providerData['averageRating']);
      int ratingCount = _toDouble(providerData['ratingCount']).toInt();

      double newAverage;
      if (ratingCount > 0) {
        newAverage = (currentAverage * ratingCount + rating) / (ratingCount + 1);
      } else {
        newAverage = rating;
      }

      // Update provider's rating data
      updates['providers/$providerId/averageRating'] = newAverage;
      updates['providers/$providerId/ratingCount'] = ratingCount + 1;

      await dbRef.update(updates);

      setState(() {
        bookings.removeAt(index);
      });

      _audioPlayer.play(AssetSource('sounds/success.mp3'));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking completed! Rated $rating stars'),
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

  void _showRatingDialog(String appointmentId, int index) {
    double rating = 0.0;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rate Provider',style: TextStyle(color: Colors.blue),),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('How was your experience?',style: TextStyle(color:Colors.green,fontWeight: FontWeight.bold ),),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        icon: Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = i + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    rating > 0 ? '${rating.toStringAsFixed(1)} Stars' : 'Select rating',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: rating == 0 || isSubmitting
                      ? null
                      : () async {
                    setState(() => isSubmitting = true);
                    await completeBooking(appointmentId, index, rating);
                    setState(() => isSubmitting = false);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Rating',style: TextStyle(color: Colors.black),),
                ),
              ],
            );
          },
        );
      },
    );
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
      backgroundColor: Colors.white,
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
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
          ? const Center(
        child: Text(
          "No accepted bookings found.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: Colors.green,
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
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ACCEPTED',
                          style: TextStyle(
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
                              '\$${booking['price'].toStringAsFixed(2)}',
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
                                      decoration:
                                      TextDecoration.underline,
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
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _showRatingDialog(
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

class RatingScreen extends StatefulWidget {
  final String appointmentId;
  final int index;

  const RatingScreen({
    super.key,
    required this.appointmentId,
    required this.index,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double rating = 0.0;
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Provider'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'How was your experience?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return IconButton(
                  icon: Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 50,
                  ),
                  onPressed: () {
                    setState(() {
                      rating = i + 1.0;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              rating > 0 ? '${rating.toStringAsFixed(1)} Stars' : 'Select rating',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: rating == 0 || isSubmitting
                  ? null
                  : () async {
                setState(() => isSubmitting = true);
                // Call completeBooking with rating
                final state = context.findAncestorStateOfType<_BookingsScreenState>();
                if (state != null) {
                  await state.completeBooking(widget.appointmentId, widget.index, rating);
                }
                setState(() => isSubmitting = false);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'Submit Rating',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}