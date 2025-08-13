import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class ProviderProfileScreen extends StatefulWidget {
  final String providerId;

  const ProviderProfileScreen({Key? key, required this.providerId}) : super(key: key);

  @override
  _ProviderProfileScreenState createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  Map<String, dynamic> _providerData = {};
  bool _isLoading = true;
  bool _isEditing = false;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProviderData();
  }

  Future<void> _loadProviderData() async {
    try {
      final snapshot = await _dbRef.child('providers/${widget.providerId}').get();
      if (snapshot.exists) {
        setState(() {
          _providerData = Map<String, dynamic>.from(snapshot.value as Map);
          _initializeControllers();
          _isLoading = false;
        });
      } else {
        setState(() {
          _providerData = {
            'name': 'New Provider',
            'email': '',
            'phone': '',
            'profileImage': '',
            'location': {
              'address': 'Current Location',
              'latitude': 0.0,
              'longitude': 0.0,
            },
            'services': {}, // Initialize empty services
          };
          _initializeControllers();
          _isLoading = false;
          _isEditing = true;
        });
      }
    } catch (e) {
      print('Error loading provider: $e');
      setState(() => _isLoading = false);
    }
  }

  void _initializeControllers() {
    _nameController.text = _providerData['name'] ?? '';
    _emailController.text = _providerData['email'] ?? '';
    _phoneController.text = _providerData['phone'] ?? '';
    _addressController.text = _providerData['location']?['address'] ?? 'Current Location';
    _latController.text = (_providerData['location']?['latitude'] ?? 0.0).toString();
    _lngController.text = (_providerData['location']?['longitude'] ?? 0.0).toString();
  }

  Future<void> _updateProviderData() async {
    if (_formKey.currentState!.validate()) {
      _providerData['name'] = _nameController.text;
      _providerData['email'] = _emailController.text;
      _providerData['phone'] = _phoneController.text;

      _providerData['location'] = {
        'address': _addressController.text,
        'latitude': double.tryParse(_latController.text) ?? 0.0,
        'longitude': double.tryParse(_lngController.text) ?? 0.0,
      };

      try {
        await _dbRef.child('providers/${widget.providerId}').update(_providerData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        setState(() => _isEditing = false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latController.text = position.latitude.toString();
        _lngController.text = position.longitude.toString();
        _addressController.text = 'Current Location';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        final bytes = await File(pickedFile.path).readAsBytes();
        final base64Image = base64Encode(bytes);

        setState(() {
          _providerData['profileImage'] = 'data:image/jpeg;base64,$base64Image';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Widget _buildServicesSection() {
    if (_providerData['services'] == null || _providerData['services'].isEmpty) {
      return const ListTile(
        leading: Icon(Icons.handyman),
        title: Text('No services added'),
        subtitle: Text('Add services in the provider dashboard'),
      );
    }

    final services = Map<String, dynamic>.from(_providerData['services']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('My Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        ...services.entries.map((entry) {
          final service = entry.value;
          return ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(service['service_name'] ?? 'Unknown Service'),
            subtitle: Text('₹${service['hourly_charge']} '),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Profile',style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black
        ),
          textAlign: TextAlign.center,),
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
        actions: _isEditing
            ? [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateProviderData,
          ),
        ]
            : [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => _isEditing = true),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Profile Image Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: (_providerData['profileImage'] != null &&
                          _providerData['profileImage'].isNotEmpty)
                          ? MemoryImage(
                          base64Decode(_providerData['profileImage'].split(',').last))
                          : null,
                      child: (_providerData['profileImage'] == null ||
                          _providerData['profileImage'].isEmpty)
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: _showImageSourceDialog,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: _showImageSourceDialog,
                    child: const Text('Change Profile Picture'),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Personal Information Card
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Personal Information',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Business Name',
                          prefixIcon: Icon(Icons.business),
                        ),
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your business name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        enabled: _isEditing,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Phone Field
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),

              // Location Card
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Service Location',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      // Address Field
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Business Address',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 16),

                      // Location Section
                      if (_isEditing) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _latController,
                                decoration: const InputDecoration(labelText: 'Latitude'),
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _lngController,
                                decoration: const InputDecoration(labelText: 'Longitude'),
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.location_on),
                          label: const Text('Use Current Location'),
                          onPressed: _getCurrentLocation,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.blue[800],
                          ),
                        ),
                      ] else ...[
                        Text('Coordinates: ${_providerData['location']?['latitude']?.toStringAsFixed(6) ?? '0.0'}, '
                            '${_providerData['location']?['longitude']?.toStringAsFixed(6) ?? '0.0'}'),
                      ],
                    ],
                  ),
                ),
              ),

              // Services Section
              Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildServicesSection(),
                ),
              ),

              // Action Buttons
              if (_isEditing) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: BorderSide(color: Colors.red),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          _loadProviderData();
                          setState(() => _isEditing = false);
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Save Profile'),
                        onPressed: _updateProviderData,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}