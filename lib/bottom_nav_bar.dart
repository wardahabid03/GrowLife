import 'package:flutter/material.dart';
import 'package:grow_life/colors.dart';
// import 'package:grow_life/home_screen.dart';
import 'package:grow_life/plant_management.dart';
import 'package:grow_life/notifications.dart';
import 'package:grow_life/user_profile.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTapped;

  BottomNavBar({required this.currentIndex, required this.onTabTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      // backgroundColor: const Color.fromARGB(255, 166, 39, 39),
       selectedItemColor: AppColors.primaryColor, // Color for the selected item
      unselectedItemColor: Colors.grey, // Color for the unselected items
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
          BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),

          BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Plant Details',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.hourglass_bottom),
          label: 'Track',
        ),
      
      
      ],
      currentIndex: currentIndex,
      onTap: onTabTapped,
    );
  }
}
