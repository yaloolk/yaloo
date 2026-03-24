import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yaloo/core/services/auth_guard_service.dart';
import 'package:yaloo/core/storage/secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SecureStorage _secureStorage = SecureStorage();
  final AuthGuardService _authGuard = AuthGuardService();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Small delay for splash effect
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    try {
      // Check if user has session in Supabase
      final session = Supabase.instance.client.auth.currentSession;

      if (session == null) {
        // No session → Go to onboarding
        Navigator.pushReplacementNamed(context, '/onboarding');
        return;
      }

      // Session exists → Save token and determine route
      await _secureStorage.setAccessToken(session.accessToken);

      // Use AuthGuard to determine where to go based on profile status
      final route = await _authGuard.getInitialRoute();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, route);

    } catch (e) {
      // Error → Go to onboarding
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo
            Image.asset(
              'assets/images/yaloo_logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'Yaloo',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}