import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grow_life/add_plant.dart';
import 'package:grow_life/auth_screen.dart';
import 'package:grow_life/colors.dart';
import 'package:grow_life/life_cyle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlantGrowthTrackerScreen extends StatelessWidget {
  PlantGrowthTrackerScreen({Key? key}) : super(key: key);

  Stream<Map<String, String>> _fetchUserDataStream(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      String userName = snapshot['name'] ?? 'User';
      String userImageUrl = snapshot['profilePictureUrl'] ?? 'default_image_url'; // Default image URL or path
      return {'userName': userName, 'userImageUrl': userImageUrl};
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('No user is currently logged in.')),
      );
    }

    return StreamBuilder<Map<String, String>>(
      stream: _fetchUserDataStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error loading user data.')),
          );
        } else if (snapshot.hasData) {
          String userName = snapshot.data!['userName']!;
          String userImageUrl = snapshot.data!['userImageUrl']!;

          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(
              backgroundColor: AppColors.backgroundColor,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(userImageUrl), // User's profile picture
                ),
              ),
              title: Text(userName, style: TextStyle(color: AppColors.textColor)),
              actions: [
                IconButton(
                  icon: Icon(Icons.logout, color: AppColors.primaryColor),
                  onPressed: () async {
                    // Sign out the user
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
                  },
                ),
              ],
            ),
      body: 
      Center(
        
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(height: 50,),
            Text(
              'Welcome To',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            RichText(
              text: TextSpan(
                text: 'Plant ',
                style: TextStyle(fontSize: 24, color: AppColors.textColor, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'Growth',
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                  TextSpan(
                    text: ' Tracker',
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Easily monitor the growth\nof your plants with our\nintuitive growth tracker.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textColor),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPlantScreen(

  ),)
                );
              },
              child: Text('Upload Pic', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlantLifecycleScreen()),
                );
              },
              child: Text('Track', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
        

            Row(
              children: [
            Image.asset(
              'assets/plant_pot1.png', // Replace with your image path
              height: 220,
              fit: BoxFit.cover,
            ),
     SizedBox(width: 105),
                  Image.asset(
              'assets/plant_pot2.png', // Replace with your image path
              height: 220,
              fit: BoxFit.cover,
            ),
            ],
            )
          ],
        ),
      ),
     
    );
  }

    return SizedBox.shrink();
  }
      );
      }
      }
