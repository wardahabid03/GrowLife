import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grow_life/add_plant.dart';
import 'package:grow_life/firebase_options.dart';
import 'package:grow_life/home_page.dart';
import 'package:grow_life/life_cyle.dart';
import 'package:grow_life/plantDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screen.dart';
import 'user_profile.dart';
import 'plant_management.dart';
import 'bottom_nav_bar.dart'; // Import the custom BottomNavBar widget
import 'notifications.dart'; // Import the NotificationService class
import 'package:timezone/data/latest.dart' as tz;

void main() async {
    tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  
  // Initialize NotificationService
  final notificationService = NotificationService();
  await notificationService.scheduleDailyNotification();
  
  runApp(MyApp(notificationService: notificationService));
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  MyApp({ required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Care App',
      home: MainScreen(notificationService: notificationService),
    );
  }
}

class MainScreen extends StatefulWidget {
  final NotificationService notificationService;

  MainScreen({required this.notificationService});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  User? _user;

  final List<Widget> _pages = [

    PlantGrowthTrackerScreen(),
    
    UserProfileScreen(),
  
        PlantSearchPage(),
          PlantLifecycleScreen(),
    
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _updateUser(User? user) async {
    setState(() {
      _user = user;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _setupNotifications();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isFirstTime) {
      prefs.setBool('isFirstTime', false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else if (!isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AuthScreen(onSignIn: _updateUser),
        ),
      );
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _updateUser(user);
      }
    }
  }

  void _setupNotifications() async {
    await widget.notificationService.checkAndNotifyUploadDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}
