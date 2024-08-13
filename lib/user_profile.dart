import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:grow_life/auth_screen.dart';
import 'package:grow_life/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  File? _image;
  int plantCount = 0;
  int uploadCount = 0;
  List<String> plantNames = [];

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImageToFirebase(_image!);
    }
  }

  Future<void> _uploadImageToFirebase(File image) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final storageRef =
        FirebaseStorage.instance.ref().child('profilePictures/${user.uid}.jpg');
    final uploadTask = storageRef.putFile(image);

    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'profilePictureUrl': downloadUrl,
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    // Clear the login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    // Navigate to the AuthScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => AuthScreen(onSignIn: (user) {}),
      ),
    );
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userData = userDoc.data() as Map<String, dynamic>;

    setState(() {
      plantCount = userData['plantCount'] ?? 0;
      uploadCount = userData['uploadCount'] ?? 0;
    });

    final plantDocs = await FirebaseFirestore.instance
        .collection('plants')
        .where('userId', isEqualTo: user.uid)
        .get();

    setState(() {
      plantNames = plantDocs.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('User Profile')),
        body: Center(child: Text('No user logged in')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Stack(
              children: [
                ClipPath(
                  clipper: OvalBottomClipper(),
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.asset(
                      'assets/P_background.png', // Add your background image asset
                      width: double.infinity,
                      height: 350,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 80.0, horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: _image != null
                                  ? FileImage(_image!)
                                  : userData['profilePictureUrl'] != null
                                      ? NetworkImage(
                                          userData['profilePictureUrl'])
                                      : null,
                              child: userData['profilePictureUrl'] == null &&
                                      _image == null
                                  ? Icon(Icons.person,
                                      size: 70, color: Colors.grey[600])
                                  : null,
                            ),
                            Positioned(
                              bottom: -5,
                              right: -5,
                              child: IconButton(
                                icon: Icon(Icons.camera_alt_rounded,
                                    size: 30,
                                    color: Color.fromARGB(255, 70, 68, 68)),
                                onPressed: _pickImage,
                              ),
                            ),
                            if (userData['badges'] != null)
                              Positioned(
                                top: -20,
                                right: -80,
                                child: Chip(
                                  label: Text(userData['badges']),
                                  backgroundColor:
                                      AppColors.lightGreenBackground,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(userData['name'] ?? 'N/A',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCountCard('Plants Count', plantCount),
                          SizedBox(width: 20),
                          _buildCountCard('Uploads Count', uploadCount),
                        ],
                      ),
                      SizedBox(height: 20),
                      if (plantNames.isNotEmpty)
                        _buildInfoCard('Plants Grown', plantNames)
                      else
                        Center(
                          child: Text(
                            'Start growing your garden!\nUpload plants to track their growth.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, color: AppColors.textColor),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountCard(String title, int count) {
    return Card(
      color: AppColors.lightGreenBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen)),
            SizedBox(height: 8),
            Text('$count',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<String> items) {
    return Center(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: AppColors.lightGreenBackground,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen)),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: items.map((item) {
                  return Chip(
                    label: Text(item,
                        style: TextStyle(color: AppColors.primaryColor)),
                    backgroundColor: Colors.white,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OvalBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 100);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
