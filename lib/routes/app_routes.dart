import 'package:flutter/material.dart';
import '../features/auth/screens/common/approval_rejected_screen.dart';
import '../features/auth/screens/common/guide_welcome_screen.dart';
import '../features/auth/screens/host/host_stay_details_screen.dart';
import '../features/common/screens/help_support/help_support_screen.dart';
import '../features/common/screens/settings/change_password_screen.dart';
import '../features/common/screens/settings/language_screen.dart';
import '../features/onboarding/screens/onboarding.dart';
import '../features/onboarding/screens/splash_screen.dart';
import '../features/onboarding/screens/user_selection_screen.dart';
import '../features/auth/screens/common/login_screen.dart';
import '../features/auth/screens/common/signup_screen.dart';
import '../features/auth/screens/tourist/tourist_profile_completion_screen.dart';
import '../features/auth/screens/common/forgot_password_screen.dart';
import '../features/auth/screens/common/email_verification_screen.dart';
import '../features/auth/screens/guide/guide_profile_completion_screen.dart';
import '../features/auth/screens/common/profile_submitted_screen.dart';
import '../features/auth/screens/host/host_signup_screen.dart.';
import '../features/auth/screens/host/host_profile_completion_screen.dart';
import '../features/tourist/screens/host/my_stay_bookings_screen.dart';
import '../features/tourist/screens/host/stay_booking_confirmation_screen.dart';
import '../features/tourist/screens/host/stay_booking_status_screen.dart';
import '../features/tourist/screens/host/stay_review_screen.dart';
import '../features/tourist/screens/my_bookings_screen.dart';
import '../features/tourist/screens/tourist_tour_completion_screen.dart';
import '../features/tourist/screens/personal_information_screen.dart';
import '../features/tourist/screens/tourist_booking_status_screen.dart';
import '../features/tourist/screens/tourist_dashboard_screen.dart';
import '../features/tourist/screens/guide/find_guide_screen.dart';
import '../features/tourist/screens/guide/guide_list_screen.dart';
import '../features/tourist/screens/guide/tourist_guide_profile.dart';
import '../features/tourist/screens/host/find_host_screen.dart';
import '../features/tourist/screens/host/host_list_screen.dart';
import '../features/tourist/screens/host/tourist_host_profile.dart';
import '../features/guide/screens/guide_dashboard_screen.dart';
import '../features/guide/screens/guide_tour_requests_screen.dart';
import '../features/guide/screens/guide_booking_cancellation_screen.dart';
import '../features/guide/screens/guide_tour_request_details.dart';
import '../features/host/screens/host_dashboard_screen.dart';
import '../features/host/screens/host_stay_requests_screen.dart';
import '../features/host/screens/host_stay_request_details.dart';
import '../features/tourist/screens/tourist_public_profile_screen.dart';
import '../features/host/screens/host_stay_cancellation_screen.dart';
import '../features/common/screens/settings/settings_screen.dart';
import '../features/common/screens/notification/notification_screen.dart';
import 'package:yaloo/features/chat/screens/chat_list_screen.dart';
import 'package:yaloo/features/chat/screens/message_screen.dart';
import 'package:yaloo/features/auth/screens/common/approval_pending_screen.dart';
import 'package:yaloo/features/tourist/screens/host/stay_booking_form_screen.dart';



class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/splash': (context) => const SplashScreen(),
    '/onboarding': (_) => const OnboardingScreen(),
    '/userSelection': (_) => const UserSelectionScreen(),
    '/login': (_) => const LoginScreen(),
    '/signup': (_) => const SignupScreen(),
    '/profileCompletion': (_) => const ProfileCompletionScreen(),
    '/forgotPassword': (_) => const ForgotPasswordScreen(),
    '/verifyEmail': (_) => const EmailVerificationScreen(),
    '/guideProfileCompletion': (_) => const GuideProfileCompletionScreen(),
    '/profileSubmitted': (_) => const ProfileSubmittedScreen(),
    '/hostSignup': (_) => const HostSignupScreen(),
    '/hostProfileCompletion': (_) => const HostProfileCompletionScreen(),
    '/touristDashboard': (_) => const TouristDashboardScreen(),
    '/findGuide': (_) => const FindGuideScreen(),
    '/guideList': (_) => const GuideListScreen(),
    '/touristGuideProfile': (_) => const GuideProfileScreen(),
    '/touristHostProfile': (context) => const TouristHostProfileScreen(),
    '/guideDashboard': (_) => const GuideDashboardScreen(),
    '/guideTourRequests': (_) => const GuideTourRequestsScreen(),
    '/guideTourRequestDetails': (_) => const GuideTourRequestDetailsScreen(),
    '/guideBookingCancellation': (_) => const GuideBookingCancellationScreen(),
    '/hostDashboard': (_) => const HostDashboardScreen(),
    '/hostStayRequestDetails': (_) => const HostStayRequestDetailsScreen(),
    '/touristPublicProfile': (_) => const TouristPublicProfileScreen(),
    '/hostStayCancellation': (_) => const HostStayCancellationScreen(),
    '/personalInformation': (_) => const PersonalInformationScreen(),
    '/settings': (_) => const SettingsScreen(),
    '/changePassword': (_) => const ChangePasswordScreen(),
    '/language': (_) => const LanguageScreen(),
    '/helpSupport': (_) => const HelpSupportScreen(),
    '/notification': (_) => const NotificationScreen(),
    '/messageScreen': (_) => const MessageScreen(),
    '/chatListScreen': (_) => const ChatListScreen(),
    '/approvalPending': (context) => const ApprovalPendingScreen(),
    '/approvalRejected': (context) => const ApprovalRejectedScreen(),
    '/guideWelcome': (context) => const GuideWelcomeScreen(),
    '/hostStayDetails': (context) => const HostStayDetailsScreen(),
    '/myBookings': (context) => const MyBookingsScreen(),
    '/bookingStatus':   (_) => const TouristBookingStatusScreen(),
    '/tourCompletion':  (_) => const TouristTourCompletionScreen(),
    '/findHost':               (_) => const FindHostScreen(),
    '/hostList':               (_) => const HostListScreen(),
    '/stayBookingForm':        (_) => const StayBookingFormScreen(),
    '/stayBookingConfirmation':(_) => const StayBookingConfirmationScreen(),
    '/myStayBookings':         (_) => const MyStayBookingsScreen(),
    '/stayBookingStatus':      (_) => const StayBookingStatusScreen(),
    '/hostStayRequests':       (_) => const HostStayRequestsScreen(),
    '/stayReview': (context) => const StayReviewScreen(),


  };
}