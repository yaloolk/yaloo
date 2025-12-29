import 'package:flutter/material.dart';
import '../features/common/screens/help&support/help_support_screen.dart';
import '../features/common/screens/settings/change_password_screen.dart';
import '../features/common/screens/settings/language_screen.dart';
import '../features/onboarding/screens/onboarding.dart';
import '../features/onboarding/screens/user_selection_screen.dart';
import '../features/auth/screens/common/login_screen.dart';
import '../features/auth/screens/tourist/tourist_signup_screen.dart';
import '../features/auth/screens/tourist/tourist_profile_completion_screen.dart';
import '../features/auth/screens/common/forgot_password_screen.dart';
import '../features/auth/screens/guide/guide_signup_screen.dart';
import '../features/auth/screens/common/email_verification_screen.dart';
import '../features/auth/screens/guide/guide_profile_completion_screen.dart';
import '../features/auth/screens/common/profile_submitted_screen.dart';
import '../features/auth/screens/host/host_signup_screen.dart.';
import '../features/auth/screens/host/host_profile_completion_screen.dart';
import '../features/tourist/screens/personal_information_screen.dart';
import '../features/tourist/screens/tourist_dashboard_screen.dart';
import '../features/tourist/screens/guide/find_guide_screen.dart';
import '../features/tourist/screens/guide/guide_list_screen.dart';
import '../features/tourist/screens/guide/tourist_guide_profile.dart';
import '../features/booking/screens/booking_details_screen.dart';
import '../features/booking/screens/tour_information_screen.dart';
import '../features/booking/screens/payment_screen.dart';
import '../features/booking/screens/booking_request_sent_screen.dart';
import '../features/booking/screens/booking_status_screen.dart';
import '../features/booking/screens/tour_completion_screen.dart';
import '../features/tourist/screens/host/find_host_screen.dart';
import '../features/tourist/screens/host/host_list_screen.dart';
import '../features/tourist/screens/host/tourist_host_profile.dart';
import '../features/booking/screens/stay_details_screen.dart';
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





class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/onboarding': (_) => const OnboardingScreen(),
    '/userSelection': (_) => const UserSelectionScreen(),
    '/login': (_) => const LoginScreen(),
    '/signup': (_) => const SignupScreen(),
    '/profileCompletion': (_) => const ProfileCompletionScreen(),
    '/forgotPassword': (_) => const ForgotPasswordScreen(),
    '/guideSignup': (_) => const GuideSignupScreen(),
    '/verifyEmail': (_) => const EmailVerificationScreen(),
    '/guideProfileCompletion': (_) => const GuideProfileCompletionScreen(),
    '/profileSubmitted': (_) => const ProfileSubmittedScreen(),
    '/hostSignup': (_) => const HostSignupScreen(),
    '/hostProfileCompletion': (_) => const HostProfileCompletionScreen(),
    '/touristDashboard': (_) => const TouristDashboardScreen(),
    '/findGuide': (_) => const FindGuideScreen(),
    '/guideList': (_) => const GuideListScreen(),
    '/touristGuideProfile': (_) => const GuideProfileScreen(),
    '/bookingDetails': (_) => const BookingDetailsScreen(),
    '/tourInformation': (_) => const TourInformationScreen(),
    '/payment': (_) => const PaymentScreen(),
    '/bookingRequestSent': (_) => const BookingRequestSentScreen(),
    '/bookingStatus': (_) => const BookingStatusScreen(),
    '/tourCompletion': (_) => const TourCompletionScreen(),
    '/findHost': (_) => const FindHostScreen(),
    '/hostList': (_) => const HostListScreen(),
    '/touristHostProfile': (_) => const TouristHostProfileScreen(),
    '/stayDetails': (_) => const StayDetailsScreen(),
    '/guideDashboard': (_) => const GuideDashboardScreen(),
    '/guideTourRequests': (_) => const GuideTourRequestsScreen(),
    '/guideTourRequestDetails': (_) => const GuideTourRequestDetailsScreen(),
    '/guideBookingCancellation': (_) => const GuideBookingCancellationScreen(),
    '/hostDashboard': (_) => const HostDashboardScreen(),
    '/hostStayRequests': (_) => const HostStayRequestsScreen(),
    '/hostStayRequestDetails': (_) => const HostStayRequestDetailsScreen(),
    '/touristPublicProfile': (_) => const TouristPublicProfileScreen(),
    '/hostStayCancellation': (_) => const HostStayCancellationScreen(),
    '/personalInformation' : (_) => const PersonalInformationScreen(),
    '/settings' : (_) => const SettingsScreen(),
    '/changePassword': (_) => const ChangePasswordScreen(),
    '/language': (_) => const LanguageScreen(),
    '/helpSupport': (_) => const HelpSupportScreen(),





  };
}