import 'dart:convert';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sewamitra/mapSelectionScreen.dart';
import 'package:sewamitra/notificationService.dart';
import 'package:sewamitra/provider/contact_Admin.dart';
import 'package:sewamitra/provider/providerProfile.dart';
import 'package:sewamitra/provider/provider_notifications_screen.dart';
import 'package:sewamitra/user/userHomeScreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';

// class ProviderHomeScreen extends StatefulWidget {
//   const ProviderHomeScreen({super.key});
//
//   @override
//   State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
// }
//
// class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
//   final List<String> carouselImages = const [
//     'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1470&q=80',
//     'https://images.unsplash.com/photo-1540518614846-7eded433c457?auto=format&fit=crop&w=1457&q=80',
//     'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=1474&q=80',
//   ];
//
//
//   late TextEditingController _searchController;
//   late List<Service> _filteredServices;
//   late ServiceDataProvider _serviceProvider;
//
//   int _currentIndex = 0; // for bottom nav
//   String? providerUserName; // 👈 added username state
//
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController = TextEditingController();
//     _filteredServices = [];
//     _loadProviderUserName();
//
//   }
//   void _loadProviderUserName() async {
//     String? name = await fetchProviderUserName();
//     setState(() {
//       providerUserName = name;
//     });
//   }
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _serviceProvider = Provider.of<ServiceDataProvider>(context, listen: false);
//     if (_filteredServices.isEmpty) {
//       _filteredServices = _serviceProvider.services;
//     }
//   }
//
//   Future<String?> fetchProviderUserName() async {
//     try {
//       // get current logged in user
//       final uid = FirebaseAuth.instance.currentUser?.uid;
//
//       if (uid == null) return null;
//
//       // reference to user's node
//       DatabaseReference ref = FirebaseDatabase.instance.ref("providers/$uid");
//
//       // fetch snapshot
//       DatabaseEvent event = await ref.once();
//
//       if (event.snapshot.exists) {
//         final data = event.snapshot.value as Map<dynamic, dynamic>;
//         return data["name"]; // get "name" field
//       } else {
//         return null;
//       }
//     } catch (e) {
//       print("Error fetching user name: $e");
//       return null;
//     }
//   }
//
//
//   String get _greeting {
//     final hour = DateTime.now().hour;
//     if (hour < 12) {
//       return 'Good Morning';
//     } else if (hour < 17) {
//       return 'Good Afternoon';
//     } else {
//       return 'Good Evening';
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//
//     return Scaffold(
//       backgroundColor: Colors.orange[400],
//       appBar: AppBar(
//         title: const Text(
//           'SewaMitra Provider',
//           style: TextStyle(
//               fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
//         ),
//         backgroundColor: Colors.white38,
//         iconTheme: const IconThemeData(color: Colors.black),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications, color: Colors.white),
//             onPressed: () => Navigator.pushNamed(context, '/notifications'),
//           ),
//           IconButton(
//             icon: const Icon(Icons.calendar_month, color: Colors.white),
//             tooltip: "Booked Appointments",
//             onPressed: () => Navigator.pushNamed(context, '/appointments'),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Padding(
//           padding: const EdgeInsets.only(bottom: 16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Greeting Card
//               Container(
//                 width: double.infinity,
//                 margin: const EdgeInsets.all(16),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.deepOrange[600],
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 8,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       _greeting,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                         color:Colors.blue,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       providerUserName != null
//                           ? "Welcome, $providerUserName 👋"
//                           : "Loading...",
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Carousel
//               CarouselSlider(
//                 options: CarouselOptions(
//                   height: 180,
//                   autoPlay: true,
//                   viewportFraction: 0.8,
//                   enlargeCenterPage: true,
//                 ),
//                 items: carouselImages.map((url) {
//                   return Container(
//                     margin: const EdgeInsets.all(5),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black26,
//                           blurRadius: 6,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.network(
//                         url,
//                         fit: BoxFit.cover,
//                         width: 1000,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//
//               const SizedBox(height: 15),
//
//               // Services Header + Search
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Services',
//                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                     Container(
//                       width: 200,
//                       height: 38,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: const [
//                           BoxShadow(
//                               color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
//                         ],
//                       ),
//                       child: TextField(
//                         controller: _searchController,
//                         decoration: const InputDecoration(
//                           hintText: 'Search services...',
//                           hintStyle: TextStyle(color:Colors.grey ),
//                           prefixIcon: Icon(Icons.search, size: 18),
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.symmetric(vertical: 8),
//                         ),
//                         onChanged: (value) {
//                           setState(() {
//                             _filteredServices = _serviceProvider.searchServices(value);
//                           });
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Services Grid
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: GridView.builder(
//                   physics: const NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   itemCount: _filteredServices.length,
//                   gridDelegate:
//                   const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 4, // 4 per row
//                     childAspectRatio: 0.8, // smaller card height
//                     crossAxisSpacing: 12,
//                     mainAxisSpacing: 12,
//                   ),
//                   itemBuilder: (context, index) {
//                     return ProviderServiceCard(service: _filteredServices[index]);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//
//
//       // Bottom Navigation Bar
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         selectedItemColor: Colors.deepOrange[400],
//         unselectedItemColor: Colors.grey,
//         onTap: (index) {
//           setState(() => _currentIndex = index);
//           if (index == 0) {
//             // Home
//           } else if (index == 1) {
//             Navigator.pushNamed(context, '/provider_profile');
//           } else if (index == 2) {
//             Navigator.pushNamed(context, '/contactadmin');
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(
//               icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.person), label: "Profile"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.support_agent), label: "Contact Admin"),
//         ],
//       ),
//     );
//   }
// }
//
// class ProviderServiceCard extends StatelessWidget {
//   final Service service;
//   const ProviderServiceCard({super.key, required this.service});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 ServiceRegistrationScreen(service: service),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.network(
//                 service.imageUrl,
//                 height: 55,
//                 width: 55,
//                 fit: BoxFit.cover,
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 service.name,
//                 style: const TextStyle(
//                     fontWeight: FontWeight.bold, fontSize: 14),
//                 textAlign: TextAlign.center,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
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




class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int _currentIndex = 0;

  late TextEditingController _searchController;
  late List<Service> _filteredServices;
  late ServiceDataProvider _serviceProvider;
  String? providerUserName;

  final List<String> carouselImages = const [
    'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1470&q=80',
    'https://images.unsplash.com/photo-1540518614846-7eded433c457?auto=format&fit=crop&w=1457&q=80',
    'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=1474&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredServices = [];
    _loadProviderUserName();
  }

  void _loadProviderUserName() async {
    String? name = await fetchProviderUserName();
    setState(() {
      providerUserName = name;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _serviceProvider = Provider.of<ServiceDataProvider>(context, listen: false);
    if (_filteredServices.isEmpty) {
      _filteredServices = _serviceProvider.services;
    }
  }

  Future<String?> fetchProviderUserName() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;

      DatabaseReference ref = FirebaseDatabase.instance.ref("providers/$uid");
      DatabaseEvent event = await ref.once();

      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        return data["name"];
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user name: $e");
      return null;
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ProviderHomeBody(
        greeting: _greeting,
        providerUserName: providerUserName,
        carouselImages: carouselImages,
        searchController: _searchController,
        filteredServices: _filteredServices,
        onSearch: (value) {
          setState(() {
            _filteredServices = _serviceProvider.searchServices(value);
          });
        },
      ),
      ProviderProfileScreen(providerId: FirebaseAuth.instance.currentUser?.uid ?? ""),
      const ContactAdminScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.orange[400],
      appBar: _currentIndex == 0
          ? AppBar(
        title: const Text(
          'SewaMitra Provider',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        backgroundColor: Colors.white38,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            tooltip: "Booked Appointments",
            onPressed: () => Navigator.pushNamed(context, '/appointments'),
          ),
        ],
      )
          : null,
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepOrange[400],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: "Contact Admin"),
        ],
      ),
    );
  }
}

