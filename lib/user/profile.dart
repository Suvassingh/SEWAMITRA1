import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _userData = {};
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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final snapshot = await _dbRef.child('users/${widget.userId}').get();
      if (snapshot.exists) {
        setState(() {
          _userData = Map<String, dynamic>.from(snapshot.value as Map);
          _initializeControllers();
          _isLoading = false;
        });
      } else {
        setState(() {
          _userData = {
            'name': 'New User',
            'email': '',
            'phone': '',
            'profileImage': '',
            'location': {
              'address': 'Current Location',
              'latitude': 0.0,
              'longitude': 0.0,
            },
          };
          _initializeControllers();
          _isLoading = false;
          _isEditing = true;
        });
      }
    } catch (e) {
      print('Error loading user: $e');
      setState(() => _isLoading = false);
    }
  }

  void _initializeControllers() {
    _nameController.text = _userData['name'] ?? '';
    _emailController.text = _userData['email'] ?? '';
    _phoneController.text = _userData['phone'] ?? '';
    _addressController.text = _userData['location']?['address'] ?? 'Current Location';
    _latController.text = (_userData['location']?['latitude'] ?? 0.0).toString();
    _lngController.text = (_userData['location']?['longitude'] ?? 0.0).toString();
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      _userData['name'] = _nameController.text;
      _userData['email'] = _emailController.text;
      _userData['phone'] = _phoneController.text;

      _userData['location'] = {
        'address': _addressController.text,
        'latitude': double.tryParse(_latController.text) ?? 0.0,
        'longitude': double.tryParse(_lngController.text) ?? 0.0,
      };

      try {
        await _dbRef.child('users/${widget.userId}').update(_userData);
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
          _userData['profileImage'] = 'data:image/jpeg;base64,$base64Image';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
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
        title: const Text('User Profile',style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black
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
        actions: _isEditing
            ? [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateUserData,
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
                      backgroundImage: (_userData['profileImage'] != null &&
                          _userData['profileImage'].isNotEmpty)
                          ? MemoryImage(
                          base64Decode(_userData['profileImage'].split(',').last))
                          : null,
                      child: (_userData['profileImage'] == null ||
                          _userData['profileImage'].isEmpty)
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

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person,color: Colors.black,),
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                ),
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
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
                  prefixIcon: Icon(Icons.email,color: Colors.black,),
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
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
                  prefixIcon: Icon(Icons.phone,color:Colors.black),
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                ),
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Address Field
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on,color: Colors.black,),
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
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
                  ),
                ),
              ] else ...[
                Text('Location: ${_userData['location']?['latitude']?.toStringAsFixed(6) ?? '0.0'}, '
                    '${_userData['location']?['longitude']?.toStringAsFixed(6) ?? '0.0'}'),
              ],
              const SizedBox(height: 30),

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
                          _loadUserData();
                          setState(() => _isEditing = false);
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('Save Profile'),
                        onPressed: _updateUserData,
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