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
import 'package:sewamitra/user/userHomeScreen.dart';

// ... (Keep your existing Service, ServiceProviderModel, and ServiceDataProvider classes)

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _serviceProvider = Provider.of<ServiceDataProvider>(context, listen: false);
    if (_filteredServices.isEmpty) {
      _filteredServices = _serviceProvider.services;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SewaMitra Provider',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          textAlign: TextAlign.center,
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
      drawer: Drawer(
        width: 250,
        backgroundColor: Colors.indigo[400],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 160,
              decoration: const BoxDecoration(
                color: Colors.white38,
              ),
              child: const Center(
                child: Text(
                  'Provider Menu',
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
              title: const Text('Home', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black),
              title: const Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pushNamed(context, '/provider_profile'),
            ),
            ListTile(
              leading: const Icon(Icons.wallet, color: Colors.black),
              title: const Text('Wallet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pushNamed(context, '/walletofprovider'),
            ),
            // ListTile(
            //   leading: const Icon(Icons.work, color: Colors.black),
            //   title: const Text('My Services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            //   onTap: () => Navigator.pushNamed(context, '/my_services'),
            // ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.black),
              title: const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pushNamed(context, '/notifications'),
            ),
            ListTile(
              leading: const Icon(Icons.contact_emergency, color: Colors.black),
              title: const Text('Contact Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              onTap: () => Navigator.pushNamed(context, '/contactadmin'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [

          const SizedBox(height: 10),

          // Carousel Slider
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
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, size: 50),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Services Header with Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: 250,
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
                    decoration: const InputDecoration(
                      hintText: 'Search services...',
                      hintStyle: TextStyle(fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filteredServices = _serviceProvider.searchServices(value);
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
                mainAxisSpacing: 20,
              ),
              itemCount: _filteredServices.length,
              itemBuilder: (context, index) {
                return ProviderServiceCard(service: _filteredServices[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProviderServiceCard extends StatelessWidget {
  final Service service;

  const ProviderServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceRegistrationScreen(service: service),
          ),
        ),
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
                errorBuilder: (context, error, stackTrace) =>
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














class ServiceRegistrationScreen extends StatefulWidget {
  final Service service;

  const ServiceRegistrationScreen({super.key, required this.service});

  @override
  State<ServiceRegistrationScreen> createState() => _ServiceRegistrationScreenState();
}

class _ServiceRegistrationScreenState extends State<ServiceRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _experienceController = TextEditingController();
  final _hourlyChargeController = TextEditingController();

  bool _isSubmitting = false;
  LatLng? _selectedLocation;
  String? _address;

  File? _idProofImage;
  String? _idProofBase64;

  final _dbRef = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  /// Pick an image and store Base64
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();

        setState(() {
          _idProofImage = file;
          _idProofBase64 = base64Encode(bytes);
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

  /// Reverse geocode location using latitude and longitude
  Future<void> _reverseGeocode(double latitude, double longitude) async {
    try {
      final addresses = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

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

  /// Submit registration data to Firebase
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

    setState(() => _isSubmitting = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');


      // Update path to match your database structure: providers/{uid}/services
      final newServiceRef = _dbRef.child('providers/${user.uid}/services').push();

      await newServiceRef.set({
        'service_id': widget.service.id,
        'service_name': widget.service.name,
        'experience': int.parse(_experienceController.text),
        'hourly_charge': double.parse(_hourlyChargeController.text),
        'location': {
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
          'address': _address ?? '',
        },
        'registration_date': ServerValue.timestamp,
        'status': 'pending',
        'id_proof': _idProofBase64,
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
    _experienceController.dispose();
    _hourlyChargeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register for ${widget.service.name}',style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black
        ),
          textAlign: TextAlign.center,
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

      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : _buildRegistrationForm(),
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

            // Experience Field
            TextFormField(
              controller: _experienceController,
              decoration: const InputDecoration(
                labelText: 'Experience (years)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work_history,color: Colors.black,),
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

            // Hourly Charge Field
            TextFormField(
              controller: _hourlyChargeController,
              decoration: const InputDecoration(
                labelText: 'Charge (₹)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee,color: Colors.black,),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter charge';
                final charge = double.tryParse(value);
                if (charge == null) return 'Please enter a valid amount';
                if (charge <= 0) return ' Charge must be positive';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Location Section
            const Text('Service Location:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.my_location),
                  label: const Text('Current Location'),
                  onPressed: _getCurrentLocation,
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text('Select on Map'),
                  onPressed: _openMapSelector,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_selectedLocation != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_address ?? 'Fetching address...', style: const TextStyle(fontSize: 14)),
                  Text(
                    'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, '
                        'Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              )
            else
              const Text('No location selected',  style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // ID Proof Section
            const Text('Upload ID Proof:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_idProofImage != null)
              Column(
                children: [
                  Image.file(_idProofImage!, height: 150, fit: BoxFit.cover),
                  const SizedBox(height: 5),
                  Text('ID Proof Selected', style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold)),
                ],
              )
            else
              const Text('No ID proof selected', style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20), // Remove default padding
                  backgroundColor: Colors.transparent, // Make button background transparent
                  shadowColor: Colors.transparent, // Remove shadow if needed
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ),
                onPressed: _submitRegistration,

                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.blue], // Gradient colors
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
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