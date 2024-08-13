import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grow_life/auth_screen.dart';
import 'package:grow_life/colors.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 1), // Add top margin
            Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  // Image Section with Overlapping Images and Green Borders
                  Container(
                    height: 500, // Set a fixed height for the container
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.green,
                                  width: 2), // Add green border
                            ),
                            child: Image.asset(
                              'assets/p2.png', // Replace with your image asset
                              width: 220, // Set width
                              height: 170,
                              fit: BoxFit.cover, // Set height
                            ),
                          ),
                        ),
                        Positioned(
                          top: 150, // Adjust this value to control the overlap
                          right: 50,

                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.green,
                                  width: 2), // Add green border
                            ),
                            child: Image.asset(
                              'assets/p3.png', // Replace with your image asset
                              width: 220, // Set width
                              height: 170,
                              fit: BoxFit.cover, // Set height
                            ),
                          ),
                        ),
                        Positioned(
                          top: 300, // Adjust this value to control the overlap
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.green,
                                  width: 2), // Add green border
                            ),
                            child: Image.asset(
                              'assets/p1.png', // Replace with your image asset
                              width: 220, // Set width
                              height: 170,
                              fit: BoxFit.cover, // Set height
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  // Text Section

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Plant',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Text(
                        ' Green, Live',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  
                  const Text(
                    'Clean',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Let's Plant & Thrive",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  // Button Section
                  ElevatedButton(
                    onPressed: () {
                         Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AuthScreen(onSignIn: (User? value) {  },),
        ),
      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'Get Started',
                      style: TextStyle(fontSize: 16,color: Colors.white),
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
