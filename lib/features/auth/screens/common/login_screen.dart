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
import 'package:yaloo/core/storage/secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isPasswordObscure = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DjangoApiService _apiService = DjangoApiService();
  final AuthGuardService _authGuard = AuthGuardService();
  final SecureStorage _secureStorage = SecureStorage();

  final String _logoPath = 'assets/images/yaloo_logo.png';
  final String _googleIconPath = 'assets/icons/google.png';
  final String _facebookIconPath = 'assets/icons/facebook.png';
  final String _appleIconPath = 'assets/icons/apple.png';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ─── ALL ORIGINAL LOGIC PRESERVED ─────────────────────────────────────────

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Email and password required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (kDebugMode) print('📧 Logging in with email: $email');

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      final session = response.session;

      if (user == null || session == null) {
        _showError('Invalid login credentials.');
        return;
      }

      if (kDebugMode) print('✅ Supabase login successful');
      if (kDebugMode) print('User ID: ${user.id}');

      if (user.emailConfirmedAt == null) {
        _showError('Please verify your email before logging in.');
        await Supabase.instance.client.auth.signOut();
        return;
      }

      final accessToken = session.accessToken;
      await _secureStorage.setAccessToken(accessToken);
      if (kDebugMode) print('✅ JWT Token saved to SecureStorage');
      if (kDebugMode) {
        print('Token (first 50 chars): ${accessToken.substring(0, 50)}...');
      }

      if (kDebugMode) print('🔍 Testing Django connection...');
      final isConnected = await _apiService.testConnection();

      if (!isConnected) {
        _showError('Cannot connect to server. Please try again.');
        return;
      }
      if (kDebugMode) print('✅ Django server is reachable');

      try {
        if (kDebugMode) print('🔐 Testing Django authentication...');
        await _apiService.testAuth();
        if (kDebugMode) print('✅ Django authentication successful');
      } catch (e) {
        if (kDebugMode) print('⚠️ Django auth test failed: $e');
        _showError('Authentication failed: ${e.toString()}');
        return;
      }

      if (kDebugMode) print('🧭 Determining route...');
      final route = await _authGuard.getInitialRoute();
      if (kDebugMode) print('🚀 Navigating to: $route');

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, route);
    } on AuthException catch (error) {
      if (kDebugMode) print('❌ Supabase Auth Error: ${error.message}');
      _showError(error.message);
    } catch (e, stackTrace) {
      if (kDebugMode) print('❌ Login error: $e');
      if (kDebugMode) print('Stack trace: $stackTrace');
      _showError('Login failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
                child:
                Text(message, style: const TextStyle(fontSize: 14))),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Gradient header banner
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.30,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF1565C0),
                    Color(0xFF1E88E5),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  // ── Logo + tagline ──────────────────────────────────────
                  SizedBox(
                    height: size.height * 0.24,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(_logoPath),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Yaloo',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Authentic local experiences',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.80),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Card ───────────────────────────────────────────────
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Container(
                        margin:
                        const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color:
                              Colors.black.withOpacity(0.08),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(
                            24, 30, 24, 30),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // Title
                            const Text(
                              'Welcome Back 👋',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0D1B2A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Sign in to continue your journey',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Email
                            _fieldLabel('Email Address'),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: _emailController,
                              hintText: 'you@example.com',
                              icon: Icons.email_outlined,
                              keyboardType:
                              TextInputType.emailAddress,
                              hint: '',
                            ),
                            const SizedBox(height: 18),

                            // Password
                            _fieldLabel('Password'),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: _passwordController,
                              hintText: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _isPasswordObscure,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(() =>
                                _isPasswordObscure =
                                !_isPasswordObscure),
                                child: Icon(
                                  _isPasswordObscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              ),
                              hint: '',
                            ),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, '/forgotPassword'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 2),
                                  tapTargetSize:
                                  MaterialTapTargetSize
                                      .shrinkWrap,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Color(0xFF1565C0),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Login button
                            _loginButton(),

                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                        color: Colors.grey[200])),
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  child: Text(
                                    'or continue with',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Divider(
                                        color: Colors.grey[200])),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Social buttons
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                _socialBtn(_googleIconPath, () {
                                  _showError(
                                      'Google login coming soon!');
                                }),
                                const SizedBox(width: 14),
                                _socialBtn(_facebookIconPath, () {
                                  _showError(
                                      'Facebook login coming soon!');
                                }),
                                const SizedBox(width: 14),
                                _socialBtn(_appleIconPath, () {
                                  _showError(
                                      'Apple login coming soon!');
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Sign up link
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, '/userSelection'),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey[600]),
                        children: const [
                          TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          disabledBackgroundColor:
          const Color(0xFF1565C0).withOpacity(0.55),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _socialBtn(String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFFE5E7EB), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(iconPath, width: 22, height: 22),
        ),
      ),
    );
  }
}