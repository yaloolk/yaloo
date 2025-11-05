import 'package:flutter/material.dart';
import '../features/onboarding/screens/onboarding.dart';
import '../features/onboarding/screens/user_selection_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/onboarding': (_) => const OnboardingScreen(),
    '/userSelection': (_) => const UserSelectionScreen(),
  };
}