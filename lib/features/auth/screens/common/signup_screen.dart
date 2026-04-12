// lib/features/auth/presentation/screens/signup_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/social_auth_button.dart';
import '../../../../core/widgets/pill_action_button.dart';
import 'package:yaloo/core/storage/secure_storage.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final SecureStorage _secureStorage = SecureStorage();

  late final String selectedRole;

  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  bool _agreeToTerms = false;
  bool _canSignUp = false;
  bool _isLoading = false;

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
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedRole =
    ModalRoute.of(context)!.settings.arguments as String;
  }

  // ─── ALL ORIGINAL LOGIC PRESERVED ─────────────────────────────────────────

  void _validateForm() {
    final valid = _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _agreeToTerms &&
        _passwordController.text == _confirmPasswordController.text;

    if (_canSignUp != valid) {
      setState(() {
        _canSignUp = valid;
      });
    }
  }

  Future<void> _handleSignup() async {
    if (_isLoading) return;

    final password = _passwordController.text.trim();
    if (!_isPasswordValid(password)) {
      _showError(
          'Password must be at least 8 characters with 1 uppercase, 1 number, and 1 symbol');
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();

    try {
      if (kDebugMode) print('🔐 Starting signup process...');
      if (kDebugMode) print('Email: $email');
      if (kDebugMode) print('Role: $selectedRole');

      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': selectedRole,
        },
      );

      if (res.session != null) {
        final token = res.session!.accessToken;
        await _secureStorage.setAccessToken(token);
        if (kDebugMode) print('✅ Token saved after signup');
      }

      final user = res.user;
      if (user == null) {
        _showError('Signup failed - no user returned');
        return;
      }

      if (kDebugMode) print('✅ Supabase user created: ${user.id}');
      if (kDebugMode) print('User metadata: ${user.userMetadata}');

      try {
        await _createUserProfile(user.id, selectedRole);
        if (kDebugMode) print('✅ User profile created in database');
      } catch (e) {
        if (kDebugMode) print('⚠️ Profile creation error: $e');
      }

      if (!mounted) return;
      _showSuccessDialog(email);
    } on AuthException catch (e) {
      if (kDebugMode) print('❌ Auth Exception: ${e.message}');
      if (e.message.toLowerCase().contains('already')) {
        _showAccountExistsDialog();
      } else {
        _showError(e.message);
      }
    } catch (e) {
      if (kDebugMode) print('❌ Unexpected error: $e');
      if (!mounted) return;
      _showError('Unexpected error occurred: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createUserProfile(
      String authUserId, String role) async {
    try {
      final existing = await Supabase.instance.client
          .from('user_profile')
          .select()
          .eq('auth_user_id', authUserId)
          .maybeSingle();

      if (existing != null) {
        if (kDebugMode) print('Profile already exists');
        return;
      }

      await Supabase.instance.client.from('user_profile').insert({
        'auth_user_id': authUserId,
        'user_role': role,
        'profile_status': 'active',
        'is_complete': false,
      });

      if (kDebugMode) print('User profile created successfully');
    } catch (e) {
      if (kDebugMode) print('Error creating user profile: $e');
    }
  }

  bool _isPasswordValid(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')))
      return false;
    return true;
  }

  void _showSuccessDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mark_email_read_rounded,
                    color: Colors.green.shade600, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Check Your Email',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D1B2A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We sent a verification link to\n$email\n\nClick the link to activate your account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '💡 Check your spam folder too.',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(
                        context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Go to Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountExistsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outline_rounded,
                    color: Colors.orange.shade600, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Account Exists',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D1B2A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'An account with this email already exists. Please sign in instead.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text('Cancel',
                          style:
                          TextStyle(color: Colors.grey[700])),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(
                            context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        elevation: 0,
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
                child: Text(message,
                    style: const TextStyle(fontSize: 14))),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─── UI ────────────────────────────────────────────────────────────────────

  String get _roleLabel {
    switch (selectedRole.toLowerCase()) {
      case 'guide':
        return 'Local Guide';
      case 'host':
        return 'Host';
      default:
        return 'Tourist';
    }
  }

  IconData get _roleIcon {
    switch (selectedRole.toLowerCase()) {
      case 'guide':
        return Icons.explore_outlined;
      case 'host':
        return Icons.home_outlined;
      default:
        return Icons.flight_takeoff_rounded;
    }
  }

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
              height: size.height * 0.24,
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
                  // ── Top section ────────────────────────────────────────
                  SizedBox(
                    height: size.height * 0.18,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                Navigator.of(context).pop(),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.2),
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Let's Get Started!",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Create your account',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white
                                        .withOpacity(0.80),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Role badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color:
                              Colors.white.withOpacity(0.18),
                              borderRadius:
                              BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                Colors.white.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_roleIcon,
                                    color: Colors.white,
                                    size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  _roleLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Card ───────────────────────────────────────────────
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(28),
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
                            24, 28, 24, 28),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
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
                              suffixIcon: IconButton(
                                onPressed: () => setState(() =>
                                _isPasswordObscure = !_isPasswordObscure),
                                icon: Icon(
                                  _isPasswordObscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              ),
                              hint: '',
                            ),
                            const SizedBox(height: 18),

                            // Confirm Password
                            _fieldLabel('Confirm Password'),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller:
                              _confirmPasswordController,
                              hintText: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscureText:
                              _isConfirmPasswordObscure,
                              suffixIcon: IconButton(
                                onPressed: () => setState(() =>
                                _isConfirmPasswordObscure = !_isConfirmPasswordObscure),
                                icon: Icon(
                                  _isConfirmPasswordObscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              ),

                              hint: '',
                            ),
                            const SizedBox(height: 10),

                            // Password hint
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                const Color(0xFFF0F4FF),
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 15,
                                    color: const Color(
                                        0xFF1565C0),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Min. 8 chars · 1 uppercase · 1 number · 1 symbol',
                                      style: TextStyle(
                                        color: const Color(
                                            0xFF1565C0),
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Terms
                            _buildTermsRow(),
                            const SizedBox(height: 24),

                            // Sign up button
                            _signupButton(),

                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                        color:
                                        Colors.grey[200])),
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  child: Text(
                                    'or sign up with',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Divider(
                                        color:
                                        Colors.grey[200])),
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
                                      'Google signup coming soon!');
                                }),
                                const SizedBox(width: 14),
                                _socialBtn(
                                    _facebookIconPath, () {
                                  _showError(
                                      'Facebook signup coming soon!');
                                }),
                                const SizedBox(width: 14),
                                _socialBtn(_appleIconPath, () {
                                  _showError(
                                      'Apple signup coming soon!');
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Sign in link
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/login'),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600]),
                        children: const [
                          TextSpan(
                              text: 'Already have an account? '),
                          TextSpan(
                            text: 'Sign In',
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

  Widget _buildTermsRow() {
    return GestureDetector(
        onTap: () {
          setState(() => _agreeToTerms = !_agreeToTerms);
          _validateForm();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // changed from .start
          children: [
            SizedBox(
              width: 24,   // slightly larger
              height: 24,
              child: Checkbox(
                value: _agreeToTerms,
                onChanged: (val) {
                  setState(() => _agreeToTerms = val ?? false);
                  _validateForm();
                },
                activeColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                side: BorderSide(color: Colors.grey[300]!, width: 1.5),
              ),
            ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4),
              children: [
                const TextSpan(
                    text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (kDebugMode)
                        print('Navigate to Terms of Service');
                    },
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (kDebugMode)
                        print('Navigate to Privacy Policy');
                    },
                ),
              ],
            ),
          ),
        ),
      ],
        ),
    );
  }

  Widget _signupButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _canSignUp && !_isLoading
            ? _handleSignup
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          disabledBackgroundColor:
          const Color(0xFF1565C0).withOpacity(0.40),
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
          'Create Account',
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