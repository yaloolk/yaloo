import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

// --- IMPORT THE REUSABLE CHAT BUTTON ---
import 'package:yaloo/core/widgets/floating_chat_button.dart';
import 'package:yaloo/features/host/screens/host_stay_request_details.dart';


import 'host_home_screen.dart';
// TODO: Create these other screens later, reusing guide/tourist ones for now if needed

import 'host_profile_screen.dart';
import 'host_chat_screen.dart';
import 'host_bookings_screen.dart';
import 'host_wallet_screen.dart';
import 'host_stay_requests_screen.dart';


class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  int _selectedIndex = 0;

  // This is the key: A global key for our nested Navigator
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // This list holds the *route names* for our tabs
  final List<String> _tabRoutes = [
    '/hostHome',
    '/hostChat',
    '/hostBookings',
    '/hostWallet',
    '/hostProfile',
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
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: true);

    return Scaffold(
      backgroundColor: Colors.white,

      // The body is now a Navigator, which hosts all other screens
      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/hostHome', // Start on the home tab
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
          // --- TAB SCREENS ---
            case '/hostHome':
              page = const HostHomeScreen();
              break;
            case '/hostChat':
              page = const HostChatScreen();
              break;
            case '/hostBookings':
              page = const HostBookingsScreen();
              break;
            case '/hostWallet':
              page = const HostWalletScreen();
              break;
            case '/hostProfile':
              page = const HostProfileScreen();
              break;
            case '/hostStayRequests':
              page = const HostStayRequestsScreen();
              break;
            case '/hostStayRequestDetails':
              page = const HostStayRequestDetailsScreen();
              break;

          // --- NESTED PAGES (Add detail pages here later) ---

            default:
              page = const HostHomeScreen();
          }
          return MaterialPageRoute(
            builder: (context) => page,
            settings: settings,
          );
        },
      ),

      // The persistent chat button
      floatingActionButton: const FloatingChatButton(),

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