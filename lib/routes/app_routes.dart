import 'package:flutter/material.dart';
import '../features/onboarding/screens/onboarding1.dart';
// import '../features/onboarding/screens/onboarding2.dart';
// import '../features/onboarding/screens/onboarding3.dart';
// import '../features/onboarding/screens/user_selection_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/onboarding1': (_) => const Onboarding1Screen(),
    // '/onboarding2': (_) => const Onboarding2(),
    // '/onboarding3': (_) => const Onboarding3(),
    // '/userSelection': (_) => const UserSelectionScreen(),
  };
}
