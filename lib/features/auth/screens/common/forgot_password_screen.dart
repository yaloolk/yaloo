import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart'; // <-- Import pinput
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  // For Page 3 (New Password)
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          // Disable manual swiping
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildSendEmailPage(),
            _buildEnterCodePage(),
            _buildNewPasswordPage(),
            _buildSuccessPage(),
          ],
        ),
      ),
    );
  }

  // --- Page 1: Send Email ---
  Widget _buildSendEmailPage() {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          _buildLogo(),
           SizedBox(height: 20.h),
          Text(
            'Forgot Password',
            style: AppTextStyles.headlineLarge
                .copyWith(fontSize: 32.sp, fontWeight: FontWeight.bold),
          ),
           SizedBox(height: 10.h),
          Text(
            'No worries, we\'ll send you reset instructions.',
            style: AppTextStyles.textSmall
                .copyWith(color: AppColors.primaryGray, fontSize: 16.sp),
          ),
           SizedBox(height: 40.h),
          _buildShadowedTextField(
            controller: _emailController,
            hint: 'E-mail',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
           SizedBox(height: 60.h),

          // const Spacer(),
          _buildActionButton(
            label: 'Reset Password',
            onPressed: () {
              // In a real app, you'd send the email here
              // For now, just go to the next page
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
          ),
           SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // --- Page 2: Enter Code ---
  Widget _buildEnterCodePage() {

    // Theme for the pinput
    final defaultPinTheme = PinTheme(
      width: 60.w,
      height: 60.h,
      textStyle: AppTextStyles.headlineLarge.copyWith(fontSize: 24.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
    );

    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          _buildLogo(),
           SizedBox(height: 20.h),
          Text(
            'Enter the Code',
            style: AppTextStyles.headlineLarge
                .copyWith(fontSize: 32.sp, fontWeight: FontWeight.bold),
          ),
           SizedBox(height: 10.h),
          // Show the email the user entered
          Text(
            'We\'ve sent a 4-digit code to ${_emailController.text}',
            style: AppTextStyles.textSmall
                .copyWith(color: AppColors.primaryGray, fontSize: 16.sp),
          ),
           SizedBox(height: 40.h),

          // --- Pinput Widget ---
          Center(
            child: Pinput(
              controller: _pinController,
              length: 4,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: AppColors.primaryBlue, width: 2.w),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  color: AppColors.thirdBlue,
                ),
              ),
              onCompleted: (pin) {
                // You can auto-verify here if you want
              },
            ),
          ),
           SizedBox(height: 60.h),
          // const Spacer(),

          _buildActionButton(
            label: 'Verify Email',
            onPressed: () {
              // In a real app, verify the code
              // For now, just go to the next page
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
          ),
          const Spacer(),
          // const SizedBox(height: 20),
          Center(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.primaryGray),
                children: [
                  const TextSpan(text: 'Didn\'t receive email? '),
                  TextSpan(
                    text: 'Resend Code',
                    style: AppTextStyles.textSmall.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // TODO: Implement Resend Code Logic
                      },
                  ),
                ],
              ),
            ),
          ),
           SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // --- Page 3: New Password ---
  Widget _buildNewPasswordPage() {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          _buildLogo(),
           SizedBox(height: 20.h),
          Text(
            'Set new password',
            style: AppTextStyles.headlineLarge
                .copyWith(fontSize: 32.sp, fontWeight: FontWeight.bold),
          ),
           SizedBox(height: 10.h),
          Text(
            'Must be at least 8 characters',
            style: AppTextStyles.textSmall
                .copyWith(color: AppColors.primaryGray, fontSize: 16.sp),
          ),
           SizedBox(height: 40.h),

          // New Password Field
          _buildShadowedPasswordField(
            hint: 'Enter New Password',
            isObscure: _isPasswordObscure,
            onToggleObscure: () {
              setState(() {
                _isPasswordObscure = !_isPasswordObscure;
              });
            },
          ),
           SizedBox(height: 16.h),

          // Confirm New Password Field
          _buildShadowedPasswordField(
            hint: 'Re-Enter New Password',
            isObscure: _isConfirmPasswordObscure,
            onToggleObscure: () {
              setState(() {
                _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
              });
            },
          ),

           SizedBox(height: 60.h),
          // const Spacer(),

          _buildActionButton(
            label: 'Reset Password',
            onPressed: () {
              // In a real app, validate and save password
              // For now, just go to the final page
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
          ),
           SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // --- Page 4: Success ---
  Widget _buildSuccessPage() {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          _buildLogo(),
           SizedBox(height: 20.h),
          Text(
            'Password changed',
            style: AppTextStyles.headlineLarge
                .copyWith(fontSize: 32.sp, fontWeight: FontWeight.bold),
          ),
           SizedBox(height: 10.h),
          Text(
            'Your password has been changed successfully. You can now log in with your new password.',
            style: AppTextStyles.textSmall
                .copyWith(color: AppColors.primaryGray, fontSize: 16.sp),
          ),
          // const Spacer(),
           SizedBox(height: 60.h),
          _buildActionButton(
            label: 'Sign in',
            onPressed: () {
              // Pop this whole screen and go back to Sign in
              Navigator.of(context).pop();
            },
          ),
           SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // --- Reusable Helper Widgets ---

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/yaloo_logo.png',
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
    );
  }

  // Reusable Text Field (from your login screen)
  Widget _buildShadowedTextField({
    TextEditingController? controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 16.w),
            child: Icon(icon, color: AppColors.primaryGray),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.only(top: 20.h, bottom: 20.h, right: 20.w),
        ),
      ),
    );
  }

  // Reusable Password Field (from your signup screen)
  Widget _buildShadowedPasswordField({
    required String hint,
    required bool isObscure,
    required VoidCallback onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        obscureText: isObscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 16.w),
            child: Icon(Icons.lock_outline, color: AppColors.primaryGray),
          ),
          suffixIcon: Padding(
            padding:  EdgeInsets.only(right: 12.w),
            child: IconButton(
              icon: Icon(
                isObscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.primaryGray,
              ),
              onPressed: onToggleObscure,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 20.h),
        ),
      ),
    );
  }

  // Reusable Action Button (from your login screen)
  Widget _buildActionButton({required String label, required VoidCallback onPressed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
         SizedBox(width: 15.w),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            shape: const StadiumBorder(), // This makes it a "pill"
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
          child: Icon(Icons.arrow_forward, color: Colors.white, size: 28.w),
        ),
      ],
    );
  }
}