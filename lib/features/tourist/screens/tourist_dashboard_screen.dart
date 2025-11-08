import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/floating_chat_button.dart';

// Import the 4 screens for your tabs
import 'tourist_home_screen.dart';
import 'tourist_chat_screen.dart';
import 'tourist_bookings_screen.dart';
import 'tourist_profile_screen.dart';


// --- IMPORT THE  GUIDE SCREENS ---
import 'package:yaloo/features/tourist/screens/find_guide_screen.dart';
import 'package:yaloo/features/tourist/screens/guide_list_screen.dart';


class TouristDashboardScreen extends StatefulWidget {
  const TouristDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TouristDashboardScreen> createState() => _TouristDashboardScreenState();
}

class _TouristDashboardScreenState extends State<TouristDashboardScreen> {
  int _selectedIndex = 0;

  // This is the key: A global key for our nested Navigator
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // This list holds the *route names* for our tabs, not the widgets
  final List<String> _tabRoutes = [
    '/touristHome',
    '/touristChat',
    '/touristBookings',
    '/touristProfile',
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // If tapping the same tab, pop to the first route
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
    // Use the Navigator key to pop all pages and push the new one
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    _navigatorKey.currentState?.pushReplacementNamed(_tabRoutes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // The body is now a Navigator, which hosts all other screens
      // This is the key to keeping the BottomNav/ChatButton persistent
      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/touristHome', // Start on the home tab
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/touristHome':
              page = const TouristHomeScreen(); // Your existing home screen
              break;
            case '/touristChat':
              page = const ChatScreen(); // Your placeholder
              break;
            case '/touristBookings':
              page = const BookingsScreen(); // Your placeholder
              break;
            case '/touristProfile':
              page = const ProfileScreen(); // Your placeholder
              break;
          // --- UPDATED: Add the FindGuideScreen to the nested router ---
            case '/findGuide':
              page = const FindGuideScreen();
              break;
            case '/guideList':
              page = const GuideListScreen();
              break;
            default:
              page = const TouristHomeScreen();
          }
          return MaterialPageRoute(
            builder: (context) => page,
            settings: settings,
          );
        },
      ),

      // The persistent chat button in the bottom-right corner
      floatingActionButton: const FloatingChatButton(),

      // 4-Tab Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.comments),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.calendar),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.user),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        // Styling
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.primaryBlack, // As per your file
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTextStyles.textSmall.copyWith(fontSize: 12),
        unselectedLabelStyle: AppTextStyles.textSmall.copyWith(fontSize: 12),
        elevation: 8.0,
      ),
    );
  }
}