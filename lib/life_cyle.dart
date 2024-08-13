import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grow_life/auth_screen.dart';
import 'package:grow_life/badges.dart';
import 'package:grow_life/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class PlantLifecycleScreen extends StatefulWidget {
  @override
  _PlantLifecycleScreenState createState() => _PlantLifecycleScreenState();
}

class _PlantLifecycleScreenState extends State<PlantLifecycleScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  Map<String, String> _plants = {};
  String? _selectedPlantId;
  List<Map<String, dynamic>> _currentPlantImages = [];
  String? _userName;
  String? _profilePicUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchPlants();
  }

  Future<void> _fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        final data = userDoc.data();

        // Fetch user data
        setState(() {
          _userName = data?['name'] ?? 'User';
          _profilePicUrl = data?['profilePictureUrl']; // This should be the path in Firebase Storage
        });

        // Retrieve profile image URL from Firebase Storage
        if (_profilePicUrl != null && _profilePicUrl!.isNotEmpty) {
          final storageRef = FirebaseStorage.instance.ref().child(_profilePicUrl!);
          _profilePicUrl = await storageRef.getDownloadURL();
        }
      } catch (e) {
        print('Error fetching user profile: $e');
        setState(() {
          _userName = 'User';
          _profilePicUrl = 'assets/default_profile_pic.png';
        });
      }
    } else {
      setState(() {
        _userName = 'User';
        _profilePicUrl = 'assets/default_profile_pic.png';
      });
    }
  }

  Future<void> _fetchPlants() async {
    final user = _auth.currentUser;
    if (user != null) {
      final plantDocs = await _firestore
          .collection('plants')
          .where('userId', isEqualTo: user.uid)
          .get();

      final plants = <String, String>{};
      for (var doc in plantDocs.docs) {
        plants[doc.id] = doc.data()['name'] ?? 'Unknown Plant';
      }

      setState(() {
        _plants = plants;
        if (plants.isNotEmpty) {
          _selectedPlantId = plants.keys.first;
          _fetchPlantImages(_selectedPlantId!);
        }
      });
    }
  }

  Future<void> _fetchPlantImages(String plantId) async {
    final imageDocs = await _firestore
        .collection('plants')
        .doc(plantId)
        .collection('images')
        .orderBy('timestamp')
        .get();

    final images = <Map<String, dynamic>>[];
    for (var imageDoc in imageDocs.docs) {
      images.add(imageDoc.data());
    }

    setState(() {
      _currentPlantImages = images;
    });
  }

  Future<void> _pickImage(String plantId) async {
  setState(() {
    _isUploading = true;
  });

  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    final imageFile = File(pickedFile.path);

    // Prompt user for additional details
    final Map<String, dynamic>? details = await _showDetailsDialog();

    if (details != null) {
      final weekNumber = details['weekNumber'];
      final description = details['description'];

      final storageRef = FirebaseStorage.instance.ref().child(
          'plant_lifecycle_images/$plantId/${DateTime.now().toString()}');
      await storageRef.putFile(imageFile);
      final imageUrl = await storageRef.getDownloadURL();

      await _firestore
          .collection('plants')
          .doc(plantId)
          .collection('images')
          .add({
        'imageUrl': imageUrl,
        'weekNumber': weekNumber,
        'description': description,
        'timestamp': Timestamp.now(),
      });

      _fetchPlantImages(plantId);

      // Update upload count and badges
      await _updateUploadCount();
    }
  }

  setState(() {
    _isUploading = false;
  });
}

Future<void> _updateUploadCount() async {
  final user = _auth.currentUser;
  if (user != null) {
    try {
      // Fetch current upload count
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final data = userDoc.data();
      int uploadCount = data?['uploadCount'] ?? 0;

      // Increment upload count
      await _firestore.collection('users').doc(user.uid).update({
        'uploadCount': uploadCount + 1,
      });



      final newBadge = await BadgeService().checkAndUpdateBadges(user.uid);
          if (newBadge != null) {
            _showCelebrationPopup(newBadge);
          }
    } catch (e) {
      print('Error updating upload count or badges: $e');
    }
  }
}


  Future<Map<String, dynamic>?> _showDetailsDialog() async {
    final TextEditingController weekController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Upload Image Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weekController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Week Number',
                  labelStyle: TextStyle(color: AppColors.primaryColor),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(color: AppColors.primaryColor),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text('Cancel',
                  style: TextStyle(color: AppColors.primaryColor)),
            ),
            ElevatedButton(
              onPressed: () {
                final weekNumber = weekController.text.isNotEmpty
                    ? int.parse(weekController.text)
                    : null;
                final description = descriptionController.text;

                Navigator.of(context).pop({
                  'weekNumber': weekNumber,
                  'description': description,
                });
              },
              child: Text('Upload'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
       await FirebaseAuth.instance.signOut();

                    // Clear the login state
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isLoggedIn', false);

                    // Navigate to the AuthScreen
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => AuthScreen(onSignIn: (user) {}),
                      ),);
    } catch (e) {
      print('Error logging out: $e');
    }
  }





Future<void> _showCelebrationPopup(String badge) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Prevent dismiss by tapping outside
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Full-screen Lottie animation
            Positioned.fill(
              child: Lottie.asset(
                'assets/celebration.json', // Path to Lottie animation file
                fit: BoxFit.cover,
              ),
            ),
            // Centered content
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8, // Adjust width as needed
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Congratulations!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                     const Text(
                      'You have earned the ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '"$badge"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen, // Highlight color for the badge
                      ),
                    ),
                    const Text(
                      ' badge! 🎉',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'OK',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   automaticallyImplyLeading: false,
      //   title: Row(
      //     children: [
      //       CircleAvatar(
      //         backgroundImage: _profilePicUrl != null
      //             ? NetworkImage(_profilePicUrl!)
      //             : AssetImage('assets/default_profile_pic.png')
      //                 as ImageProvider,
      //       ),
      //       SizedBox(width: 10),
      //       Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Text(
      //             _userName ?? 'John Doe',
      //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      //           ),
      //         ],
      //       ),
      //       Spacer(),
      //       IconButton(
      //         icon: Icon(Icons.logout, color: AppColors.primaryColor,),
      //         onPressed: () {
      //           _logout();
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Weekly',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    Text(
                      ' Growth',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  ' Progress',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Container(
              height: 50, // Set the height for the horizontal scroll
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _plants.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: _selectedPlantId == entry.key
                            ? Colors.white
                            : AppColors.primaryColor,
                        backgroundColor: _selectedPlantId == entry.key
                            ? AppColors.primaryColor
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(
                            color: Colors.green, // Set the border color to green
                            width: 1.0, // Adjust the border width as needed
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedPlantId = entry.key;
                          _fetchPlantImages(_selectedPlantId!);
                        });
                      },
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _selectedPlantId == entry.key
                              ? Colors.white
                              : AppColors.primaryColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: _currentPlantImages.isEmpty
                  ? Center(child: Text('No images available.'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: _currentPlantImages
                                .map(
                                  (imageData) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          child: Image.network(
                                            imageData['imageUrl'],
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Week ${imageData['weekNumber'] ?? ''}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                        if (imageData['description'] != null &&
                                            imageData['description'].isNotEmpty)
                                          Text(
                                            imageData['description'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Swipe Left',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Icon(
                                Icons.double_arrow,
                                size: 24.0,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            SizedBox(height: 50),
            if (_selectedPlantId != null)
              Center(
                child: ElevatedButton(
                  onPressed: () => _pickImage(_selectedPlantId!),
                  child: _isUploading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text('Uploading...'),
                          ],
                        )
                      : Text('Upload New Image'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
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

