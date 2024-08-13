import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grow_life/life_cyle.dart';
import 'package:grow_life/main.dart';
import 'package:grow_life/notifications.dart';
import 'package:grow_life/plant_management.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';
import 'signup_form.dart';
import 'login_form.dart';
import 'add_plant.dart';

class AuthScreen extends StatefulWidget {
  final ValueChanged<User?> onSignIn;

  AuthScreen({required this.onSignIn});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isSignUp = true; // Toggle between sign-up and login

  Future<void> _signInOrSignUp() async {
    try {
      UserCredential userCredential;
      if (_isSignUp) {
        // Sign Up
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Update user profile and store in Firestore
        await _updateUserProfile(userCredential.user!);

        widget.onSignIn(userCredential.user);
      } else {
        // Sign In
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        widget.onSignIn(userCredential.user);
      }

      // Store login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // Fetch user data from Firestore
  
      

     Navigator.of(context).pushReplacement(
  MaterialPageRoute(
    builder: (context) => MainScreen(notificationService: NotificationService()),
  ),
);
      }
 catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

Future<void> _updateUserProfile(User user) async {
  final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

  final docSnapshot = await userDoc.get();
  if (!docSnapshot.exists) {
    await userDoc.set({
      'name': _nameController.text.isEmpty
          ? 'User ${user.uid}'
          : _nameController.text, // Default or user-provided name
      'achievements': 'None',
      'uploadCount': 0, // Initialize with 0
      'plantCount': 0, // Initialize with 0
      'consecutiveDays': 0, // Initialize with 0
      'profilePictureUrl': '', // Initialize with an empty string for the image URL
      'badges': 'New Gardener', // Initial badge with a motivating message
      
    });
  }
}


  Future<Map<String, String>> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String userName = userDoc['name'] ?? 'User';
      String userImageUrl = userDoc['profilePictureUrl'] ?? 'default_image_url'; // Default image URL or path
      return {'userName': userName, 'userImageUrl': userImageUrl};
    } catch (e) {
      print('Error fetching user data: $e');
      return {'userName': 'User', 'userImageUrl': 'default_image_url'}; // Return default values on error
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => AuthScreen(onSignIn: widget.onSignIn),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            _isSignUp
                ? SignUpForm(
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onSubmit: _signInOrSignUp,
                    onToggle: () {
                      setState(() {
                        _isSignUp = false;
                      });
                    },
                  )
                : LoginForm(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onSubmit: _signInOrSignUp,
                    onToggle: () {
                      setState(() {
                        _isSignUp = true;
                      });
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
