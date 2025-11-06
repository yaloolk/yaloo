import 'package:flutter/material.dart';
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

  };
}