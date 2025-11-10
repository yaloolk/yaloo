import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/features/tourist/screens/tourist_guide_profile.dart';

// Import the 4 screens for your tabs
import '../../booking/screens/booking_details_screen.dart';
import '../../booking/screens/payment-screen.dart';
import '../../booking/screens/tour_information_screen.dart';
import 'tourist_home_screen.dart';
import 'tourist_chat_screen.dart';
import 'tourist_bookings_screen.dart';
import 'tourist_profile_screen.dart';

// --- IMPORT THE NEW WIDGET ---
import 'package:yaloo/core/widgets/floating_chat_button.dart';
// --- IMPORT THE OTHER SCREENS ---
import 'package:yaloo/features/tourist/screens/find_guide_screen.dart';
import 'package:yaloo/features/tourist/screens/guide_list_screen.dart';
import 'package:yaloo/features/tourist/screens/tourist_guide_profile.dart'; // <-- ADDED



class TouristDashboardScreen extends StatefulWidget {
  const TouristDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TouristDashboardScreen> createState() => _TouristDashboardScreenState();
}

class _TouristDashboardScreenState extends State<TouristDashboardScreen> {
  int _selectedIndex = 0;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  final List<String> _tabRoutes = [
    '/touristHome',
    '/touristChat',
    '/touristBookings',
    '/touristProfile',
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    _navigatorKey.currentState?.pushReplacementNamed(_tabRoutes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/touristHome',
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/touristHome':
              page = const TouristHomeScreen();
              break;
            case '/touristChat':
              page = const ChatScreen();
              break;
            case '/touristBookings':
              page = const BookingsScreen();
              break;
            case '/touristProfile':
              page = const ProfileScreen();
              break;
            case '/findGuide':
              page = const FindGuideScreen();
              break;
            case '/guideList':
              page = const GuideListScreen();
              break;
          // --- UPDATED: Add the new routes ---
            case '/touristGuideProfile':
              page = const GuideProfileScreen();
              break;
            case '/bookingDetails':
              page = const BookingDetailsScreen();
              break;
            case '/tourInformation':
              page = const TourInformationScreen();
              break;
            case '/payment':
              page = const PaymentScreen();
              break;
            default:
              page = const TouristHomeScreen();
          }
          return MaterialPageRoute(
            builder: (context) => page,
            settings: settings, // This is what passes the arguments
          );
        },
      ),

      floatingActionButton: const FloatingChatButton(),

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

        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.primaryBlack,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTextStyles.textSmall.copyWith(fontSize: 12),
        unselectedLabelStyle: AppTextStyles.textSmall.copyWith(fontSize: 12),
        elevation: 8.0,
      ),
    );
  }
}