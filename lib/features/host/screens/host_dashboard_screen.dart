// lib/features/host/screens/host_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/floating_chat_button.dart';
import 'package:yaloo/features/common/screens/help_support/help_support_screen.dart';
import 'package:yaloo/features/host/providers/host_provider.dart';
import 'package:yaloo/features/host/screens/host_stay_cancellation_screen.dart';
import 'package:yaloo/features/host/screens/host_stay_request_details.dart';
import '../../tourist/screens/tourist_public_profile_screen.dart';
import 'host_home_screen.dart';
import 'host_profile_screen.dart';
import 'host_chat_screen.dart';
import 'host_bookings_screen.dart';
import 'host_wallet_screen.dart';
import 'host_stay_requests_screen.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';


class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  final List<String> _tabRoutes = [
    '/hostHome',
    '/hostChat',
    '/hostBookings',
    '/hostWallet',
    '/hostProfile',
  ];

  @override
  void initState() {
    super.initState();
    // Load profile and dashboard data on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HostProvider>();
      provider.loadProfile();
      provider.loadDashboard();
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      return;
    }
    setState(() => _selectedIndex = index);
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    _navigatorKey.currentState?.pushReplacementNamed(_tabRoutes[index]);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/hostHome',
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
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
            case '/touristPublicProfile':
              page = const TouristPublicProfileScreen();
              break;
            case '/hostStayCancellation':
              page = const HostStayCancellationScreen();
              break;
            case '/helpSupport':
              page = const HelpSupportScreen();
              break;
            default:
              page = const HostHomeScreen();
          }
          return MaterialPageRoute(
            builder: (_) => page,
            settings: settings,
          );
        },
      ),
      floatingActionButton: const FloatingChatButton(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Iconsax.home_2_copy),        label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Iconsax.message_2_copy), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Iconsax.calendar_2_copy), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Iconsax.dollar_circle_copy),    label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Iconsax.user_square_copy),          label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.primaryBlack.withOpacity(0.45),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTextStyles.textSmall.copyWith(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.textSmall.copyWith(fontSize: 11.sp),
        elevation: 0,
      ),
    );
  }
}