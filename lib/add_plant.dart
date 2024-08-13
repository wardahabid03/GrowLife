import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grow_life/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddPlantScreen extends StatefulWidget {
  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _plantName = '';
  File? _image;
  String? _userId;
  String? _userName;
  String? _currentPlantId;
  bool _isUploading = false;
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }
  // Initialize animation controller for blinking effect

  Future<void> _initializeUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      _userId = user.uid;
      final userDoc = await _firestore.collection('users').doc(_userId).get();
      setState(() {
        _userName = userDoc.data()?['name'] ?? 'User';
      });
    }
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => _buildImageSourceDialog(),
    );

    if (source != null) {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }
  }

  Widget _buildImageSourceDialog() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Take a Photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Choose from Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: Icon(Icons.cancel),
            title: Text('Cancel'),
            onTap: () => Navigator.pop(context, null),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadPlant() async {
    if (_plantName.isEmpty) {
      // Show error if plant name is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a plant name.')),
      );
      return;
    }

    if (_image != null && _userId != null) {
      setState(() {
        _isUploading = true; // Set uploading state to true
      });

      try {
        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('plant_images/${DateTime.now().toString()}');
        await storageRef.putFile(_image!);
        final imageUrl = await storageRef.getDownloadURL();

        // Create a new plant document
        final plantRef =
            _firestore.collection('plants').doc(); // Generate a new document ID
        final plantId = plantRef.id;

        await plantRef.set({
          'name': _plantName,
          'timestamp': Timestamp.now(),
          'userId': _userId,
        });

        // Add the first image to the images subcollection
        final imageRef = plantRef
            .collection('images')
            .doc(); // Create a new document for the image
        await imageRef.set({
          'imageUrl': imageUrl,
          'timestamp': Timestamp.now(),
          'description': 'First capture.', // Add your description here
          'weekNumber': 1, // Add week number
        });

        // Update user plant count
        final userRef = _firestore.collection('users').doc(_userId);
        final userDoc = await userRef.get();
        final plantCount = (userDoc.data()?['plantCount'] ?? 0) + 1;

        await userRef.update({'plantCount': plantCount});

        setState(() {
          _currentPlantId = plantId; // Save the current plant ID
          _isUploading = false; // Set uploading state to false
        });
      } catch (e) {
        // Handle any errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload plant. Please try again.')),
        );
        setState(() {
          _isUploading = false; // Set uploading state to false on error
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryColor, // Use your app's primary color
        title: Text('Add Your New Plant'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${_userName ?? 'Plant Lover'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Let\'s start your green journey by adding your new plant. Follow the steps below to upload a plant image and give it a name.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            TextField(
              cursorColor: AppColors.primaryColor,
              decoration: const InputDecoration(
                labelText: 'Plant Name',
                labelStyle: TextStyle(
                    color: AppColors.primaryColor), // Change label color
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors
                          .primaryColor), // Change focused border color
                ),
              ),
              onChanged: (value) => _plantName = value,
            ),
            SizedBox(height: 16),
            _image == null
                ? Center(child: Text('No image selected.'))
                : Container(
                    constraints: const BoxConstraints(
                      maxHeight: 200, // Adjust the maximum height as needed
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            16.0), // Adjust the radius as needed
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
            SizedBox(height: 16),
            if (_isUploading)
              Center(
                  child: Text('Uploading...',
                      style: TextStyle(
                          fontSize: 16, color: AppColors.primaryColor)))
            else
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors
                          .primaryColor, // Use your app's primary color
                      minimumSize: Size(150, 50),
                    ),
                    child: Text('Pick Plant Image',
                        style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _uploadPlant,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Button background color
                      minimumSize: Size(150, 50),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: AppColors.primaryColor,
                            width: 1), // Green border color and width
                        borderRadius: BorderRadius.circular(
                            30), // Adjust border radius if needed
                      ),
                    ),
                    child: const Text(
                      'Upload Plant',
                      style: TextStyle(
                          color: AppColors.primaryColor), // Text color
                    ),
                  ),
                ],
              ),
            if (_currentPlantId != null)
              const Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    Text(
                      'Awesome!',
                      style: TextStyle(
                        fontSize: 24,
                        color: AppColors
                            .primaryColor, // Use your app's primary color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Great job! Your plant is now added. 🌱 Visit the Track page to watch its growth and keep your plant journey going!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
