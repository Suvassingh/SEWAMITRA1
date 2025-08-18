// user_home_screen.dart
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sewamitra/user/user_notifications_screen.dart';

import '../notificationService.dart';
import '../services/send_notification_service.dart';

// Service Model
class Service {
  final String id;
  final String name;
  final String imageUrl;

  Service({required this.id, required this.name, required this.imageUrl});
}

// Location Model
class LocationModel {
  final String address;
  final double latitude;
  final double longitude;

  LocationModel({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory LocationModel.fromMap(Map<dynamic, dynamic> map) {
    return LocationModel(
      address: map['address'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'address': address, 'latitude': latitude, 'longitude': longitude};
  }
}

// Service Offering Model
class ServiceOffering {
  final int experience;
  final double hourlyCharge;
  final String idProof;
  final LocationModel location;
  final String providerId;
  final int registrationDate;
  final String serviceId;
  final String serviceName;
  final String status;

  ServiceOffering({
    required this.experience,
    required this.hourlyCharge,
    required this.idProof,
    required this.location,
    required this.providerId,
    required this.registrationDate,
    required this.serviceId,
    required this.serviceName,
    required this.status,
  });

  factory ServiceOffering.fromMap(Map<dynamic, dynamic> map) {
    return ServiceOffering(
      experience: map['experience'] ?? 0,
      hourlyCharge: map['hourly_charge']?.toDouble() ?? 0.0,
      idProof: map['id_proof'] ?? '',
      location: LocationModel.fromMap(
        Map<String, dynamic>.from(map['location']),
      ),
      providerId: map['provider_id'] ?? '',
      registrationDate: map['registration_date'] ?? 0,
      serviceId: map['service_id'] ?? '',
      serviceName: map['service_name'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }
}

// Provider Model
class ProviderModel {
  final int createdAt;
  final String email;
  final String name;
  final String phone;
  final String role;
  final String? profileImage;
  final double averageRating;

  final Map<String, ServiceOffering> services;
  final String uid;

  ProviderModel({
    required this.createdAt,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.profileImage,
    required this.services,
    required this.uid,
    required this.averageRating,
  });

  factory ProviderModel.fromMap(Map<dynamic, dynamic> map) {
    return ProviderModel(
      createdAt: map['createdAt'] ?? 0,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      profileImage: map['profileImage'],
      role: map['role'] ?? '',
      services:
          (map['services'] as Map<dynamic, dynamic>?)?.map((key, value) {
            return MapEntry(
              key.toString(),
              ServiceOffering.fromMap(Map<String, dynamic>.from(value)),
            );
          }) ??
          {},
      uid: map['uid'] ?? '',
      averageRating: map['averageRating']?.toDouble() ?? 0.0,
    );
  }
}

// Service Provider Display Model
class ServiceProviderDisplay {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage; // Add profile image
  final String serviceId;
  final String serviceName;
  final int experience;
  final double hourlyRate;
  final LocationModel location;
  final double distance;
  final double averageRating;

  ServiceProviderDisplay({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.serviceId,
    required this.serviceName,
    required this.experience,
    required this.hourlyRate,
    required this.location,
    required this.distance,
    required this.averageRating,
  });
}

// Service Data Provider (ChangeNotifier)
class ServiceDataProvider with ChangeNotifier {
  List<Service> _services = [
    Service(
      id: '1',
      name: 'Cleaning',
      imageUrl:
          'https://images.unsplash.com/photo-1581578021426-3c1b74b96b6a?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80',
    ),
    Service(
      id: '2',
      name: 'Plumbing',
      imageUrl:
          'https://images.unsplash.com/photo-1633441380346-615a1a87f7c3?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80',
    ),
    Service(
      id: '3',
      name: 'Electrical',
      imageUrl:
          'https://images.unsplash.com/photo-1590959651373-a3db0f38a961?ixlib=rb-4.0.3&auto=format&fit=crop&w=1478&q=80',
    ),
    Service(
      id: '4',
      name: 'Painting',
      imageUrl:
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80',
    ),
    Service(
      id: '5',
      name: 'Carpenter',
      imageUrl:
          'https://images.unsplash.com/photo-1601342630314-8427c38bf5e6?ixlib=rb-4.0.3&auto=format&fit=crop&w=1381&q=80',
    ),
    Service(
      id: '6',
      name: 'Gardening',
      imageUrl:
          'https://images.unsplash.com/photo-1591892150210-0be5b3c7d7b1?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80',
    ),
  ];

  List<ProviderModel> _providers = [];
  LocationModel? _userLocation;

  List<Service> get services => _services;

  LocationModel? get userLocation => _userLocation;

  Future<void> loadProviders() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final providersData = data['providers'] as Map<dynamic, dynamic>? ?? {};

      _providers =
          providersData.values.map((p) {
            return ProviderModel.fromMap(Map<dynamic, dynamic>.from(p));
          }).toList();

      notifyListeners();
    }
  }

  void setUserLocation(LocationModel location) {
    _userLocation = location;
    notifyListeners();
  }

  // Search method
  List<Service> searchServices(String query) {
    if (query.isEmpty) return _services;

    return _services.where((service) {
      return service.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Get providers for a specific service within 20 km range
  List<ServiceProviderDisplay> getProvidersForService(String serviceId) {
    if (_userLocation == null) return [];

    final providers = <ServiceProviderDisplay>[];

    for (final provider in _providers) {
      for (final serviceEntry in provider.services.entries) {
        final service = serviceEntry.value;
        if (service.serviceId == serviceId) {
          // Calculate distance using geolocator
          double distance =
              Geolocator.distanceBetween(
                _userLocation!.latitude,
                _userLocation!.longitude,
                service.location.latitude,
                service.location.longitude,
              ) /
              1000; // Convert to kilometers

          // Only include providers within 20 km
          if (distance <= 20000.0) {
            providers.add(
              ServiceProviderDisplay(
                id: provider.uid,
                name: provider.name,
                email: provider.email,
                phone: provider.phone,
                profileImage: provider.profileImage,
                averageRating: provider.averageRating,
                serviceId: service.serviceId,
                serviceName: service.serviceName,
                experience: service.experience,
                hourlyRate: service.hourlyCharge,
                location: service.location,
                distance: distance,
              ),
            );
          }
        }
      }
    }

    // Sort by distance
    providers.sort((a, b) => a.distance.compareTo(b.distance));

    return providers;
  }
}

// Location Screen
class LocationScreen extends StatefulWidget {
  static const routeName = '/location';

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _locationController = TextEditingController();
  LocationModel? _selectedLocation;

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();

      setState(() {
        _selectedLocation = LocationModel(
          address: "Current Location",
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _locationController.text = "Current Location";
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not get location: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Set Your Location',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        backgroundColor: Colors.white38,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Enter Location',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.location_on, color: Colors.black),
                  onPressed: _getCurrentLocation,
                ),
              ),
              onChanged: (value) {
                // You could add address lookup here
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_selectedLocation != null) {
                  // Save to user data in Firebase
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId != null) {
                    FirebaseDatabase.instance
                        .ref()
                        .child('users')
                        .child(userId)
                        .update({'location': _selectedLocation!.toMap()});
                  }

                  // Update provider
                  Provider.of<ServiceDataProvider>(
                    context,
                    listen: false,
                  ).setUserLocation(_selectedLocation!);

                  Navigator.pop(context, _selectedLocation);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a location')),
                  );
                }
              },
              child: const Text('Save Location'),
            ),
          ],
        ),
      ),
    );
  }
}

