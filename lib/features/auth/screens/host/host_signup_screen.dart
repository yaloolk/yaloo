import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_text_field.dart';
import 'package:yaloo/core/widgets/pill_action_button.dart';
import 'package:yaloo/core/widgets/social_auth_button.dart';


class HostSignupScreen extends StatefulWidget {
  const HostSignupScreen({super.key});

  @override
  State<HostSignupScreen> createState() => _HostSignupScreenState();
}

class _HostSignupScreenState extends State<HostSignupScreen> {


  // --- Controllers ---
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  bool _agreeToTerms = false;
  bool _canSignUp = false;
  bool _isLoading = false;
  String _errorMessage = '';

  final String _logoPath = 'assets/images/yaloo_logo.png';
  final String _googleIconPath = 'assets/icons/google.png';
  final String _facebookIconPath = 'assets/icons/facebook.png';
  final String _appleIconPath = 'assets/icons/apple.png';


  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final bool fieldsAreValid = _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;

    if (_canSignUp != (fieldsAreValid && _agreeToTerms)) {
      setState(() {
        _canSignUp = fieldsAreValid && _agreeToTerms;
      });
    }
  }

  // --- Sign Up Logic ---
  Future<void> _handleHostSignUp() async {
    if (!_canSignUp) return;
    setState(() { _isLoading = true; _errorMessage = ''; });

    // --- MOCKUP: Simulate success ---
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _isLoading = false; });

    // UPDATED: Pass email AND role as arguments
    Navigator.pushReplacementNamed(
      context,
      '/verifyEmail',
      arguments: {
        'email': _emailController.text.trim(),
        'role': 'Host', // <-- Pass the role
      },
    );
    // --- END MOCKUP ---
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                Image.asset(_logoPath, width: 80.w, height: 80.h),
                 SizedBox(height: 20.h),

                // Title
                Text(
                  'Become a Host', // <-- UPDATED TITLE
                  style: AppTextStyles.headlineLarge
                      .copyWith(fontSize: 32.sp, fontWeight: FontWeight.bold),
                ),
                 SizedBox(height: 10.h),
                Text(
                  'Share your home and earn with Yaloo.', // <-- UPDATED SUBTITLE
                  style: AppTextStyles.textSmall
                      .copyWith(color: AppColors.primaryGray, fontSize: 16.sp),
                ),
                 SizedBox(height: 40.h),

                CustomTextField(
                  controller: _emailController,
                  hintText: 'E-mail',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress, hint: '',
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  icon: Icons.lock_outline,
                  // UPDATED: from isObscure to obscureText
                  obscureText: _isPasswordObscure,
                  suffixIcon: _buildObscureToggle(_isPasswordObscure, () {
                    setState(() { _isPasswordObscure = !_isPasswordObscure; });
                  }), hint: '',
                ),
                 SizedBox(height: 16.h),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  icon: Icons.lock_outline,
                  // UPDATED: from isObscure to obscureText
                  obscureText: _isConfirmPasswordObscure,
                  suffixIcon: _buildObscureToggle(_isConfirmPasswordObscure, () {
                    setState(() { _isConfirmPasswordObscure = !_isConfirmPasswordObscure; });
                  }), hint: '',
                ),
                 SizedBox(height: 8.h),
                Text(
                  'At least 8 characters, 1 uppercase letter, 1 number, 1 symbol',
                  style: AppTextStyles.textSmall
                      .copyWith(color: AppColors.primaryGray, fontSize: 12.sp),
                ),
                 SizedBox(height: 20.h),

                // Terms and Conditions
                _buildTermsAndConditionsRow(),
                 SizedBox(height: 20.h),

                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding:  EdgeInsets.only(bottom: 10.h),
                    child: Text(
                      _errorMessage,
                      style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryRed),
                    ),
                  ),
                SizedBox(height: 40.h),
                // Sign Up Button
                PillActionButton(
                  label: 'Sign Up',
                  isLoading: _isLoading,
                  onPressed: _canSignUp ? _handleHostSignUp : null,
                ),
                // Sign In Footer
                 SizedBox(height: 40.h),
                _buildSeparator(),
                 SizedBox(height: 20.h),
                _buildSocialLoginRow(),
                 SizedBox(height: 30.h),
                _buildSignInFooter(context),
                 SizedBox(height: 20.h),

              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildObscureToggle(bool isObscure, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: IconButton(
        icon: Icon(
          isObscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColors.primaryGray,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildTermsAndConditionsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24.h,
          width: 24.w,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (bool? value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
              _validateForm(); // Re-validate
            },
            activeColor: AppColors.primaryBlue,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primaryBlue;
              }
              return AppColors.secondaryGray;
            }),
          ),
        ),
         SizedBox(width: 12.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray, fontSize: 13.sp),
              children: [
                const TextSpan(text: 'By Signing up, you agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: AppTextStyles.textSmall.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () { /* TODO: Open Terms */ },
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: AppTextStyles.textSmall.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () { /* TODO: Open Privacy */ },
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildSignInFooter(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.primaryGray),
          children: [
            const TextSpan(text: 'Already have an account? '),
            TextSpan(
              text: 'Sign In',
              style: AppTextStyles.textSmall.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushNamed(context, '/login');
                },
            ),
          ],
        ),
      ),
    );
  }
}