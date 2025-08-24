// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:provider/provider.dart';
// import 'package:sewamitra/user/cart.dart';
// import 'package:sewamitra/user/profile.dart';
// import 'package:sewamitra/user/user_notifications_screen.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../services/send_notification_service.dart';
//
// // Service Model
// class Service {
//   final String id;
//   final String name;
//   final String imageAssets;
//
//   Service({required this.id, required this.name, required this.imageAssets});
// }
//
// // Location Model
// class LocationModel {
//   final String address;
//   final double latitude;
//   final double longitude;
//
//   LocationModel({
//     required this.address,
//     required this.latitude,
//     required this.longitude,
//   });
//
//   factory LocationModel.fromMap(Map<dynamic, dynamic> map) {
//     return LocationModel(
//       address: map['address'] ?? '',
//       latitude: map['latitude']?.toDouble() ?? 0.0,
//       longitude: map['longitude']?.toDouble() ?? 0.0,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {'address': address, 'latitude': latitude, 'longitude': longitude};
//   }
// }
//
// // Service Offering Model
// class ServiceOffering {
//   final int experience;
//   final double hourlyCharge;
//   final String idProof;
//   final LocationModel location;
//   final String providerId;
//   final int registrationDate;
//   final String serviceId;
//   final String serviceName;
//   final String status;
//   final String relatedWorkImage;
//   final String priceType;
//   final String serviceType;
//
//   final String? priceDescription;
//
//   ServiceOffering({
//     required this.experience,
//     required this.hourlyCharge,
//     required this.idProof,
//     required this.location,
//     required this.providerId,
//     required this.registrationDate,
//     required this.serviceId,
//     required this.serviceName,
//     required this.status,
//     required this.relatedWorkImage,
//     required this.priceType,
//     required this.serviceType,
//     this.priceDescription,
//   });
//
//   factory ServiceOffering.fromMap(Map<dynamic, dynamic> map) {
//     return ServiceOffering(
//       experience: map['experience'] ?? 0,
//       hourlyCharge: map['hourly_charge']?.toDouble() ?? 0.0,
//       idProof: map['id_proof'] ?? '',
//       location: LocationModel.fromMap(
//         Map<String, dynamic>.from(map['location']),
//       ),
//       providerId: map['provider_id'] ?? '',
//       registrationDate: map['registration_date'] ?? 0,
//       serviceId: map['service_id'] ?? '',
//       serviceName: map['service_name'] ?? '',
//       status: map['status'] ?? 'pending',
//       relatedWorkImage: map['related_work_image'] ?? '',
//       priceType: map['price_type'] ?? 'Per Hour',
//       serviceType: map['service_type'] ?? '',
//       priceDescription: map['price_description'],
//     );
//   }
// }
//
// // Provider Model
// class ProviderModel {
//   final int createdAt;
//   final String email;
//   final String name;
//   final String phone;
//   final String role;
//   final String? profileImage;
//   final double averageRating;
//   final int ratingCount;
//   final Map<String, ServiceOffering> services;
//   final String uid;
//
//   ProviderModel({
//     required this.createdAt,
//     required this.email,
//     required this.name,
//     required this.phone,
//     required this.role,
//     this.profileImage,
//     required this.services,
//     required this.uid,
//     required this.averageRating,
//     required this.ratingCount,
//   });
//
//   factory ProviderModel.fromMap(Map<dynamic, dynamic> map) {
//     return ProviderModel(
//       createdAt: map['createdAt'] ?? 0,
//       email: map['email'] ?? '',
//       name: map['name'] ?? '',
//       phone: map['phone'] ?? '',
//       profileImage: map['profileImage'],
//       role: map['role'] ?? '',
//       services:
//           (map['services'] as Map<dynamic, dynamic>?)?.map((key, value) {
//             return MapEntry(
//               key.toString(),
//               ServiceOffering.fromMap(Map<String, dynamic>.from(value)),
//             );
//           }) ??
//           {},
//       uid: map['uid'] ?? '',
//       averageRating: map['averageRating']?.toDouble() ?? 0.0,
//       ratingCount: map['ratingCount'] ?? 0,
//     );
//   }
// }
//
// // Service Provider Display Model
// class ServiceProviderDisplay {
//   final String id;
//   final String name;
//   final String email;
//   final String phone;
//   final String? profileImage;
//   final String serviceId;
//   final String serviceName;
//   final int experience;
//   final double hourlyRate;
//   final LocationModel location;
//   final double distance;
//   final double averageRating;
//   final int ratingCount;
//   final String relatedWorkImage;
//   final String priceType;
//   final String serviceType;
//   final String? priceDescription;
//
//   ServiceProviderDisplay({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.phone,
//     this.profileImage,
//     required this.serviceId,
//     required this.serviceName,
//     required this.experience,
//     required this.hourlyRate,
//     required this.location,
//     required this.distance,
//     required this.averageRating,
//     required this.ratingCount,
//     required this.relatedWorkImage,
//     required this.priceType,
//     required this.serviceType,
//     this.priceDescription,
//   });
// }
//
// // Service Data Provider (ChangeNotifier)
// class ServiceDataProvider with ChangeNotifier {
//   List<Service> _services = [
//     Service(
//       id: '1',
//       name: 'Technology And Digital Services ',
//       imageAssets: 'assets/images/telecommunication.png',
//     ),
//     Service(
//       id: '2',
//       name: 'House Related Services',
//       imageAssets: 'assets/images/house.png',
//     ),
//     Service(
//       id: '3',
//       name: 'Health Care',
//       imageAssets: 'assets/images/medical.png',
//     ),
//     Service(
//       id: '4',
//       name: 'Motor Vehicle',
//       imageAssets: 'assets/images/traffic.png',
//     ),
//     Service(
//       id: '5',
//       name: 'Skill And Training',
//       imageAssets: 'assets/images/training.png',
//     ),
//     Service(
//       id: '6',
//       name: 'Beautification',
//       imageAssets: 'assets/images/makeup.png',
//     ),
//     Service(id: '7', name: 'Pet Care', imageAssets: 'assets/images/pet.png'),
//     Service(
//       id: '8',
//       name: 'Education',
//       imageAssets: 'assets/images/education.png',
//     ),
//   ];
//
//   List<ProviderModel> _providers = [];
//   LocationModel? _userLocation;
//
//   List<Service> get services => _services;
//
//   LocationModel? get userLocation => _userLocation;
//
//   Future<void> loadProviders() async {
//     final ref = FirebaseDatabase.instance.ref();
//     final snapshot = await ref.get();
//
//     if (snapshot.exists) {
//       final data = snapshot.value as Map<dynamic, dynamic>;
//       final providersData = data['providers'] as Map<dynamic, dynamic>? ?? {};
//
//       _providers =
//           providersData.values.map((p) {
//             return ProviderModel.fromMap(Map<dynamic, dynamic>.from(p));
//           }).toList();
//
//       notifyListeners();
//     }
//   }
//
//   void setUserLocation(LocationModel location) {
//     _userLocation = location;
//     notifyListeners();
//   }
//
//   // Search method
//   List<Service> searchServices(String query) {
//     if (query.isEmpty) return _services;
//
//     return _services.where((service) {
//       return service.name.toLowerCase().contains(query.toLowerCase());
//     }).toList();
//   }
//
//   // Get providers for a specific service within 20 km range
//   List<ServiceProviderDisplay> getProvidersForService(String serviceId) {
//     if (_userLocation == null) return [];
//
//     final providers = <ServiceProviderDisplay>[];
//
//     for (final provider in _providers) {
//       for (final serviceEntry in provider.services.entries) {
//         final service = serviceEntry.value;
//         if (service.serviceId == serviceId && service.status == 'approved') {
//           // Calculate distance using geolocator
//           double distance =
//               Geolocator.distanceBetween(
//                 _userLocation!.latitude,
//                 _userLocation!.longitude,
//                 service.location.latitude,
//                 service.location.longitude,
//               ) /
//               1000; // Convert to kilometers
//
//           // Only include providers within 20 km
//           if (distance <= 20.0) {
//             providers.add(
//               ServiceProviderDisplay(
//                 id: provider.uid,
//                 name: provider.name,
//                 email: provider.email,
//                 phone: provider.phone,
//                 profileImage: provider.profileImage,
//                 averageRating: provider.averageRating,
//                 ratingCount: provider.ratingCount,
//                 serviceId: service.serviceId,
//                 serviceName: service.serviceName,
//                 experience: service.experience,
//                 hourlyRate: service.hourlyCharge,
//                 location: service.location,
//                 distance: distance,
//                 relatedWorkImage: service.relatedWorkImage,
//                 priceType: service.priceType,
//                 serviceType: service.serviceType,
//                 priceDescription: service.priceDescription,
//               ),
//             );
//           }
//         }
//       }
//     }
//
//     // Sort by distance
//     providers.sort((a, b) => a.distance.compareTo(b.distance));
//
//     return providers;
//   }
//
//   // Get all services from providers within 20 km range
//   List<ProviderServiceCard> getAllServicesWithin20Km() {
//     if (_userLocation == null) return [];
//
//     final services = <ProviderServiceCard>[];
//
//     for (final provider in _providers) {
//       for (final serviceEntry in provider.services.entries) {
//         final service = serviceEntry.value;
//         if (service.status == 'approved') {
//           // Calculate distance using geolocator
//           double distance =
//               Geolocator.distanceBetween(
//                 _userLocation!.latitude,
//                 _userLocation!.longitude,
//                 service.location.latitude,
//                 service.location.longitude,
//               ) /
//               1000; // Convert to kilometers
//
//           // Only include providers within 20 km
//           if (distance <= 20.0) {
//             services.add(
//               ProviderServiceCard(
//                 serviceName: service.serviceName,
//                 providerName: provider.name,
//                 hourlyCharge: service.hourlyCharge,
//                 rating: provider.averageRating,
//                 ratingCount: provider.ratingCount,
//                 imageBase64: service.relatedWorkImage,
//                 serviceId: service.serviceId,
//                 serviceType: service.serviceType,
//               ),
//             );
//           }
//         }
//       }
//     }
//
//     return services;
//   }
// }
//
// // ProviderServiceCard Model
// class ProviderServiceCard {
//   final String serviceName;
//   final String providerName;
//   final double hourlyCharge;
//   final double rating;
//   final int ratingCount;
//   final String? imageBase64;
//   final String serviceId;
//   final String serviceType;
//
//   ProviderServiceCard({
//     required this.serviceName,
//     required this.providerName,
//     required this.hourlyCharge,
//     required this.rating,
//     required this.ratingCount,
//     this.imageBase64,
//     required this.serviceId,
//     required this.serviceType,
//   });
// }
//
// // Your LocationModel and ServiceDataProvider classes here...
//
// class LocationScreen extends StatefulWidget {
//   static const routeName = '/location';
//
//   @override
//   _LocationScreenState createState() => _LocationScreenState();
// }
//
// class _LocationScreenState extends State<LocationScreen>
//     with SingleTickerProviderStateMixin {
//   LocationModel? _selectedLocation;
//   bool _isLoading = false;
//
//   late final AnimationController _animationController;
//   late final Animation<double> _fadeAnimation;
//   late final Animation<Offset> _slideAnimation;
//   final MapController _mapController = MapController();
//
//   @override
//   void initState() {
//     super.initState();
//
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.5),
//       end: const Offset(0, 0),
//     ).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       // Request location permissions
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           setState(() {
//             _isLoading = false;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Location permissions are denied'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text(
//               'Location permissions are permanently denied, enable them in app settings',
//             ),
//             backgroundColor: Colors.red,
//             action: SnackBarAction(
//               label: 'Open Settings',
//               onPressed: () => Geolocator.openAppSettings(),
//             ),
//           ),
//         );
//         return;
//       }
//
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       await Future.delayed(const Duration(milliseconds: 800));
//
//       final newLocation = LocationModel(
//         address: "Current Location",
//         latitude: position.latitude,
//         longitude: position.longitude,
//       );
//
//       setState(() {
//         _selectedLocation = newLocation;
//         _isLoading = false;
//       });
//
//       _animationController.forward();
//
//       // ✅ Move map only after FlutterMap has rendered
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted && _selectedLocation != null) {
//           _mapController.move(
//             LatLng(newLocation.latitude, newLocation.longitude),
//             15.0,
//           );
//         }
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Could not get location: $e'),
//             backgroundColor: Colors.red,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//   }
//
//   void _saveLocation() {
//     if (_selectedLocation != null) {
//       final userId = FirebaseAuth.instance.currentUser?.uid;
//       if (userId != null) {
//         FirebaseDatabase.instance.ref().child('users').child(userId).update({
//           'location': _selectedLocation!.toMap(),
//         });
//       }
//
//       Provider.of<ServiceDataProvider>(
//         context,
//         listen: false,
//       ).setUserLocation(_selectedLocation!);
//
//       Navigator.pop(context, _selectedLocation);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select a location first'),
//           backgroundColor: Colors.orange,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text(
//           'Set Your Location',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w700,
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Tap the location icon to detect your current location',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 6,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         Icon(
//                           Icons.location_searching,
//                           size: 32,
//                           color: Colors.blue[700],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Get My Location',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'We\'ll use your current location to provide better service',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         SizedBox(
//                           width: 200,
//                           child: ElevatedButton.icon(
//                             onPressed: _getCurrentLocation,
//                             icon: const Icon(Icons.my_location, size: 20),
//                             label:
//                                 _isLoading
//                                     ? const SizedBox(
//                                       width: 20,
//                                       height: 20,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         valueColor:
//                                             AlwaysStoppedAnimation<Color>(
//                                               Colors.white,
//                                             ),
//                                       ),
//                                     )
//                                     : const Text('Detect Location'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue[700],
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 16,
//                                 horizontal: 20,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 0,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   // _buildMapPreview(),
//                   if (_selectedLocation != null) ...[
//                     FadeTransition(
//                       opacity: _fadeAnimation,
//                       child: SlideTransition(
//                         position: _slideAnimation,
//                         child: Container(
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.check_circle,
//                                 color: Colors.green,
//                                 size: 24,
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text(
//                                       'Location Detected',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
//                                       style: TextStyle(
//                                         color: Colors.grey[600],
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 60),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 16,
//                     ),
//
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 10,
//                           offset: const Offset(0, -5),
//                         ),
//                       ],
//                     ),
//                     child: SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _saveLocation,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor:
//                               _selectedLocation != null
//                                   ? Colors.blue[700]
//                                   : Colors.grey[400],
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 0,
//                         ),
//                         child: const Text(
//                           'Save Location',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Service Providers Screen
// class ServiceProvidersScreen extends StatelessWidget {
//   static const routeName = '/service_providers';
//
//   const ServiceProvidersScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final serviceId = ModalRoute.of(context)!.settings.arguments as String;
//     final serviceProviders = Provider.of<ServiceDataProvider>(
//       context,
//     ).getProvidersForService(serviceId);
//
//     final service = Provider.of<ServiceDataProvider>(
//       context,
//     ).services.firstWhere((s) => s.id == serviceId);
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           '${service.name} Providers',
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
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body:
//           serviceProviders.isEmpty
//               ? const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.location_off, size: 50, color: Colors.grey),
//                     SizedBox(height: 16),
//                     Text(
//                       'No nearby providers found',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Try again later or search in a different location',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 16, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               )
//               : ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: serviceProviders.length,
//                 itemBuilder: (context, index) {
//                   final provider = serviceProviders[index];
//                   return ServiceProviderCard(provider: provider);
//                 },
//               ),
//     );
//   }
// }
//
// class ServiceProviderCard extends StatelessWidget {
//   final ServiceProviderDisplay provider;
//
//   const ServiceProviderCard({super.key, required this.provider});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ProviderDetailScreen(provider: provider),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Service Image (Related Work Image)
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child:
//                     provider.relatedWorkImage.isNotEmpty
//                         ? ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: Image.memory(
//                             base64Decode(provider.relatedWorkImage),
//                             fit: BoxFit.cover,
//                             errorBuilder:
//                                 (context, error, stackTrace) => const Icon(
//                                   Icons.image_not_supported,
//                                   size: 40,
//                                 ),
//                           ),
//                         )
//                         : const Icon(Icons.work, size: 40, color: Colors.grey),
//               ),
//               const SizedBox(width: 16),
//
//               // Provider Details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           provider.name,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const Spacer(),
//                         RatingBarIndicator(
//                           rating: provider.averageRating,
//                           itemBuilder:
//                               (context, index) =>
//                                   const Icon(Icons.star, color: Colors.amber),
//                           itemCount: 5,
//                           itemSize: 16,
//                           direction: Axis.horizontal,
//                         ),
//                         Text(
//                           provider.averageRating.toStringAsFixed(1),
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           ' (${provider.ratingCount})',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                     // Service Name
//                     Text(
//                       provider.serviceName,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[700],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     // Experience
//                     Row(
//                       children: [
//                         const Icon(Icons.work, size: 16, color: Colors.blue),
//                         const SizedBox(width: 4),
//                         Text(
//                           '${provider.experience} yrs exp',
//                           style: TextStyle(color: Colors.grey[600]),
//                         ),
//                         const Spacer(),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     // Distance and Rate
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.location_on,
//                           size: 16,
//                           color: Colors.blue,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           '${provider.distance.toStringAsFixed(1)} km away',
//                           style: TextStyle(color: Colors.grey[600]),
//                         ),
//                         const Spacer(),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.attach_money,
//                           size: 16,
//                           color: Colors.green,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           'Rs.${provider.hourlyRate}/${provider.priceType}',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     // Book Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder:
//                                   (context) =>
//                                       BookNowScreen(provider: provider),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         child: const Text(
//                           'Book Now',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Provider Detail Screen
// class ProviderDetailScreen extends StatelessWidget {
//   final ServiceProviderDisplay provider;
//
//   const ProviderDetailScreen({super.key, required this.provider});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           provider.name,
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
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Profile Image and Service Image side by side
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Profile Image
//                 Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     shape: BoxShape.circle,
//                   ),
//                   child:
//                       provider.profileImage != null &&
//                               provider.profileImage!.isNotEmpty
//                           ? ClipRRect(
//                             borderRadius: BorderRadius.circular(60),
//                             child: Image.memory(
//                               base64Decode(provider.profileImage!),
//                               fit: BoxFit.cover,
//                               errorBuilder:
//                                   (context, error, stackTrace) =>
//                                       const Icon(Icons.person, size: 40),
//                             ),
//                           )
//                           : const Icon(Icons.person, size: 40),
//                 ),
//                 const SizedBox(width: 20),
//
//                 // Service Image (Related Work Image)
//                 Expanded(
//                   child: Container(
//                     height: 120,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child:
//                         provider.relatedWorkImage.isNotEmpty
//                             ? ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Image.memory(
//                                 base64Decode(provider.relatedWorkImage),
//                                 fit: BoxFit.cover,
//                                 errorBuilder:
//                                     (context, error, stackTrace) =>
//                                         const Icon(Icons.work, size: 40),
//                               ),
//                             )
//                             : const Icon(
//                               Icons.work,
//                               size: 40,
//                               color: Colors.grey,
//                             ),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 20),
//
//             // Rating
//             Row(
//               children: [
//                 RatingBarIndicator(
//                   rating: provider.averageRating,
//                   itemBuilder:
//                       (context, index) =>
//                           const Icon(Icons.star, color: Colors.amber),
//                   itemCount: 5,
//                   itemSize: 20,
//                   direction: Axis.horizontal,
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   '${provider.averageRating.toStringAsFixed(1)} (${provider.ratingCount} reviews)',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 20),
//
//             // Service Info
//             _buildDetailRow('Service', provider.serviceName),
//             _buildDetailRow('Experience', '${provider.experience} years'),
//             _buildDetailRow(
//               'Pricing',
//               '${provider.priceType} - Rs.${provider.hourlyRate}/hr',
//             ),
//             if (provider.priceDescription != null &&
//                 provider.priceDescription!.isNotEmpty)
//               _buildDetailRow('Price Details', provider.priceDescription!),
//             _buildDetailRow('Phone', provider.phone),
//             _buildDetailRow('Address', provider.location.address),
//             _buildDetailRow(
//               'Distance',
//               '${provider.distance.toStringAsFixed(1)} km',
//             ),
//             const SizedBox(height: 40),
//
//             // Book Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => BookNowScreen(provider: provider),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   backgroundColor: Colors.blue,
//                 ),
//                 child: const Text(
//                   'Book Appointment',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               '$title:',
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//           ),
//           Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
//         ],
//       ),
//     );
//   }
// }
//
// Future<String?> getProviderToken(String providerId) async {
//   try {
//     final snapshot =
//         await FirebaseDatabase.instance
//             .ref()
//             .child("providers")
//             .child(providerId)
//             .child("token")
//             .get();
//
//     if (snapshot.exists) {
//       return snapshot.value as String;
//     }
//     return null;
//   } catch (e) {
//     debugPrint("Error fetching provider token: $e");
//     return null;
//   }
// }
//
// // Booking Screen
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
//         // Get provider token and send notification
//         final providerToken = await getProviderToken(widget.provider.id);
//         if (providerToken != null) {
//           await SendNotificationService.sendNotificationUsingApi(
//             token: providerToken,
//             title: "New Booking Request",
//             body: "You have a new booking request",
//             data: {
//               "click_action": "FLUTTER_NOTIFICATION_CLICK",
//               "appointmentId": appointmentId,
//             },
//           );
//           await EasyLoading.dismiss();
//         }
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
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Booking failed: ${e.toString()}')),
//         );
//       } finally {
//         EasyLoading.dismiss();
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(title: const Text("Book Appointment")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               Card(
//                 child: ListTile(
//                   leading: const Icon(Icons.calendar_today),
//                   title: Text(
//                     _selectedDate == null
//                         ? "Select Date"
//                         : DateFormat('EEE, MMM d, y').format(_selectedDate!),
//                   ),
//                   trailing: const Icon(Icons.arrow_drop_down),
//                   onTap: _pickDate,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Card(
//                 child: ListTile(
//                   leading: const Icon(Icons.access_time),
//                   title: Text(
//                     _selectedTime == null
//                         ? "Select Time"
//                         : _selectedTime!.format(context),
//                   ),
//                   trailing: const Icon(Icons.arrow_drop_down),
//                   onTap: _pickTime,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _problemController,
//                 maxLines: 4,
//                 decoration: const InputDecoration(
//                   labelText: "Describe your problem",
//                   border: OutlineInputBorder(),
//                   alignLabelWithHint: true,
//                 ),
//                 validator:
//                     (value) =>
//                         value!.isEmpty ? "Please describe the problem" : null,
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _submitBooking,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: const Text(
//                   "Book Now",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
// // .........................User Home Screen
//
//
//
//
//
//
// class UserHomeScreen extends StatefulWidget {
//   const UserHomeScreen({super.key});
//
//   @override
//   State<UserHomeScreen> createState() => _UserHomeScreenState();
// }
//
// class _UserHomeScreenState extends State<UserHomeScreen> {
//   final List<String> carouselImages = const [
//     'assets/images/banner1.png',
//     'assets/images/banner2.png',
//     'assets/images/banner3.png',
//   ];
//
//   TextEditingController _searchController = TextEditingController();
//   List<Service> _filteredServices = [];
//   ServiceDataProvider? _serviceProvider;
//
//   int _currentIndex = 0;
//   String? userName;
//
//   String get _greeting {
//     final hour = DateTime.now().hour;
//     if (hour < 12) return 'Good Morning';
//     if (hour < 17) return 'Good Afternoon';
//     return 'Good Evening';
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserName();
//     _serviceProvider = Provider.of<ServiceDataProvider>(context, listen: false);
//     _serviceProvider!.loadProviders();
//     _filteredServices = _serviceProvider!.services;
//   }
//
//   void _loadUserName() async {
//     String? name = await fetchUserName();
//     setState(() {
//       userName = name;
//     });
//   }
//
//   Future<String?> fetchUserName() async {
//     try {
//       final uid = FirebaseAuth.instance.currentUser?.uid;
//       if (uid == null) return null;
//
//       DatabaseReference ref = FirebaseDatabase.instance.ref("users/$uid");
//       DatabaseEvent event = await ref.once();
//
//       if (event.snapshot.exists) {
//         final data = event.snapshot.value as Map<dynamic, dynamic>;
//         return data["name"];
//       }
//       return null;
//     } catch (e) {
//       print("Error fetching user name: $e");
//       return null;
//     }
//   }
//
//   Future<void> _refreshData() async {
//     // Reload providers
//     await _serviceProvider!.loadProviders();
//
//     // Update filtered services
//     setState(() {
//       _filteredServices = _serviceProvider!.searchServices(_searchController.text);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screens = [
//       _buildHomeScreen(),
//       _buildSearchScreen(),
//       const BookingsScreen(),
//       ProfileScreen(userId: FirebaseAuth.instance.currentUser!.uid),
//     ];
//
//     return Scaffold(
//       backgroundColor: Colors.white, // Ensure scaffold has white background
//       appBar:
//       _currentIndex == 0
//           ? AppBar(
//         backgroundColor: Colors.orange[400],
//         title: const Text(
//           'SewaMitra',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications, color: Colors.white),
//             onPressed:
//                 () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const UserNotificationsScreen(),
//               ),
//             ),
//           ),
//         ],
//       )
//           : null,
//       body: IndexedStack(index: _currentIndex, children: screens),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _currentIndex,
//         selectedItemColor: Colors.deepOrange,
//         backgroundColor: Colors.white,
//         unselectedItemColor: Colors.grey,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_cart),
//             label: 'Cart',
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     );
//   }
//
//
//
//
//   Widget _buildHomeScreen() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Color(0xFFFFA726), // Orange 400
//             Color(0xFFFFB74D), // Orange 300
//             Colors.white,
//             Colors.white,
//           ],
//           stops: [0.0, 0.8, 1.0, 1.0], // Adjusted to prevent blue area
//         ),
//       ),
//       child: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: _refreshData,
//           color: Colors.orange,
//           backgroundColor: Colors.white,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.only(bottom: 80),
//             physics: const AlwaysScrollableScrollPhysics(),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildGreetingCard(),
//
//                 // Carousel
//                 CarouselSlider(
//                   options: CarouselOptions(
//                     height: 180,
//                     autoPlay: true,
//                     viewportFraction: 0.8,
//                     enlargeCenterPage: true,
//                   ),
//                   items:
//                   carouselImages.map((url) {
//                     return Container(
//                       margin: const EdgeInsets.all(5),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.5),
//                             blurRadius: 8,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.asset(
//                           url,
//                           fit: BoxFit.cover,
//                           width: 1000,
//                           errorBuilder:
//                               (context, error, stackTrace) =>
//                           const Icon(Icons.error, size: 50),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//                 const SizedBox(height: 10),
//
//                 // Services header + search
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Services',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       Container(
//                         width: 200,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.3),
//                               blurRadius: 6,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child: TextField(
//                           controller: _searchController,
//                           style: const TextStyle(color: Colors.black87),
//                           decoration: const InputDecoration(
//                             hintText: 'Search...',
//                             hintStyle: TextStyle(fontSize: 14),
//                             prefixIcon: Icon(
//                               Icons.search,
//                               color: Colors.grey,
//                               size: 20,
//                             ),
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.symmetric(
//                               vertical: 8,
//                               horizontal: 12,
//                             ),
//                             isDense: true,
//                           ),
//                           onChanged: (value) {
//                             setState(() {
//                               _filteredServices =
//                                   _serviceProvider?.searchServices(value) ?? [];
//                             });
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 10),
//
//                 // Services Grid
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: GridView.builder(
//                     physics: const NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: _filteredServices.length,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       childAspectRatio: 0.8,
//                       crossAxisSpacing: 12,
//                       mainAxisSpacing: 12,
//                     ),
//                     itemBuilder: (context, index) {
//                       return ServiceCard(service: _filteredServices[index]);
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // Provider Services Section - Updated to use 20km range
//                 Consumer<ServiceDataProvider>(
//                   builder: (context, serviceProvider, child) {
//                     final servicesWithin20Km =
//                     serviceProvider.getAllServicesWithin20Km();
//
//                     if (servicesWithin20Km.isEmpty) {
//                       return const SizedBox(); // Return empty if no services
//                     }
//
//                     return Container(
//                       child: Column(
//                         children: [
//                           const Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 16.0),
//                             child: Text(
//                               'Available Services Near You',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             child: Column(
//                               children:
//                               servicesWithin20Km
//                                   .map(
//                                     (service) =>
//                                     _buildProviderServiceCard(service),
//                               )
//                                   .toList(),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSearchScreen() {
//     return Container(color: Colors.white); // Ensure white background
//   }
//
//   Widget _buildProviderServiceCard(ProviderServiceCard service) {
//     return Card(
//       elevation: 3,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(8),
//         leading: Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child:
//           service.imageBase64 != null && service.imageBase64!.isNotEmpty
//               ? ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.memory(
//               base64Decode(service.imageBase64!),
//               fit: BoxFit.cover,
//               errorBuilder:
//                   (context, error, stackTrace) =>
//               const Icon(Icons.image_not_supported, size: 30),
//             ),
//           )
//               : const Icon(Icons.work, size: 30, color: Colors.grey),
//         ),
//         title: Text(
//           service.serviceType,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("By ${service.providerName}"),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 const Icon(Icons.star, color: Colors.amber, size: 16),
//                 const SizedBox(width: 4),
//                 Text(service.rating.toStringAsFixed(1)),
//                 Text(
//                   " (${service.ratingCount})",
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         trailing: Text(
//           "Rs. ${service.hourlyCharge.toStringAsFixed(0)}",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.orange[700],
//             fontSize: 16,
//           ),
//         ),
//         onTap: () {
//           // Navigate to service providers screen for this service
//           Navigator.pushNamed(
//             context,
//             ServiceProvidersScreen.routeName,
//             arguments: service.serviceId,
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildGreetingCard() {
//     return Container(
//       margin: const EdgeInsets.all(12),
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//         gradient: LinearGradient(
//           colors: [Colors.orange[900]!, Colors.orange[800]!],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _greeting,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Text(
//                   userName != null ? "Welcomes, $userName 👋" : "Loading...",
//                   style: const TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const Text(
//                   'What service do you need today?',
//                   style: TextStyle(fontSize: 14, color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
//
//
//
// class ServiceCard extends StatelessWidget {
//   final Service service;
//
//   const ServiceCard({super.key, required this.service});
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 90,
//       height: 110,
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(12),
//           onTap: () async {
//             final location =
//                 Provider.of<ServiceDataProvider>(
//                   context,
//                   listen: false,
//                 ).userLocation;
//
//             if (location == null) {
//               final newLocation =
//                   await Navigator.pushNamed(context, LocationScreen.routeName)
//                       as LocationModel?;
//
//               if (newLocation != null) {
//                 Navigator.pushNamed(
//                   context,
//                   ServiceProvidersScreen.routeName,
//                   arguments: service.id,
//                 );
//               }
//             } else {
//               Navigator.pushNamed(
//                 context,
//                 ServiceProvidersScreen.routeName,
//                 arguments: service.id,
//               );
//             }
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   service.imageAssets,
//                   height: 40,
//                   width: 40,
//                   fit: BoxFit.cover,
//                   errorBuilder:
//                       (context, error, stackTrace) =>
//                           const Icon(Icons.error_outline, size: 40),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   service.name,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ... (rest of the code remains the same)
















import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sewamitra/user/cart.dart';
import 'package:sewamitra/user/profile.dart';
import 'package:sewamitra/user/user_notifications_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/send_notification_service.dart';

// Service Model
class Service {
  final String id;
  final String name;
  final String imageAssets;

  Service({required this.id, required this.name, required this.imageAssets});
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
  final String relatedWorkImage;
  final String priceType;
  final String serviceType;

  final String? priceDescription;

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
    required this.relatedWorkImage,
    required this.priceType,
    required this.serviceType,
    this.priceDescription,
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
      relatedWorkImage: map['related_work_image'] ?? '',
      priceType: map['price_type'] ?? 'Per Hour',
      serviceType: map['service_type'] ?? '',
      priceDescription: map['price_description'],
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
  final int ratingCount;
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
    required this.ratingCount,
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
      ratingCount: map['ratingCount'] ?? 0,
    );
  }
}

// Service Provider Display Model
class ServiceProviderDisplay {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String serviceId;
  final String serviceName;
  final int experience;
  final double hourlyRate;
  final LocationModel location;
  final double distance;
  final double averageRating;
  final int ratingCount;
  final String relatedWorkImage;
  final String priceType;
  final String serviceType;
  final String? priceDescription;

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
    required this.ratingCount,
    required this.relatedWorkImage,
    required this.priceType,
    required this.serviceType,
    this.priceDescription,
  });
}

// Service Data Provider (ChangeNotifier)
class ServiceDataProvider with ChangeNotifier {
  List<Service> _services = [
    Service(
      id: '1',
      name: 'Technology And Digital Services ',
      imageAssets: 'assets/images/telecommunication.png',
    ),
    Service(
      id: '2',
      name: 'House Related Services',
      imageAssets: 'assets/images/house.png',
    ),
    Service(
      id: '3',
      name: 'Health Care',
      imageAssets: 'assets/images/medical.png',
    ),
    Service(
      id: '4',
      name: 'Motor Vehicle',
      imageAssets: 'assets/images/traffic.png',
    ),
    Service(
      id: '5',
      name: 'Skill And Training',
      imageAssets: 'assets/images/training.png',
    ),
    Service(
      id: '6',
      name: 'Beautification',
      imageAssets: 'assets/images/makeup.png',
    ),
    Service(id: '7', name: 'Pet Care', imageAssets: 'assets/images/pet.png'),
    Service(
      id: '8',
      name: 'Education',
      imageAssets: 'assets/images/education.png',
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
        if (service.serviceId == serviceId && service.status == 'approved') {
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
          if (distance <= 20.0) {
            providers.add(
              ServiceProviderDisplay(
                id: provider.uid,
                name: provider.name,
                email: provider.email,
                phone: provider.phone,
                profileImage: provider.profileImage,
                averageRating: provider.averageRating,
                ratingCount: provider.ratingCount,
                serviceId: service.serviceId,
                serviceName: service.serviceName,
                experience: service.experience,
                hourlyRate: service.hourlyCharge,
                location: service.location,
                distance: distance,
                relatedWorkImage: service.relatedWorkImage,
                priceType: service.priceType,
                serviceType: service.serviceType,
                priceDescription: service.priceDescription,
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

  // Get all services from providers within 20 km range
  List<ProviderServiceCard> getAllServicesWithin20Km() {
    if (_userLocation == null) return [];

    final services = <ProviderServiceCard>[];

    for (final provider in _providers) {
      for (final serviceEntry in provider.services.entries) {
        final service = serviceEntry.value;
        if (service.status == 'approved') {
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
          if (distance <= 20.0) {
            services.add(
              ProviderServiceCard(
                serviceName: service.serviceName,
                providerName: provider.name,
                hourlyCharge: service.hourlyCharge,
                rating: provider.averageRating,
                ratingCount: provider.ratingCount,
                imageBase64: service.relatedWorkImage,
                serviceId: service.serviceId,
                serviceType: service.serviceType,
              ),
            );
          }
        }
      }
    }

    return services;
  }

  // NEW: Get all providers with locations within 20 km
  List<ServiceProviderDisplay> getAllProvidersWithLocations() {
    if (_userLocation == null) return [];

    final providers = <ServiceProviderDisplay>[];
    final Set<String> addedProviderIds = {};

    for (final provider in _providers) {
      for (final serviceEntry in provider.services.entries) {
        final service = serviceEntry.value;
        if (service.status == 'approved') {
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
          if (distance <= 20.0 && !addedProviderIds.contains(provider.uid)) {
            addedProviderIds.add(provider.uid);
            providers.add(
              ServiceProviderDisplay(
                id: provider.uid,
                name: provider.name,
                email: provider.email,
                phone: provider.phone,
                profileImage: provider.profileImage,
                averageRating: provider.averageRating,
                ratingCount: provider.ratingCount,
                serviceId: service.serviceId,
                serviceName: service.serviceName,
                experience: service.experience,
                hourlyRate: service.hourlyCharge,
                location: service.location,
                distance: distance,
                relatedWorkImage: service.relatedWorkImage,
                priceType: service.priceType,
                serviceType: service.serviceType,
                priceDescription: service.priceDescription,
              ),
            );
            break; // Only add each provider once
          }
        }
      }
    }

    return providers;
  }
}

// ProviderServiceCard Model
class ProviderServiceCard {
  final String serviceName;
  final String providerName;
  final double hourlyCharge;
  final double rating;
  final int ratingCount;
  final String? imageBase64;
  final String serviceId;
  final String serviceType;

  ProviderServiceCard({
    required this.serviceName,
    required this.providerName,
    required this.hourlyCharge,
    required this.rating,
    required this.ratingCount,
    this.imageBase64,
    required this.serviceId,
    required this.serviceType,
  });
}

// Your LocationModel and ServiceDataProvider classes here...

class LocationScreen extends StatefulWidget {
  static const routeName = '/location';

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with SingleTickerProviderStateMixin {
  LocationModel? _selectedLocation;
  bool _isLoading = false;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are denied'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Location permissions are permanently denied, enable them in app settings',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Open Settings',
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await Future.delayed(const Duration(milliseconds: 800));

      final newLocation = LocationModel(
        address: "Current Location",
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _selectedLocation = newLocation;
        _isLoading = false;
      });

      _animationController.forward();

      // ✅ Move map only after FlutterMap has rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedLocation != null) {
          _mapController.move(
            LatLng(newLocation.latitude, newLocation.longitude),
            15.0,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not get location: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _saveLocation() {
    if (_selectedLocation != null) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        FirebaseDatabase.instance.ref().child('users').child(userId).update({
          'location': _selectedLocation!.toMap(),
        });
      }

      Provider.of<ServiceDataProvider>(
        context,
        listen: false,
      ).setUserLocation(_selectedLocation!);

      Navigator.pop(context, _selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location first'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Set Your Location',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tap the location icon to detect your current location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_searching,
                          size: 32,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Get My Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We\'ll use your current location to provide better service',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.my_location, size: 20),
                            label:
                            _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                                : const Text('Detect Location'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // _buildMapPreview(),
                  if (_selectedLocation != null) ...[
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Location Detected',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 60),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          _selectedLocation != null
                              ? Colors.blue[700]
                              : Colors.grey[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
      backgroundColor: Colors.white,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Service Image (Related Work Image)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                provider.relatedWorkImage.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    base64Decode(provider.relatedWorkImage),
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      size: 40,
                    ),
                  ),
                )
                    : const Icon(Icons.work, size: 40, color: Colors.grey),
              ),
              const SizedBox(width: 16),

              // Provider Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          provider.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                        Text(
                          provider.averageRating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' (${provider.ratingCount})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    // Service Name
                    Text(
                      provider.serviceName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                      ],
                    ),
                    const SizedBox(height: 4),
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
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Rs.${provider.hourlyRate}/${provider.priceType}',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image and Service Image side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                Container(
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
                      base64Decode(provider.profileImage!),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                      const Icon(Icons.person, size: 40),
                    ),
                  )
                      : const Icon(Icons.person, size: 40),
                ),
                const SizedBox(width: 20),

                // Service Image (Related Work Image)
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                    provider.relatedWorkImage.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(provider.relatedWorkImage),
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                        const Icon(Icons.work, size: 40),
                      ),
                    )
                        : const Icon(
                      Icons.work,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Rating
            Row(
              children: [
                RatingBarIndicator(
                  rating: provider.averageRating,
                  itemBuilder:
                      (context, index) =>
                  const Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 20,
                  direction: Axis.horizontal,
                ),
                const SizedBox(width: 10),
                Text(
                  '${provider.averageRating.toStringAsFixed(1)} (${provider.ratingCount} reviews)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Service Info
            _buildDetailRow('Service', provider.serviceName),
            _buildDetailRow('Experience', '${provider.experience} years'),
            _buildDetailRow(
              'Pricing',
              '${provider.priceType} - Rs.${provider.hourlyRate}/hr',
            ),
            if (provider.priceDescription != null &&
                provider.priceDescription!.isNotEmpty)
              _buildDetailRow('Price Details', provider.priceDescription!),
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

Future<String?> getProviderToken(String providerId) async {
  try {
    final snapshot =
    await FirebaseDatabase.instance
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

// Booking Screen
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
      Provider.of<ServiceDataProvider>(
        context,
        listen: false,
      ).userLocation!;

      // Create appointment data with isConfirmed: false
      final appointment = {
        'userId': userId,
        'providerId': widget.provider.id,
        'providerName': widget.provider.name,
        'serviceId': widget.provider.serviceId,
        'serviceName': widget.provider.serviceName,
        'appointmentTime': appointmentTime.millisecondsSinceEpoch,
        'problemDescription': _problemController.text,
        'location': userLocation.toMap(),
        'isConfirmed': false, // Initial status is false (unconfirmed)
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'price': widget.provider.hourlyRate,
        'duration': 1,
      };

      try {
        // Save to Firebase
        final ref =
        FirebaseDatabase.instance.ref().child('appointments').push();
        final appointmentId = ref.key!;

        await ref.set({...appointment, 'appointmentId': appointmentId});

        // Get provider token and send notification
        final providerToken = await getProviderToken(widget.provider.id);
        if (providerToken != null) {
          await SendNotificationService.sendNotificationUsingApi(
            token: providerToken,
            title: "New Booking Request",
            body: "You have a new booking request",
            data: {
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
            },
          );
          await EasyLoading.dismiss();
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Booking request sent! Waiting for provider confirmation',
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: ${e.toString()}')),
        );
      } finally {
        EasyLoading.dismiss();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Book Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    _selectedDate == null
                        ? "Select Date"
                        : DateFormat('EEE, MMM d, y').format(_selectedDate!),
                  ),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    _selectedTime == null
                        ? "Select Time"
                        : _selectedTime!.format(context),
                  ),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: _pickTime,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _problemController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Describe your problem",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator:
                    (value) =>
                value!.isEmpty ? "Please describe the problem" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitBooking,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Providers Map View
class ProvidersMapView extends StatefulWidget {
  final List<ServiceProviderDisplay> providers;

  const ProvidersMapView({Key? key, required this.providers}) : super(key: key);

  @override
  _ProvidersMapViewState createState() => _ProvidersMapViewState();
}

class _ProvidersMapViewState extends State<ProvidersMapView> {
  final MapController _mapController = MapController();
  late LatLng _center;

  @override
  void initState() {
    super.initState();
    // Set initial center to first provider's location or default location
    if (widget.providers.isNotEmpty) {
      final firstProvider = widget.providers.first;
      _center = LatLng(
        firstProvider.location.latitude,
        firstProvider.location.longitude,
      );
    } else {
      _center = const LatLng(27.6220633, 85.5387054); // Default location
    }
  }

  @override
  Widget build(BuildContext context) {
    final userLocation = Provider.of<ServiceDataProvider>(context).userLocation;
    final userLatLng = userLocation != null
        ? LatLng(userLocation.latitude, userLocation.longitude)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Providers Near You'),
        actions: [
          if (userLatLng != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                _mapController.move(userLatLng, 13.0);
              },
            ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _center,
          zoom: 13.0,
          interactiveFlags: InteractiveFlag.all, // Add this for interactivity

        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.sewamitra',
          ),
          MarkerLayer(
            markers: [
              // User location marker
              if (userLatLng != null)
                Marker(
                  point: userLatLng,
                  width: 40,
                  height: 40,
                  builder: (context) => const Icon(
                    Icons.person_pin_circle,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              // Provider markers
              ...widget.providers.map((provider) {
                final point = LatLng(
                  provider.location.latitude,
                  provider.location.longitude,
                );
                return Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  builder: (context) => const Icon(
                    Icons.location_pin,
                    color: Colors.orange,
                    size: 40,
                  ),
                );
              }).toList(),

            ],
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// .........................User Home Screen

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final List<String> carouselImages = const [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
  ];

  TextEditingController _searchController = TextEditingController();
  List<Service> _filteredServices = [];
  ServiceDataProvider? _serviceProvider;

  int _currentIndex = 0;
  String? userName;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _serviceProvider = Provider.of<ServiceDataProvider>(context, listen: false);
    _serviceProvider!.loadProviders();
    _filteredServices = _serviceProvider!.services;
  }

  void _loadUserName() async {
    String? name = await fetchUserName();
    setState(() {
      userName = name;
    });
  }

  Future<String?> fetchUserName() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;

      DatabaseReference ref = FirebaseDatabase.instance.ref("users/$uid");
      DatabaseEvent event = await ref.once();

      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        return data["name"];
      }
      return null;
    } catch (e) {
      print("Error fetching user name: $e");
      return null;
    }
  }

  Future<void> _refreshData() async {
    // Reload providers
    await _serviceProvider!.loadProviders();

    // Update filtered services
    setState(() {
      _filteredServices = _serviceProvider!.searchServices(_searchController.text);
    });
  }

  void _showProvidersMap() {
    final serviceProvider = Provider.of<ServiceDataProvider>(context, listen: false);
    final providers = serviceProvider.getAllProvidersWithLocations();

    if (providers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No providers found in your area'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: ProvidersMapView(providers: providers),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeScreen(),
      _buildSearchScreen(),
      const BookingsScreen(),
      ProfileScreen(userId: FirebaseAuth.instance.currentUser!.uid),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
      _currentIndex == 0
          ? AppBar(
        backgroundColor: Colors.orange[400],
        title: const Text(
          'SewaMitra',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed:
                () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UserNotificationsScreen(),
              ),
            ),
          ),
        ],
      )
          : null,
      body: IndexedStack(index: _currentIndex, children: screens),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        onPressed: _showProvidersMap,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.map, color: Colors.white),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepOrange,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFA726), // Orange 400
            Color(0xFFFFB74D), // Orange 300
            Colors.white,
            Colors.white,
          ],
          stops: [0.0, 0.8, 1.0, 1.0], // Adjusted to prevent blue area
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.orange,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingCard(),

                // Carousel
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
                        child: Image.asset(
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
                const SizedBox(height: 10),

                // Services header + search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                              _filteredServices =
                                  _serviceProvider?.searchServices(value) ?? [];
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Services Grid
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _filteredServices.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      return ServiceCard(service: _filteredServices[index]);
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Provider Services Section - Updated to use 20km range
                Consumer<ServiceDataProvider>(
                  builder: (context, serviceProvider, child) {
                    final servicesWithin20Km =
                    serviceProvider.getAllServicesWithin20Km();

                    if (servicesWithin20Km.isEmpty) {
                      return const SizedBox(); // Return empty if no services
                    }

                    return Container(
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Available Services Near You',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children:
                              servicesWithin20Km
                                  .map(
                                    (service) =>
                                    _buildProviderServiceCard(service),
                              )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchScreen() {
    return Container(color: Colors.white);
  }

  Widget _buildProviderServiceCard(ProviderServiceCard service) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child:
          service.imageBase64 != null && service.imageBase64!.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              base64Decode(service.imageBase64!),
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported, size: 30),
            ),
          )
              : const Icon(Icons.work, size: 30, color: Colors.grey),
        ),
        title: Text(
          service.serviceType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("By ${service.providerName}"),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(service.rating.toStringAsFixed(1)),
                Text(
                  " (${service.ratingCount})",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          "Rs. ${service.hourlyCharge.toStringAsFixed(0)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange[700],
            fontSize: 16,
          ),
        ),
        onTap: () {
          // Navigate to service providers screen for this service
          Navigator.pushNamed(
            context,
            ServiceProvidersScreen.routeName,
            arguments: service.serviceId,
          );
        },
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        gradient: LinearGradient(
          colors: [Colors.orange[900]!, Colors.orange[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  userName != null ? "Welcomes, $userName 👋" : "Loading...",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'What service do you need today?',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final Service service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 110,
      child: Card(
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
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  service.imageAssets,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                  const Icon(Icons.error_outline, size: 40),
                ),
                const SizedBox(height: 6),
                Text(
                  service.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}