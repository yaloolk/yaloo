import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isEmailVerified = false;
  Timer? _timer;
  String _userEmail = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // --- TODO: BACKEND LOGIC ---
    // final user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   _userEmail = user.email ?? 'your email';
    //   _isEmailVerified = user.emailVerified;
    //   if (!_isEmailVerified) {
    //     _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
    //       _checkEmailVerification();
    //     });
    //   }
    // }
    // --- END BACKEND LOGIC ---

    // --- MOCKUP: Simulate the email ---
    Future.delayed(Duration.zero, () {
      setState(() {
        _userEmail = ModalRoute.of(context)?.settings.arguments as String? ?? 'your email';
      });
    });
    // --- END MOCKUP ---
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerification() async {
    // --- TODO: BACKEND LOGIC ---
    // final user = FirebaseAuth.instance.currentUser;
    // await user?.reload();
    // setState(() {
    //   _isEmailVerified = user?.emailVerified ?? false;
    // });

    // if (_isEmailVerified) {
    //   _timer?.cancel();
    //   // Email is verified! Now find out what profile to show.
    //   final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    //   final role = userDoc.get('role');
    //
    //   if (role == 'Tourist') {
    //     Navigator.pushReplacementNamed(context, '/profileCompletion'); // This is the old tourist one
    //   } else if (role == 'Guide') {
    //     Navigator.pushReplacementNamed(context, '/guideProfileCompletion');
    //   } else if (role == 'Host') {
    //     // Navigator.pushReplacementNamed(context, '/hostProfileCompletion');
    //   }
    // }
    // --- END BACKEND LOGIC ---
  }

  Future<void> _resendVerificationEmail() async {
    setState(() { _isLoading = true; });
    // --- TODO: BACKEND LOGIC ---
    // ... (resend logic) ...

    // --- MOCKUP: Simulate API call ---
    await Future.delayed(const Duration(seconds: 1));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Verification email resent successfully.')),
    );
    // --- END MOCKUP ---

    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Image.asset(
                'assets/images/yaloo_logo.png',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 20),
              Text(
                'Verify Your Email',
                style: AppTextStyles.headlineLarge
                    .copyWith(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.textSmall
                      .copyWith(color: AppColors.primaryGray, fontSize: 16, height: 1.5),
                  children: [
                    TextSpan(text: 'We\'ve sent a verification link to '),
                    TextSpan(
                      text: _userEmail,
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                    ),
                    TextSpan(text: '. Please check your inbox (and spam folder) and click the link to continue.'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // --- MOCKUP BUTTON to simulate verification ---
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // --- MOCKUP: Manually push to the next step ---
                    // We assume this is a Guide, so we send them to the
                    // new Guide Profile Completion screen
                    Navigator.pushReplacementNamed(context, '/guideProfileCompletion');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text('I\'ve Verified, Continue'),
                ),
              ),
              // --- END MOCKUP ---

              const Spacer(),

              // Resend Email Button
              Center(
                child: _isLoading
                    ? CircularProgressIndicator()
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}