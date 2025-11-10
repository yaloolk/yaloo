import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_text_field.dart';
import '../../../../core/widgets/social_auth_button.dart';
import '../../../../core/widgets/pill_action_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordObscure = true;

  // Image & icon Paths
  final String _logoPath = 'assets/images/yaloo_logo.png';
  final String _googleIconPath = 'assets/icons/google.png';
  final String _facebookIconPath = 'assets/icons/facebook.png';
  final String _appleIconPath = 'assets/icons/apple.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.h),
                    Image.asset(
                      _logoPath,
                      width: 80.w,
                      height: 80.h,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 70.w,
                          height: 70.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.public_rounded,
                            color: AppColors.primaryBlue,
                            size: 40.w,
                          ),
                        );
                      },
                    ),
                     SizedBox(height: 20.h),
                    Text(
                      'Welcome',
                      style: AppTextStyles.headlineLarge
                          .copyWith(fontSize: 32.sp, fontWeight: FontWeight.bold),
                    ),
                     SizedBox(height: 10.h),
                    Text(
                      'Sign in with Social or fill the form to continue.',
                      style: AppTextStyles.textSmall
                          .copyWith(color: AppColors.primaryGray, fontSize: 16.sp),
                    ),
                     SizedBox(height: 40.h),

                    // --- REFACTORED ---
                    CustomTextField(
                      hintText: 'E-mail',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress, hint: '',
                    ),
                     SizedBox(height: 16.h),
                    CustomTextField(
                      hintText: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: _isPasswordObscure,
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: IconButton(
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
                      ), hint: '',
                    ),
                    // --- END REFACTOR ---

                     SizedBox(height: 20.h),
                    _buildRememberAndForgotRow(),
                     SizedBox(height: 30.h),

                    // --- REFACTORED ---
                    PillActionButton(
                      label: 'Sign in',
                      onPressed: () {
                        // TODO: Implement Sign In Logic

                      },
                    ),
                    // --- END REFACTOR ---

                     SizedBox(height: 40.h),
                    _buildSeparator(),
                     SizedBox(height: 20.h),
                    _buildSocialLoginRow(),
                     SizedBox(height: 40.h),
                    _buildSignUpFooter(context),
                     SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRememberAndForgotRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/forgotPassword');
          },
          child: Text(
            'Forgotten your password?',
            style: AppTextStyles.textSmall
                .copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.secondaryGray, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Or sign in with',
            style: AppTextStyles.textSmall
                .copyWith(color: AppColors.primaryGray),
          ),
        ),
        Expanded(child: Divider(color: AppColors.secondaryGray, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20.w,
      children: [
        SocialAuthButton(
          iconPath: _googleIconPath,
          onPressed: () { /* TODO: Google Sign In */ },
        ),
        SocialAuthButton(
          iconPath: _facebookIconPath,
          onPressed: () { /* TODO: Facebook Sign In */ },
        ),
        SocialAuthButton(
          iconPath: _appleIconPath,
          onPressed: () { /* TODO: Apple Sign In */ },
        ),
      ],
    );
  }

  Widget _buildSignUpFooter(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.primaryGray),
          children: [
            const TextSpan(text: 'Don\'t have an account? '),
            TextSpan(
              text: 'Sign Up',
              style: AppTextStyles.textSmall.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushNamed(context, '/userSelection');
                },
            ),
          ],
        ),
      ),
    );
  }
}