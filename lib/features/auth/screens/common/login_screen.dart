// lib/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_text_field.dart';
import 'package:yaloo/core/widgets/social_auth_button.dart';
import 'package:yaloo/core/widgets/pill_action_button.dart';
import 'package:yaloo/core/services/api_service.dart';
import 'package:yaloo/core/services/auth_guard_service.dart';
import 'package:yaloo/core/storage/secure_storage.dart'; // ADD THIS

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordObscure = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DjangoApiService _apiService = DjangoApiService();
  final AuthGuardService _authGuard = AuthGuardService();
  final SecureStorage _secureStorage = SecureStorage(); // ADD THIS

  final String _logoPath = 'assets/images/yaloo_logo.png';
  final String _googleIconPath = 'assets/icons/google.png';
  final String _facebookIconPath = 'assets/icons/facebook.png';
  final String _appleIconPath = 'assets/icons/apple.png';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Email and password required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (kDebugMode) {
        print('📧 Logging in with email: $email');
      }

      // Step 1: Authenticate with Supabase
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      final session = response.session; // GET THE SESSION

      if (user == null || session == null) {
        _showError('Invalid login credentials.');
        return;
      }

      if (kDebugMode) {
        print('✅ Supabase login successful');
      }
      if (kDebugMode) {
        print('User ID: ${user.id}');
      }

      // Check if email is verified
      if (user.emailConfirmedAt == null) {
        _showError('Please verify your email before logging in.');
        await Supabase.instance.client.auth.signOut();
        return;
      }

      // ⭐ CRITICAL FIX: Save the JWT token to SecureStorage
      final accessToken = session.accessToken;
      await _secureStorage.setAccessToken(accessToken);
      if (kDebugMode) {
        print('✅ JWT Token saved to SecureStorage');
      }
      if (kDebugMode) {
        print('Token (first 50 chars): ${accessToken.substring(0, 50)}...');
      }

      // Step 2: Test Django connection
      if (kDebugMode) {
        print('🔍 Testing Django connection...');
      }
      final isConnected = await _apiService.testConnection();

      if (!isConnected) {
        _showError('Cannot connect to server. Please try again.');
        return;
      }

      if (kDebugMode) {
        print('✅ Django server is reachable');
      }

      // Step 3: Verify authentication with Django
      try {
        if (kDebugMode) {
          print('🔐 Testing Django authentication...');
        }
        await _apiService.testAuth();
        if (kDebugMode) {
          print('✅ Django authentication successful');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Django auth test failed: $e');
        }
        _showError('Authentication failed: ${e.toString()}');
        return;
      }

      // Step 4: Get route based on profile status
      if (kDebugMode) {
        print('🧭 Determining route...');
      }
      final route = await _authGuard.getInitialRoute();

      if (kDebugMode) {
        print('🚀 Navigating to: $route');
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, route);

    } on AuthException catch (error) {
      if (kDebugMode) {
        print('❌ Supabase Auth Error: ${error.message}');
      }
      _showError(error.message);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Login error: $e');
      }
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }
      _showError('Login failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  _logoPath,
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome Back!',
                  style: AppTextStyles.headlineLarge
                      .copyWith(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Sign in to continue to your account.',
                  style: AppTextStyles.textSmall.copyWith(
                      color: AppColors.primaryGray, fontSize: 16),
                ),
                const SizedBox(height: 40),


                // Email
                CustomTextField(
                  controller: _emailController,
                  hintText: 'E-mail',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  hint: '',
                ),
                const SizedBox(height: 16),

                // Password
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: _isPasswordObscure,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.primaryGray,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordObscure = !_isPasswordObscure;
                      });
                    },
                  ),
                  hint: '',
                ),
                const SizedBox(height: 20),

                // Login Button
                PillActionButton(
                  label: _isLoading ? 'Logging In...' : 'Login',
                  onPressed: _isLoading ? null : _login,
                ),

                const SizedBox(height: 70),

                // Social Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialAuthButton(
                      iconPath: _googleIconPath,
                      onPressed: () {
                        _showError('Google login coming soon!');
                      },
                    ),
                    const SizedBox(width: 20),
                    SocialAuthButton(
                      iconPath: _facebookIconPath,
                      onPressed: () {
                        _showError('Facebook login coming soon!');
                      },
                    ),
                    const SizedBox(width: 20),
                    SocialAuthButton(
                      iconPath: _appleIconPath,
                      onPressed: () {
                        _showError('Apple login coming soon!');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Footer
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/userSelection');
                    },
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: AppTextStyles.textSmall.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}