// lib/features/auth/presentation/screens/forgot_password_screen.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

/// Forgot Password flow – 4 pages:
///  1. Enter email  →  triggers Supabase OTP (email)
///  2. Enter 6-digit OTP  →  verifies via Supabase
///  3. Set new password  →  updates via Supabase
///  4. Success screen  →  back to login
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // ─── Controllers ──────────────────────────────────────────────────────────
  final PageController _pageController = PageController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  // ─── State ─────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  int _currentPage = 0;

  // ─── Supabase client ───────────────────────────────────────────────────────
  final _supabase = Supabase.instance.client;

  // Read from .env — same source as Supabase.initialize() in main.dart.
  // Never hardcoded, never exposed in source code.
  String get _projectUrl => dotenv.env['SUPABASE_URL'] ?? '';
  String get _anonKey    => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _pinController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── BACKEND LOGIC ─────────────────────────────────────────────────────────

  // ─── Supabase project config ──────────────────────────────────────────────
  // Replace these with your actual Supabase project URL and anon key.
  // These are the same values you use in Supabase.initialize() in main.dart.
  static const String _supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '', // fill in your project URL e.g. https://xyz.supabase.co
  );
  static const String _supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '', // fill in your anon key
  );

  /// Page 1 → Send 6-digit OTP via direct REST call.
  ///
  /// WHY REST and not signInWithOtp()?
  /// The Flutter Supabase SDK's signInWithOtp() always sends a magic link
  /// unless "Email OTP" is explicitly turned on in the Supabase dashboard
  /// AND the SDK passes type=email correctly. The most reliable cross-version
  /// approach is to call the /auth/v1/otp endpoint directly with no redirect.
  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showError('Please enter a valid email address.');
      return;
    }

    final supabaseUrl = _projectUrl;
    final anonKey    = _anonKey;

    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('$supabaseUrl/auth/v1/otp');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'apikey': anonKey,
        },
        // create_user: false  → only send OTP if account already exists
        // No "redirect_to" field → Supabase sends a 6-digit code, NOT a magic link
        body: jsonEncode({
          'email': email,
          'create_user': false,
        }),
      );

      if (kDebugMode) {
        print('📧 OTP send status: ${response.statusCode}');
        print('📧 OTP send body:   ${response.body}');
      }

      if (response.statusCode == 200) {
        _nextPage();
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final msg = (body['msg'] ?? body['message'] ?? 'Failed to send code.').toString();
        if (msg.toLowerCase().contains('user not found') ||
            msg.toLowerCase().contains('no user')) {
          _showError('No account found with that email.');
        } else {
          _showError(msg);
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ OTP send error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Page 2 → Verify the 6-digit OTP entered by the user.
  Future<void> _verifyOtp() async {
    final otp = _pinController.text.trim();
    if (otp.length < 6) {
      _showError('Please enter the complete 6-digit code.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _supabase.auth.verifyOTP(
        email: _emailController.text.trim(),
        token: otp,
        type: OtpType.email,
      );

      if (response.session == null) {
        _showError('Invalid or expired code. Please try again.');
        return;
      }

      _nextPage();
    } on AuthException catch (e) {
      if (kDebugMode) print('❌ OTP verify error: ${e.message}');
      _showError('Invalid or expired code. Please request a new one.');
    } catch (e) {
      if (kDebugMode) print('❌ OTP verify error: $e');
      _showError('Verification failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Page 3 → Update the user's password via Supabase (session already active
  /// after OTP verification above).
  Future<void> _resetPassword() async {
    final password = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (password.isEmpty) {
      _showError('Please enter a new password.');
      return;
    }
    if (password.length < 8) {
      _showError('Password must be at least 8 characters.');
      return;
    }
    if (password != confirm) {
      _showError('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _supabase.auth.updateUser(UserAttributes(password: password));
      // Sign out so user logs in fresh with new password
      await _supabase.auth.signOut();
      _nextPage();
    } on AuthException catch (e) {
      if (kDebugMode) print('❌ Password update error: ${e.message}');
      _showError(e.message);
    } catch (e) {
      if (kDebugMode) print('❌ Password update error: $e');
      _showError('Failed to update password. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Resend OTP (used on page 2) — same direct REST call.
  Future<void> _resendOtp() async {
    setState(() => _isLoading = true);
    try {
      final supabaseUrl = _projectUrl;
      final anonKey    = _anonKey;

      final uri = Uri.parse('$supabaseUrl/auth/v1/otp');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'apikey': anonKey,
        },
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'create_user': false,
        }),
      );

      if (response.statusCode == 200) {
        _showSuccess('A new code has been sent to your email.');
        _pinController.clear();
      } else {
        _showError('Could not resend code. Please try again.');
      }
    } catch (e) {
      _showError('Could not resend code. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── NAVIGATION HELPERS ────────────────────────────────────────────────────

  void _nextPage() {
    setState(() => _currentPage++);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    if (_currentPage == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _currentPage--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // ─── SNACKBAR HELPERS ──────────────────────────────────────────────────────

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 14))),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 14))),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // ── Gradient header banner (matches login_screen) ───────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.28,
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
            child: Column(
              children: [
                // ── Header area ────────────────────────────────────────────
                SizedBox(
                  height: size.height * 0.22,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: _prevPage,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Logo + title
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  'assets/images/yaloo_logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.public_rounded,
                                    color: Color(0xFF1565C0),
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Yaloo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                _buildStepIndicator(),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ── Page content ───────────────────────────────────────────
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildSendEmailPage(size),
                      _buildEnterCodePage(size),
                      _buildNewPasswordPage(size),
                      _buildSuccessPage(size),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP INDICATOR ────────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    // Only show for pages 0-2 (not success page)
    if (_currentPage >= 3) return const SizedBox.shrink();
    return Row(
      children: List.generate(3, (i) {
        final active = i <= _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 5),
          width: active ? 20 : 8,
          height: 5,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ─── PAGE 1: SEND EMAIL ────────────────────────────────────────────────────

  Widget _buildSendEmailPage(Size size) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(28),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Forgot Password?'),
            const SizedBox(height: 8),
            _sectionSubtitle(
                "No worries! Enter your registered email and we'll send you a reset code."),
            const SizedBox(height: 28),

            _fieldLabel('Email Address'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hint: 'you@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 32),

            _buildPrimaryButton(
              label: 'Send Reset Code',
              icon: Icons.send_rounded,
              onPressed: _isLoading ? null : _sendOtp,
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: RichText(
                  text: TextSpan(
                    style:
                    TextStyle(fontSize: 13, color: Colors.grey[500]),
                    children: [
                      const TextSpan(text: 'Remember your password? '),
                      const TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PAGE 2: ENTER CODE ────────────────────────────────────────────────────

  Widget _buildEnterCodePage(Size size) {
    final defaultPinTheme = PinTheme(
      width: 52.w,
      height: 58.h,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A2E),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(28),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Enter the Code'),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5),
                children: [
                  const TextSpan(text: "We've sent a 6-digit code to "),
                  TextSpan(
                    text: _emailController.text.trim(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Center(
              child: Pinput(
                controller: _pinController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(
                        color: const Color(0xFF1565C0), width: 2),
                  ),
                ),
                submittedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    color: const Color(0xFFE3F2FD),
                    border: Border.all(
                        color: const Color(0xFF1565C0), width: 1.5),
                  ),
                ),
                onCompleted: (_) => _isLoading ? null : _verifyOtp(),
              ),
            ),
            const SizedBox(height: 32),

            _buildPrimaryButton(
              label: 'Verify Code',
              icon: Icons.verified_outlined,
              onPressed: _isLoading ? null : _verifyOtp,
            ),
            const SizedBox(height: 20),

            Center(
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : RichText(
                text: TextSpan(
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey[500]),
                  children: [
                    const TextSpan(text: "Didn't receive a code? "),
                    TextSpan(
                      text: 'Resend',
                      style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w700,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = _resendOtp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PAGE 3: NEW PASSWORD ──────────────────────────────────────────────────

  Widget _buildNewPasswordPage(Size size) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(28),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Set New Password'),
            const SizedBox(height: 8),
            _sectionSubtitle(
                'Create a strong password with at least 8 characters.'),
            const SizedBox(height: 28),

            _fieldLabel('New Password'),
            const SizedBox(height: 8),
            _buildPasswordField(
              controller: _newPasswordController,
              hint: '••••••••',
              isObscure: _isPasswordObscure,
              onToggle: () =>
                  setState(() => _isPasswordObscure = !_isPasswordObscure),
            ),
            const SizedBox(height: 16),

            _fieldLabel('Confirm Password'),
            const SizedBox(height: 8),
            _buildPasswordField(
              controller: _confirmPasswordController,
              hint: '••••••••',
              isObscure: _isConfirmPasswordObscure,
              onToggle: () => setState(() =>
              _isConfirmPasswordObscure = !_isConfirmPasswordObscure),
            ),
            const SizedBox(height: 8),

            // Password strength hint
            _buildPasswordHints(),
            const SizedBox(height: 28),

            _buildPrimaryButton(
              label: 'Reset Password',
              icon: Icons.lock_reset_rounded,
              onPressed: _isLoading ? null : _resetPassword,
            ),
          ],
        ),
      ),
    );
  }

  // ─── PAGE 4: SUCCESS ───────────────────────────────────────────────────────

  Widget _buildSuccessPage(Size size) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(28),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF2E7D32),
                size: 52,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Password Changed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your password has been updated successfully. You can now sign in with your new password.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),
            const SizedBox(height: 36),
            _buildPrimaryButton(
              label: 'Back to Sign In',
              icon: Icons.login_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── REUSABLE WIDGETS ──────────────────────────────────────────────────────

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(28),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.07),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      color: Color(0xFF1A1A2E),
    ),
  );

  Widget _sectionSubtitle(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 14,
      color: Colors.grey[600],
      height: 1.5,
    ),
  );

  Widget _fieldLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF374151),
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon:
          Icon(Icons.lock_outline_rounded, color: Colors.grey[400], size: 20),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              isObscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey[400],
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordHints() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _passwordHint('At least 8 characters'),
        const SizedBox(height: 4),
        _passwordHint('Mix of letters and numbers recommended'),
      ],
    );
  }

  Widget _passwordHint(String text) => Row(
    children: [
      Icon(Icons.info_outline_rounded, size: 13, color: Colors.grey[400]),
      const SizedBox(width: 6),
      Text(text,
          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
    ],
  );

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
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
              strokeWidth: 2.5, color: Colors.white),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}