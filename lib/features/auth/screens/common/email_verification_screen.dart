import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  String _userEmail = '';
  String _userRole = '';
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    _userEmail = args?['email'] ?? 'your email';
    _userRole = args?['role'] ?? 'Tourist';

    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkEmailVerified());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) return;

      // Refresh session to get updated user info
      final refreshedSession = await Supabase.instance.client.auth.refreshSession();
      final user = refreshedSession.user;

      final role = user?.userMetadata?['role'] as String? ?? 'Tourist';
      final isVerified = user?.emailConfirmedAt != null;

      if (isVerified) {
        _timer?.cancel(); // stop polling
        if (role == 'Guide') {
          Navigator.pushReplacementNamed(context, '/guideProfileCompletion');
        } else if (role == 'Host') {
          Navigator.pushReplacementNamed(context, '/hostProfileCompletion');
        } else {
          Navigator.pushReplacementNamed(context, '/profileCompletion');
        }
      }
    } catch (e) {
      // silently fail, could log for debugging
    }
  }

  /// Resends verification email using new SDK method
  Future<void> _resendVerificationEmail() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: _userEmail,

      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email resent successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend email: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              Image.asset(
                'assets/images/yaloo_logo.png',
                width: 80.w,
                height: 80.h,
              ),
              SizedBox(height: 20.h),
              Text(
                'Verify Your Email',
                style: AppTextStyles.headlineLarge
                    .copyWith(fontSize: 32.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.textSmall.copyWith(
                    color: AppColors.primaryGray,
                    fontSize: 16.sp,
                    height: 1.5.h,
                  ),
                  children: [
                    const TextSpan(text: 'We\'ve sent a verification link to '),
                    TextSpan(
                      text: _userEmail,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const TextSpan(
                        text: '. Please check your inbox (and spam folder) and click the link to continue.'),
                  ],
                ),
              ),
              SizedBox(height: 30.h),

              // Optional manual verification button
              Center(
                child: ElevatedButton(
                  onPressed: _checkEmailVerified,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('I\'ve Verified, Continue'),
                ),
              ),

              const Spacer(),

              // Resend Email Button
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : TextButton(
                  onPressed: _resendVerificationEmail,
                  child: Text(
                    'Resend Verification Email',
                    style: AppTextStyles.textSmall.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