// Service Providers Screen
class ServiceProvidersScreen extends StatelessWidget {
  static const routeName = '/service_providers';

  const ServiceProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceId = ModalRoute.of(context)!.settings.arguments as String;
    final serviceProviders = Provider.of<ServiceDataProvider>(
      context,
    ).getProvidersForService(serviceId);

    final service = Provider.of<ServiceDataProvider>(
      context,
    ).services.firstWhere((s) => s.id == serviceId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${service.name} Providers',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        backgroundColor: Colors.white38,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body:
          serviceProviders.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 50, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No nearby providers found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Try again later or search in a different location',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: serviceProviders.length,
                itemBuilder: (context, index) {
                  final provider = serviceProviders[index];
                  return ServiceProviderCard(provider: provider);
                },
              ),
    );
  }
}

class ServiceProviderCard extends StatelessWidget {
  final ServiceProviderDisplay provider;

  const ServiceProviderCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderDetailScreen(provider: provider),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    provider.profileImage != null &&
                            provider.profileImage!.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            base64Decode(
                              provider.profileImage!.split(',').last,
                            ),
                            fit: BoxFit.cover,
                          ),
                        )
                        : const Icon(Icons.person, size: 40),
              ),
              const SizedBox(width: 16),

              // Provider Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Experience
                    Row(
                      children: [
                        const Icon(Icons.work, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.experience} yrs exp',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const Spacer(),
                        RatingBarIndicator(
                          rating: provider.averageRating,
                          itemBuilder:
                              (context, index) =>
                                  const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 16,
                          direction: Axis.horizontal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          provider.averageRating.toStringAsFixed(1),
                          // e.g., 4.3
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Distance and Rate
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.distance.toStringAsFixed(1)} km away',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.attach_money,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Rs.${provider.hourlyRate}/hr',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Book Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      BookNowScreen(provider: provider),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Provider Detail Screen
class ProviderDetailScreen extends StatelessWidget {
  final ServiceProviderDisplay provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          provider.name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        backgroundColor: Colors.white38,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child:
                    provider.profileImage != null &&
                            provider.profileImage!.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.memory(
                            base64Decode(
                              provider.profileImage!.split(',').last,
                            ),
                            fit: BoxFit.cover,
                          ),
                        )
                        : const Icon(Icons.person, size: 60),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),

            // Service Info
            _buildDetailRow('Service', provider.serviceName),
            _buildDetailRow('Experience', '${provider.experience} years'),
            _buildDetailRow('Hourly Rate', 'Rs.${provider.hourlyRate}/hr'),
            _buildDetailRow('Phone', provider.phone),
            _buildDetailRow('Address', provider.location.address),
            _buildDetailRow(
              'Distance',
              '${provider.distance.toStringAsFixed(1)} km',
            ),
            const SizedBox(height: 40),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookNowScreen(provider: provider),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Book Appointment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

// Booking Screen

// class BookNowScreen extends StatefulWidget {
//   final ServiceProviderDisplay provider;
//
//   const BookNowScreen({Key? key, required this.provider}) : super(key: key);
//
//   @override
//   _BookNowScreenState createState() => _BookNowScreenState();
// }
//
// class _BookNowScreenState extends State<BookNowScreen> {
//   final _formKey = GlobalKey<FormState>();
//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;
//   final TextEditingController _problemController = TextEditingController();
//
//   void _pickDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }
//
//   void _pickTime() async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedTime = picked;
//       });
//     }
//   }
//
//   Future<String?> getProviderToken(String providerId) async {
//     try {
//       final snapshot =
//           await FirebaseDatabase.instance
//               .ref()
//               .child("providers")
//               .child(providerId)
//               .child("token")
//               .get();
//
//       if (snapshot.exists) {
//         return snapshot.value as String;
//       }
//       return null;
//     } catch (e) {
//       debugPrint("Error fetching provider token: $e");
//       return null;
//     }
//   }
//
//   Future<void> _submitBooking() async {
//     if (_formKey.currentState!.validate() &&
//         _selectedDate != null &&
//         _selectedTime != null) {
//       EasyLoading.show(status: 'Booking...');
//
//       final appointmentTime = DateTime(
//         _selectedDate!.year,
//         _selectedDate!.month,
//         _selectedDate!.day,
//         _selectedTime!.hour,
//         _selectedTime!.minute,
//       );
//
//       final userId = FirebaseAuth.instance.currentUser!.uid;
//       final userLocation =
//           Provider.of<ServiceDataProvider>(
//             context,
//             listen: false,
//           ).userLocation!;
//
//       // Create appointment data with isConfirmed: false
//       final appointment = {
//         'userId': userId,
//         'providerId': widget.provider.id,
//         'providerName': widget.provider.name,
//         'serviceId': widget.provider.serviceId,
//         'serviceName': widget.provider.serviceName,
//         'appointmentTime': appointmentTime.millisecondsSinceEpoch,
//         'problemDescription': _problemController.text,
//         'location': userLocation.toMap(),
//         'isConfirmed': false, // Initial status is false (unconfirmed)
//         'createdAt': DateTime.now().millisecondsSinceEpoch,
//         'price': widget.provider.hourlyRate,
//         'duration': 1,
//       };
//
//       try {
//         // Save to Firebase
//         final ref =
//             FirebaseDatabase.instance.ref().child('appointments').push();
//         final appointmentId = ref.key!;
//
//         await ref.set({...appointment, 'appointmentId': appointmentId});
//
//         // // Get provider token and send notification
//         // final providerToken = await getProviderToken(widget.provider.id);
//         // if (providerToken != null) {
//         //   await SendNotificationService.sendNotificationUsingApi(
//         //     token: providerToken,
//         //     title: "New Booking Request",
//         //     body:
//         //         "You have a new booking request from ${FirebaseAuth.instance.currentUser!.displayName}",
//         //     data: {
//         //       "click_action": "FLUTTER_NOTIFICATION_CLICK",
//         //       "appointmentId": appointmentId,
//         //     },
//         //
//         //   );
//         // }
//
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               'Booking request sent! Waiting for provider confirmation',
//             ),
//           ),
//         );
//       } catch (e) {
//         // EasyLoading.dismiss();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Booking failed: ${e.toString()}')),
//         );
//       }
//       // finally {
//       //   EasyLoading.dismiss();
//       // }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Book Appointment")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               ListTile(
//                 title: Text(
//                   _selectedDate == null
//                       ? "Select Date"
//                       : "${_selectedDate!.toLocal()}".split(' ')[0],
//                 ),
//                 trailing: const Icon(Icons.calendar_today),
//                 onTap: _pickDate,
//               ),
//               ListTile(
//                 title: Text(
//                   _selectedTime == null
//                       ? "Select Time"
//                       : _selectedTime!.format(context),
//                 ),
//                 trailing: const Icon(Icons.access_time),
//                 onTap: _pickTime,
//               ),
//               TextFormField(
//                 controller: _problemController,
//                 maxLines: 4,
//                 decoration: const InputDecoration(
//                   labelText: "Describe your problem",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator:
//                     (value) =>
//                         value!.isEmpty ? "Please describe the problem" : null,
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   _submitBooking;
//                 },
//
//                 child: const Text("Book Now"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }









class BookNowScreen extends StatefulWidget {
  final ServiceProviderDisplay provider;

  const BookNowScreen({Key? key, required this.provider}) : super(key: key);

  @override
  _BookNowScreenState createState() => _BookNowScreenState();
}

class _BookNowScreenState extends State<BookNowScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _problemController = TextEditingController();

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<String?> getProviderToken(String providerId) async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref()
          .child("providers")
          .child(providerId)
          .child("token")
          .get();

      if (snapshot.exists) {
        return snapshot.value as String;
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching provider token: $e");
      return null;
    }
  }

  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      EasyLoading.show(status: 'Booking...');

      final appointmentTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userLocation =
      Provider.of<ServiceDataProvider>(context, listen: false).userLocation!;

      final appointment = {
        'userId': userId,
        'providerId': widget.provider.id,
        'providerName': widget.provider.name,
        'serviceId': widget.provider.serviceId,
        'serviceName': widget.provider.serviceName,
        'appointmentTime': appointmentTime.millisecondsSinceEpoch,
        'problemDescription': _problemController.text,
        'location': userLocation.toMap(),
        'isConfirmed': false,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'price': widget.provider.hourlyRate,
        'duration': 1,
      };

      try {
        final ref = FirebaseDatabase.instance.ref().child('appointments').push();
        final appointmentId = ref.key!;

        await ref.set({...appointment, 'appointmentId': appointmentId});

        // Get provider token and send notification
        final providerToken = await getProviderToken(widget.provider.id);
        if (providerToken != null) {
          await SendNotificationService.sendNotificationUsingApi(
            token: providerToken,
            title: "New Booking Request",
            body: "You have a new booking request from ${FirebaseAuth.instance.currentUser!.displayName ?? 'a customer'}",
            data: {
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "appointmentId": appointmentId,
              "type": "new_booking",
            },
          );
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request sent! Waiting for provider confirmation'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: ${e.toString()}')),
        );
      } finally {
        await EasyLoading.dismiss();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? "Select Date"
                      : "${_selectedDate!.toLocal()}".split(' ')[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                title: Text(
                  _selectedTime == null
                      ? "Select Time"
                      : _selectedTime!.format(context),
                ),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
              ),
              TextFormField(
                controller: _problemController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Describe your problem",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? "Please describe the problem" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitBooking, // Fixed: removed the semicolon
                child: const Text("Book Now"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// User Home Screen
class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final List<String> carouselImages = const [
    'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80',
    'https://images.unsplash.com/photo-1540518614846-7eded433c457?ixlib=rb-4.0.3&auto=format&fit=crop&w=1457&q=80',
    'https://images.unsplash.com/photo-1484154218962-a197022b5858?ixlib=rb-4.0.3&auto=format&fit=crop&w=1474&q=80',
  ];

  late TextEditingController _searchController;
  late List<Service> _filteredServices;
  late ServiceDataProvider _serviceProvider;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredServices = [];
    _serviceProvider = Provider.of<ServiceDataProvider>(context, listen: false);
    _serviceProvider.loadProviders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_filteredServices.isEmpty) {
      _filteredServices = _serviceProvider.services;
    }
  }

  Future<void> _checkLocation() async {
    final location =
        await Navigator.pushNamed(context, LocationScreen.routeName)
            as LocationModel?;

    if (location != null) {
      Provider.of<ServiceDataProvider>(
        context,
        listen: false,
      ).setUserLocation(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Update AppBar colors to match the new theme
        backgroundColor: const Color(0xFF5D69BE),
        title: const Text(
          'SewaMitra',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange, // Changed to white
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            // White icon
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
        iconTheme: const IconThemeData(
          color: Colors.white, // White drawer icon
        ),
      ),
      drawer: Drawer(
        width: 250,
        backgroundColor: const Color(0xFF5D69BE),
        // Updated to match gradient start
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 160,
              decoration: const BoxDecoration(
                color: Color(0x445D69BE), // Semi-transparent version
              ),
              child: const Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.black),
              title: const Text(
                'Home',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black),
              title: const Text(
                'Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.black),
              title: const Text(
                'Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserNotificationsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5D69BE), Color(0xFFC89FEB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Carousel Slider
            CarouselSlider(
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                viewportFraction: 0.8,
                enlargeCenterPage: true,
              ),
              items:
                  carouselImages.map((url) {
                    return Container(
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          width: 1000,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.error, size: 50),
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 20),

            // Services Header with Search Box
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.black87),

                      // Dark text
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(fontSize: 14),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filteredServices = _serviceProvider.searchServices(
                            value,
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Services Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: _filteredServices.length,
                itemBuilder: (context, index) {
                  return ServiceCard(service: _filteredServices[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final Service service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final location =
              Provider.of<ServiceDataProvider>(
                context,
                listen: false,
              ).userLocation;

          if (location == null) {
            final newLocation =
                await Navigator.pushNamed(context, LocationScreen.routeName)
                    as LocationModel?;

            if (newLocation != null) {
              Navigator.pushNamed(
                context,
                ServiceProvidersScreen.routeName,
                arguments: service.id,
              );
            }
          } else {
            Navigator.pushNamed(
              context,
              ServiceProvidersScreen.routeName,
              arguments: service.id,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                service.imageUrl,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.error_outline, size: 40),
              ),
              const SizedBox(height: 12),
              Text(
                service.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
