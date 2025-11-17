import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/test_icons.dart';


// Import the 5 screens for your tabs
import 'guide_home_screen.dart';
import 'guide_chat_screen.dart';
import 'guide_bookings_screen.dart';
import 'guide_wallet_screen.dart';
import 'guide_profile_screen.dart';

// --- IMPORT THE REUSABLE CHAT BUTTON ---
import 'package:yaloo/core/widgets/floating_chat_button.dart';

class GuideDashboardScreen extends StatefulWidget {
  const GuideDashboardScreen({Key? key}) : super(key: key);

  @override
  State<GuideDashboardScreen> createState() => _GuideDashboardScreenState();
}

class _GuideDashboardScreenState extends State<GuideDashboardScreen> {
  int _selectedIndex = 0;

  // This is the key: A global key for our nested Navigator
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // This list holds the *route names* for our tabs
  final List<String> _tabRoutes = [
    '/guideHome',
    '/guideChat',
    '/guideBookings',
    '/guideWallet',
    '/guideProfile',
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // If tapping the same tab, pop to the first route in that stack
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
    // Reset the navigator stack for the new tab
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    _navigatorKey.currentState?.pushReplacementNamed(_tabRoutes[index]);
  }

  @override
  Widget build(BuildContext context) {
    // Ensure ScreenUtil is initialized (if this is the first screen loaded)
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: true);

    return Scaffold(
      backgroundColor: Colors.white,

      // The body is now a Navigator, which hosts all other screens
      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/guideHome', // Start on the home tab
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
          // --- TAB SCREENS ---
            case '/guideHome':
              page = const GuideHomeScreen();
              break;
            case '/guideChat':
              page = const GuideChatScreen();
              break;
            case '/guideBookings':
              page = const GuideBookingsScreen();
              break;
            case '/guideWallet':
              page = const GuideWalletScreen();
              break;
            case '/guideProfile':
              page = const GuideProfileScreen();
              break;

          // --- NESTED PAGES (Add detail pages here later) ---
          // Example:
          // case '/tourRequestDetails':
          //   page = TourRequestDetailsScreen();
          //   break;

            default:
              page = const GuideHomeScreen();
          }
          return MaterialPageRoute(
            builder: (context) => page,
            settings: settings, // Passes arguments if any
          );
        },
      ),

      // The persistent chat button
      floatingActionButton: const FloatingChatButton(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Default

      // 5-Tab Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.messagesSquare),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.calendarCheck2),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.dollarSign),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        // Styling
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.primaryBlack,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTextStyles.textSmall.copyWith(fontSize: 12.sp),
        unselectedLabelStyle: AppTextStyles.textSmall.copyWith(fontSize: 12.sp),
        elevation: 8.0,
      ),
    );
  }
}