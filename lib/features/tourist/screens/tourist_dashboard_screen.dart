// lib/features/tourist/screens/tourist_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/features/tourist/screens/guide/tourist_guide_profile.dart';
import 'package:yaloo/features/tourist/screens/host/host_list_screen.dart';
import 'package:yaloo/features/tourist/screens/personal_information_screen.dart';
import 'package:yaloo/features/tourist/screens/tourist_booking_status_screen.dart';
import 'package:yaloo/features/tourist/screens/tourist_tour_completion_screen.dart';
import '../../auth/screens/common/login_screen.dart';
import '../../booking/screens/booking_details_screen.dart';
import '../../booking/screens/booking_request_sent_screen.dart';
import '../../booking/screens/booking_status_screen.dart';
import '../../booking/screens/payment_screen.dart';
import '../../booking/screens/stay_details_screen.dart';
import '../../booking/screens/tour_completion_screen.dart';
import '../../chat/screens/message_screen.dart';
import '../../common/screens/help_support/contact_support_screen.dart';
import '../../common/screens/help_support/faq_screen.dart';
import '../../common/screens/help_support/help_support_screen.dart';
import '../../common/screens/settings/change_password_screen.dart';
import '../../common/screens/settings/language_screen.dart';
import '../../common/screens/settings/settings_screen.dart';
import '../../common/screens/notification/notification_screen.dart';
import 'host/find_host_screen.dart';
import 'host/tourist_host_profile.dart';
import 'tourist_home_screen.dart';
import 'tourist_bookings_screen.dart';
import 'tourist_profile_screen.dart';
import 'package:yaloo/core/widgets/floating_chat_button.dart';
import 'package:yaloo/features/chat/screens/chat_list_screen.dart';

// ── New guide booking flow ────────────────────────────────────────────────────
import 'package:yaloo/features/tourist/screens/guide/find_guide_screen.dart';
import 'package:yaloo/features/tourist/screens/guide/guide_list_screen.dart';
import 'package:yaloo/features/tourist/screens/guide/guide_detail_screen.dart';
import 'package:yaloo/features/tourist/screens/guide/tour_information_screen.dart';
import 'package:yaloo/features/tourist/screens/guide/booking_confirmation_screen.dart';
import 'package:yaloo/features/tourist/screens/my_bookings_screen.dart';

class TouristDashboardScreen extends StatefulWidget {
  const TouristDashboardScreen({super.key});
  @override State<TouristDashboardScreen> createState() =>
      _TouristDashboardScreenState();
}

class _TouristDashboardScreenState extends State<TouristDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  final List<String> _tabRoutes = [
    '/touristHome', '/touristChat', '/myBookings', '/touristProfile',
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      _navigatorKey.currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() => _selectedIndex = index);
    _navigatorKey.currentState?.popUntil((r) => r.isFirst);
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

          // ── Bottom nav tabs ────────────────────────────────────────────
            case '/touristHome':       page = const TouristHomeScreen();    break;
            case '/touristChat':       page = const ChatListScreen();        break;
            case '/myBookings':   page = const MyBookingsScreen();        break;
            case '/touristProfile':    page = const TouristProfileScreen();  break;

          // ── NEW guide booking flow ─────────────────────────────────────
            case '/findGuide':         page = const FindGuideScreen();              break;
            case '/guideList':         page = const GuideListScreen();              break;
            case '/guideDetail':       page = const GuideDetailScreen();            break;
          // ✅ tourInformation is the booking form (was guide_booking_screen)
            case '/tourInformation':   page = const TourInformationScreen();        break;
            case '/bookingConfirmation': page = const BookingConfirmationScreen();  break;
            case '/myBookings':        page = const MyBookingsScreen();             break;

          // ── Old guide profile (keep for backwards compat) ──────────────
            case '/touristGuideProfile': page = const GuideProfileScreen();   break;

          // ── Existing booking screens (kept intact) ─────────────────────
            case '/bookingDetails':    page = const BookingDetailsScreen();   break;
            case '/payment':           page = const PaymentScreen();          break;
            case '/bookingRequestSent':page = const BookingRequestSentScreen(); break;

          // ── Host flow ──────────────────────────────────────────────────
            case '/findHost':         page = const FindHostScreen();          break;
            case '/hostList':         page = const HostListScreen();          break;
            case '/touristHostProfile':page = const TouristHostProfileScreen(); break;
            case '/stayDetails':      page = const StayDetailsScreen();       break;

          // ── Profile / settings ─────────────────────────────────────────
            case '/personalInformation': page = const PersonalInformationScreen(); break;
            case '/settings':          page = const SettingsScreen();         break;
            case '/changePassword':    page = const ChangePasswordScreen();   break;
            case '/language':          page = const LanguageScreen();         break;

          // ── Help & support ─────────────────────────────────────────────
            case '/helpSupport':       page = const HelpSupportScreen();      break;
            case '/contactSupport':    page = const ContactSupportScreen();   break;
            case '/faqs':              page = const FAQScreen();              break;

          // ── Notifications / messaging ──────────────────────────────────
            case '/notification':      page = const NotificationScreen();     break;
            case '/messageScreen':     page = const MessageScreen();          break;

            case '/login':     page = const LoginScreen();

            case '/bookingStatus':     page = const TouristBookingStatusScreen();
            case '/tourCompletion':     page = const TouristTourCompletionScreen();

            default:                   page = const TouristHomeScreen();
          }
          return MaterialPageRoute(
            builder: (_) => page,
            settings: settings,   // preserves arguments
          );
        },
      ),
      floatingActionButton: const FloatingChatButton(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Iconsax.home_2_copy),       label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Iconsax.message_2_copy),    label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Iconsax.calendar_2_copy),   label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Iconsax.user_square_copy),  label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.primaryBlack,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle:   AppTextStyles.textSmall.copyWith(fontSize: 12.sp),
        unselectedLabelStyle: AppTextStyles.textSmall.copyWith(fontSize: 12.sp),
        elevation: 8.0,
      ),
    );
  }
}