// ----------------- HOME BODY -----------------
class ProviderHomeBody extends StatelessWidget {
  final String greeting;
  final String? providerUserName;
  final List<String> carouselImages;
  final TextEditingController searchController;
  final List<Service> filteredServices;
  final ValueChanged<String> onSearch;

  const ProviderHomeBody({
    super.key,
    required this.greeting,
    required this.providerUserName,
    required this.carouselImages,
    required this.searchController,
    required this.filteredServices,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepOrange[600],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    providerUserName != null
                        ? "Welcome, $providerUserName 👋"
                        : "Loading...",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Carousel
            CarouselSlider(
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                viewportFraction: 0.8,
                enlargeCenterPage: true,
              ),
              items: carouselImages.map((url) {
                return Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: 1000,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 15),

            // Services Header + Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Services',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 200,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search services...',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, size: 18),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: onSearch,
                    ),
                  ),
                ],
              ),
            ),

            // Services Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: filteredServices.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  return ProviderServiceCard(service: filteredServices[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- SERVICE CARD -----------------
class ProviderServiceCard extends StatelessWidget {
  final Service service;
  const ProviderServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceRegistrationScreen(service: service),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image with constrained size
              SizedBox(
                height: 55,
                width: 55,
                child: Image.network(
                  service.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              // Text constrained to one line
              Text(
                service.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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










//
// class ServiceRegistrationScreen extends StatefulWidget {
//   final Service service;
//
//   const ServiceRegistrationScreen({super.key, required this.service});
//
//   @override
//   State<ServiceRegistrationScreen> createState() => _ServiceRegistrationScreenState();
// }
//
// class _ServiceRegistrationScreenState extends State<ServiceRegistrationScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _experienceController = TextEditingController();
//   final _hourlyChargeController = TextEditingController();
//   final _priceDescriptionController = TextEditingController();
//
//   bool _isSubmitting = false;
//   LatLng? _selectedLocation;
//   String? _address;
//
//   File? _idProofImage;
//   String? _idProofBase64;
//
//   File? _relatedWorkImage;
//   String? _relatedWorkBase64;
//
//   String? _priceType; // per unit, per hour, custom
//
//   final _dbRef = FirebaseDatabase.instance.ref();
//   final _auth = FirebaseAuth.instance;
//
//   /// Pick a single image (ID proof or related work)
//   Future<void> _pickImage(ImageSource source, bool isIdProof) async {
//     try {
//       final picker = ImagePicker();
//       final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
//
//       if (pickedFile != null) {
//         final file = File(pickedFile.path);
//         final bytes = await file.readAsBytes();
//         final base64Str = base64Encode(bytes);
//
//         setState(() {
//           if (isIdProof) {
//             _idProofImage = file;
//             _idProofBase64 = base64Str;
//           } else {
//             _relatedWorkImage = file;
//             _relatedWorkBase64 = base64Str;
//           }
//         });
//       }
//     } catch (e) {
//       log('Image picking failed: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Image selection failed: ${e.toString()}')),
//       );
//     }
//   }
//
//   /// Get current location
//   Future<void> _getCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         _showLocationError('Location services are disabled');
//         return;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           _showLocationError('Location permission denied');
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         _showLocationError('Location permissions are permanently denied. Enable in app settings');
//         return;
//       }
//
//       final position = await Geolocator.getCurrentPosition();
//       setState(() {
//         _selectedLocation = LatLng(position.latitude, position.longitude);
//       });
//       await _reverseGeocode(position.latitude, position.longitude);
//     } catch (e) {
//       log('Error getting location: $e');
//       _showLocationError('Failed to get location: ${e.toString()}');
//     }
//   }
//
//   void _showLocationError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
//
//   /// Select location from map
//   Future<void> _openMapSelector() async {
//     final selectedLocation = await Navigator.push<LatLng>(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MapSelectionScreen(initialLocation: _selectedLocation),
//       ),
//     );
//
//     if (selectedLocation != null) {
//       setState(() => _selectedLocation = selectedLocation);
//       await _reverseGeocode(selectedLocation.latitude, selectedLocation.longitude);
//     }
//   }
//
//   /// Reverse geocode
//   Future<void> _reverseGeocode(double latitude, double longitude) async {
//     try {
//       final addresses = await placemarkFromCoordinates(latitude, longitude);
//
//       if (addresses.isNotEmpty) {
//         final place = addresses.first;
//         setState(() {
//           _address = [
//             place.street,
//             place.subLocality,
//             place.locality,
//             place.administrativeArea,
//             place.postalCode,
//             place.country
//           ].where((part) => part != null && part.isNotEmpty).join(', ');
//         });
//       } else {
//         setState(() => _address = "Address not found");
//       }
//     } catch (e) {
//       log('Reverse geocoding failed: $e');
//       setState(() => _address = "Address lookup failed");
//     }
//   }
//
//   /// Submit registration
//   Future<void> _submitRegistration() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     if (_idProofBase64 == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please upload your ID proof')),
//       );
//       return;
//     }
//
//     if (_selectedLocation == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a location')),
//       );
//       return;
//     }
//
//     if (_priceType == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select how pricing is defined')),
//       );
//       return;
//     }
//
//     setState(() => _isSubmitting = true);
//
//     try {
//       final user = _auth.currentUser;
//       if (user == null) throw Exception('User not authenticated');
//
//       final newServiceRef = _dbRef.child('providers/${user.uid}/services').push();
//
//       await newServiceRef.set({
//         'service_id': widget.service.id,
//         'service_name': widget.service.name,
//         'experience': int.parse(_experienceController.text),
//         'hourly_charge': double.parse(_hourlyChargeController.text),
//         'price_type': _priceType,
//         'price_description': _priceType == 'Custom'
//             ? _priceDescriptionController.text
//             : null,
//         'location': {
//           'latitude': _selectedLocation!.latitude,
//           'longitude': _selectedLocation!.longitude,
//           'address': _address ?? '',
//         },
//         'registration_date': ServerValue.timestamp,
//         'status': 'pending',
//         'id_proof': _idProofBase64,
//         'related_work_image': _relatedWorkBase64,
//         'provider_id': user.uid,
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Registration submitted successfully!')),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       log('Registration failed: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Registration failed: ${e.toString()}')),
//       );
//     } finally {
//       setState(() => _isSubmitting = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     _experienceController.dispose();
//     _hourlyChargeController.dispose();
//     _priceDescriptionController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.orange[400],
//       appBar: AppBar(
//         title: Text(
//           'Register for ${widget.service.name}',
//           style: const TextStyle(
//               fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
//         ),
//         centerTitle: true,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
//         ),
//         backgroundColor: Colors.white38,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.orange[400]!, Colors.orange[300]!],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: _isSubmitting
//             ? const Center(child: CircularProgressIndicator())
//             : _buildRegistrationForm(),
//       ),
//     );
//   }
//
//   Widget _buildRegistrationForm() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 20),
//
//             // Experience
//             TextFormField(
//               controller: _experienceController,
//               decoration: const InputDecoration(
//                 labelText: 'Experience (years)',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.work_history, color: Colors.black),
//               ),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) return 'Please enter your experience';
//                 final years = int.tryParse(value);
//                 if (years == null) return 'Please enter a valid number';
//                 if (years <= 0) return 'Experience must be at least 1 year';
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//
//             // Price
//             TextFormField(
//               controller: _hourlyChargeController,
//               decoration: const InputDecoration(
//                 labelText: 'Starting Price (₹)',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.currency_rupee, color: Colors.black),
//               ),
//               keyboardType: const TextInputType.numberWithOptions(decimal: true),
//               validator: (value) {
//                 if (value == null || value.isEmpty) return 'Please enter charge';
//                 final charge = double.tryParse(value);
//                 if (charge == null) return 'Please enter a valid amount';
//                 if (charge <= 0) return 'Charge must be positive';
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//
//             // Price type
//             DropdownButtonFormField<String>(
//               value: _priceType,
//               decoration: const InputDecoration(
//                 labelText: 'Pricing Type',
//                 border: OutlineInputBorder(),
//
//               ),
//               items: const [
//                 DropdownMenuItem(value: 'Per Hour', child: Text('Per Hour')),
//                 DropdownMenuItem(value: 'Per Unit', child: Text('Per Unit')),
//                 DropdownMenuItem(value: 'Custom', child: Text('Custom Description')),
//               ],
//               onChanged: (val) => setState(() => _priceType = val),
//               validator: (val) => val == null ? 'Please select a pricing type' : null,
//             ),
//             const SizedBox(height: 15),
//
//             if (_priceType == 'Custom')
//               TextFormField(
//                 controller: _priceDescriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Price Description (e.g., per visit, per sq. ft.)',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (_priceType == 'Custom' && (value == null || value.isEmpty)) {
//                     return 'Please enter description for custom pricing';
//                   }
//                   return null;
//                 },
//               ),
//             const SizedBox(height: 20),
//
//             // Location selection
//             const Text('Service Location:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.my_location),
//                   label: const Text('Current Location'),
//                   onPressed: _getCurrentLocation,
//                 ),
//                 const SizedBox(width: 10),
//                 // ElevatedButton.icon(
//                 //   icon: const Icon(Icons.map),
//                 //   label: const Text('Visit Map'),
//                 //   onPressed: _openMapSelector,
//                 // ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             if (_selectedLocation != null)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(_address ?? 'Fetching address...', style: const TextStyle(fontSize: 14,
//                     fontWeight: FontWeight.bold,)),
//                   Text(
//                     'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, '
//                         'Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
//                     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                   ),
//                 ],
//               )
//             else
//               const Text('No location selected', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 20),
//
//             // ID Proof
//             const Text('Upload ID Proof:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.camera_alt),
//                   label: const Text('Camera'),
//                   onPressed: () => _pickImage(ImageSource.camera, true),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.photo_library),
//                   label: const Text('Gallery'),
//                   onPressed: () => _pickImage(ImageSource.gallery, true),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             if (_idProofImage != null)
//               Column(
//                 children: [
//                   Image.file(_idProofImage!, height: 150, fit: BoxFit.cover),
//                   const SizedBox(height: 5),
//                   const Text('ID Proof Selected', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                 ],
//               )
//             else
//               const Text('No ID proof selected', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 20),
//
//             // Related Work Image
//             const Text('Upload Related Work Image:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.camera_alt),
//                   label: const Text('Camera'),
//                   onPressed: () => _pickImage(ImageSource.camera, false),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.photo_library),
//                   label: const Text('Gallery'),
//                   onPressed: () => _pickImage(ImageSource.gallery, false),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             if (_relatedWorkImage != null)
//               Column(
//                 children: [
//                   Image.file(_relatedWorkImage!, height: 150, fit: BoxFit.cover),
//                   const SizedBox(height: 5),
//                   const Text('Related Work Image Selected', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                 ],
//               )
//             else
//               const Text('No related work image selected', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//
//             // Submit Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.all(20),
//                   backgroundColor: Colors.transparent,
//                   shadowColor: Colors.transparent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: _submitRegistration,
//                 child: Ink(
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Colors.purple, Colors.blue],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Container(
//                     alignment: Alignment.center,
//                     child: const Text(
//                       'Submit Registration',
//                       style: TextStyle(fontSize: 25, color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }












class ServiceRegistrationScreen extends StatefulWidget {
  final Service service;

  const ServiceRegistrationScreen({super.key, required this.service});

  @override
  State<ServiceRegistrationScreen> createState() => _ServiceRegistrationScreenState();
}

class _ServiceRegistrationScreenState extends State<ServiceRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceTypeController = TextEditingController();
  final _experienceController = TextEditingController();
  final _hourlyChargeController = TextEditingController();
  final _priceDescriptionController = TextEditingController();

  bool _isSubmitting = false;
  LatLng? _selectedLocation;
  String? _address;

  File? _idProofImage;
  String? _idProofBase64;

  File? _relatedWorkImage;
  String? _relatedWorkBase64;

  String? _priceType; // per unit, per hour, custom

  final _dbRef = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  /// Pick a single image (ID proof or related work)
  Future<void> _pickImage(ImageSource source, bool isIdProof) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        final base64Str = base64Encode(bytes);

        setState(() {
          if (isIdProof) {
            _idProofImage = file;
            _idProofBase64 = base64Str;
          } else {
            _relatedWorkImage = file;
            _relatedWorkBase64 = base64Str;
          }
        });
      }
    } catch (e) {
      log('Image picking failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image selection failed: ${e.toString()}')),
      );
    }
  }

  /// Get current location
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError('Location permissions are permanently denied. Enable in app settings');
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
      await _reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      log('Error getting location: $e');
      _showLocationError('Failed to get location: ${e.toString()}');
    }
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Select location from map
  Future<void> _openMapSelector() async {
    final selectedLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionScreen(initialLocation: _selectedLocation),
      ),
    );

    if (selectedLocation != null) {
      setState(() => _selectedLocation = selectedLocation);
      await _reverseGeocode(selectedLocation.latitude, selectedLocation.longitude);
    }
  }

  /// Reverse geocode
  Future<void> _reverseGeocode(double latitude, double longitude) async {
    try {
      final addresses = await placemarkFromCoordinates(latitude, longitude);

      if (addresses.isNotEmpty) {
        final place = addresses.first;
        setState(() {
          _address = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.postalCode,
            place.country
          ].where((part) => part != null && part.isNotEmpty).join(', ');
        });
      } else {
        setState(() => _address = "Address not found");
      }
    } catch (e) {
      log('Reverse geocoding failed: $e');
      setState(() => _address = "Address lookup failed");
    }
  }

  /// Submit registration
  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (_idProofBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your ID proof')),
      );
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    if (_priceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select how pricing is defined')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final newServiceRef = _dbRef.child('providers/${user.uid}/services').push();

      await newServiceRef.set({
        'service_id': widget.service.id,
        'service_name': widget.service.name,
        'service_type': _serviceTypeController.text, // New field added
        'experience': int.parse(_experienceController.text),
        'hourly_charge': double.parse(_hourlyChargeController.text),
        'price_type': _priceType,
        'price_description': _priceType == 'Custom'
            ? _priceDescriptionController.text
            : null,
        'location': {
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
          'address': _address ?? '',
        },
        'registration_date': ServerValue.timestamp,
        'status': 'pending',
        'id_proof': _idProofBase64,
        'related_work_image': _relatedWorkBase64,
        'provider_id': user.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      log('Registration failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _experienceController.dispose();
    _hourlyChargeController.dispose();
    _priceDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Register for ${widget.service.name}',
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        backgroundColor: Colors.white38,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isSubmitting
            ? const Center(child: CircularProgressIndicator())
            : _buildRegistrationForm(),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Service Type/Specialization
            TextFormField(
              controller: _serviceTypeController,
              decoration: const InputDecoration(
                labelText: 'Service Type/Specialization',
                hintText: 'e.g., AC Repair, Plumbing, Electrical Wiring',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.handyman, color: Colors.black),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your service type or specialization';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Experience
            TextFormField(
              controller: _experienceController,
              decoration: const InputDecoration(
                labelText: 'Experience (years)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work_history, color: Colors.black),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your experience';
                final years = int.tryParse(value);
                if (years == null) return 'Please enter a valid number';
                if (years <= 0) return 'Experience must be at least 1 year';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Price
            TextFormField(
              controller: _hourlyChargeController,
              decoration: const InputDecoration(
                labelText: 'Starting Price (₹)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee, color: Colors.black),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter charge';
                final charge = double.tryParse(value);
                if (charge == null) return 'Please enter a valid amount';
                if (charge <= 0) return 'Charge must be positive';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Price type
            DropdownButtonFormField<String>(
              value: _priceType,
              decoration: const InputDecoration(
                labelText: 'Pricing Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Per Hour', child: Text('Per Hour')),
                DropdownMenuItem(value: 'Per Unit', child: Text('Per Unit')),
                DropdownMenuItem(value: 'Custom', child: Text('Custom Description')),
              ],
              onChanged: (val) => setState(() => _priceType = val),
              validator: (val) => val == null ? 'Please select a pricing type' : null,
            ),
            const SizedBox(height: 15),

            if (_priceType == 'Custom')
              TextFormField(
                controller: _priceDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Price Description (e.g., per visit, per sq. ft.)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_priceType == 'Custom' && (value == null || value.isEmpty)) {
                    return 'Please enter description for custom pricing';
                  }
                  return null;
                },
              ),
            const SizedBox(height: 20),

            // Location selection
            const Text('Service Location:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.my_location),
                  label: const Text('Current Location',style: TextStyle(color: Colors.black),),
                  onPressed: _getCurrentLocation,
                ),
                // const SizedBox(width: 10),
                // ElevatedButton.icon(
                //   icon: const Icon(Icons.map),
                //   label: const Text('Select on Map'),
                //   onPressed: _openMapSelector,
                // ),
              ],
            ),
            const SizedBox(height: 10),
            if (_selectedLocation != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_address ?? 'Fetching address...', style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.bold,)),
                  Text(
                    'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, '
                        'Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              )
            else
              const Text('No location selected', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // ID Proof
            const Text('Upload ID Proof:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt,),
                  label: const Text('Camera',style: TextStyle(color: Colors.black),),
                  onPressed: () => _pickImage(ImageSource.camera, true),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery',style: TextStyle(color: Colors.black),),
                  onPressed: () => _pickImage(ImageSource.gallery, true),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_idProofImage != null)
              Column(
                children: [
                  Image.file(_idProofImage!, height: 150, fit: BoxFit.cover),
                  const SizedBox(height: 5),
                  const Text('ID Proof Selected', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              )
            else
              const Text('No ID proof selected', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Related Work Image
            const Text('Upload Related Work Image:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera',style: TextStyle(color: Colors.black),),
                  onPressed: () => _pickImage(ImageSource.camera, false),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery',style: TextStyle(color: Colors.black),),
                  onPressed: () => _pickImage(ImageSource.gallery, false),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_relatedWorkImage != null)
              Column(
                children: [
                  Image.file(_relatedWorkImage!, height: 150, fit: BoxFit.cover),
                  const SizedBox(height: 5),
                  const Text('Related Work Image Selected', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              )
            else
              const Text('No related work image selected', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submitRegistration,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Submit Registration',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}