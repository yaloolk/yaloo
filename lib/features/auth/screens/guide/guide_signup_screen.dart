import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/social_auth_button.dart';

// This screen is for *Guide* signup. It only collects Email/Password.
class GuideSignupScreen extends StatefulWidget {
  const GuideSignupScreen({super.key});

  @override
  State<GuideSignupScreen> createState() => _GuideSignupScreenState();
}

class _GuideSignupScreenState extends State<GuideSignupScreen> {
  // --- Controllers to listen to text fields ---
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  bool _agreeToTerms = false;

  // --- State variable to control the button ---
  bool _canSignUp = false;

  // Image & icon Paths
  final String _logoPath = 'assets/images/yaloo_logo.png';
  final String _googleIconPath = 'assets/icons/google.png';
  final String _facebookIconPath = 'assets/icons/facebook.png';
  final String _appleIconPath = 'assets/icons/apple.png';

  // --- Loading and Error State ---
  bool _isLoading = false;
  String _errorMessage = '';


  @override
  void initState() {
    super.initState();
    // Add listeners to all controllers
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    // Clean up listeners and controllers
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _confirmPasswordController.removeListener(_validateForm);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Validation logic ---
  void _validateForm() {
    // Check if all fields are not empty and terms are agreed to
    final bool fieldsAreValid = _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;

    // Update the state of _canSignUp
    if (_canSignUp != (fieldsAreValid && _agreeToTerms)) {
      setState(() {
        _canSignUp = fieldsAreValid && _agreeToTerms;
      });
    }
  }

  // --- Sign Up Logic ---
  Future<void> _handleGuideSignUp() async {
    if (!_canSignUp) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // --- TODO: BACKEND LOGIC ---
    // try {
    //   1. Create user with Firebase Auth
    //   final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    //     email: _emailController.text.trim(),
    //     password: _passwordController.text.trim(),
    //   );
    //
    //   if (cred.user != null) {
    //     2. Send verification email
    //     await cred.user!.sendEmailVerification();
    //
    //     3. Save the role to Firestore
    //     await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
    //       'email': _emailController.text.trim(),
    //       'uid': cred.user!.uid,
    //       'role': 'Guide', // <-- This is the key
    //       'profileCompleted': false,
    //       'isApproved': false, // Admin approval pending
    //       'createdAt': FieldValue.serverTimestamp(),
    //     });
    //
    //     4. Navigate to verification screen
    //     Navigator.pushReplacementNamed(context, '/verifyEmail');
    //   }
    //
    // } on FirebaseAuthException catch (e) {
    //   setState(() {
    //     _errorMessage = e.message ?? 'An error occurred';
    //     _isLoading = false;
    //   });
    // } catch (e) {
    //    setState(() {
    //     _errorMessage = 'An error occurred. Please try again.';
    //     _isLoading = false;
    //   });
    // }

    // --- MOCKUP: Simulate success ---
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _isLoading = false; });

    // UPDATED: Pass email AND role as arguments
    Navigator.pushReplacementNamed(
      context,
      '/verifyEmail',
      arguments: {
        'email': _emailController.text.trim(),
        'role': 'Guide', // <-- Pass the role
      },
    );
    // --- END MOCKUP ---
  }


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

                    // Welcome Text
                    Text(
                      'Become a Guide', // <-- UPDATED TITLE
                      style: AppTextStyles.headlineLarge
                          .copyWith(fontSize: 32.sp, fontWeight: FontWeight.bold),
                    ),
                     SizedBox(height: 10.h),
                    Text(
                      'Create your account to get started.', // <-- UPDATED SUBTITLE
                      style: AppTextStyles.textSmall
                          .copyWith(color: AppColors.primaryGray, fontSize: 16.sp),
                    ),
                     SizedBox(height: 40.h),

                    // Email Field
                    _buildEmailField(),
                     SizedBox(height: 16.h),

                    // Password Field
                    _buildPasswordField(),
                     SizedBox(height: 16.h),

                    // Confirm Password Field
                    _buildConfirmPasswordField(),
                     SizedBox(height: 8.h),

                    // Password hint text
                    Text(
                      'At least 8 characters, 1 uppercase letter, 1 number, 1 symbol',
                      style: AppTextStyles.textSmall
                          .copyWith(color: AppColors.primaryGray, fontSize: 12.sp),
                    ),
                     SizedBox(height: 20.h),

                    // Terms and Conditions
                    _buildTermsAndConditionsRow(),
                     SizedBox(height: 10.h),

                    // Show error message
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
                    _buildSignUpButton(),
                     SizedBox(height: 40.h),

                    _buildSeparator(),
                     SizedBox(height: 20.h),
                    _buildSocialLoginRow(),
                     SizedBox(height: 30.h),
                    _buildSignInFooter(context),
                     SizedBox(height: 20.h), // For bottom padding
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for Email field
  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Field background color
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20), // Shadow color
            blurRadius: 20,
            offset: Offset(0, 5), // Shadow position
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController, // Attach controller
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'E-mail',
          prefixIcon: Padding(
            padding: EdgeInsets.only(
                left: 20.w, right: 16.w), // Add space left and right of icon
            child: Icon(Icons.email_outlined, color: AppColors.primaryGray),
          ),
          filled: true,
          fillColor: Colors.white, // Match container color
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r), // Your updated radius
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.only(top: 20.h, bottom: 20.h, right: 20.w),
        ),
      ),
    );
  }

  // Helper widget for Password field
  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Field background color
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20), // Shadow color
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: _passwordController, // Attach controller
        obscureText: _isPasswordObscure,
        decoration: InputDecoration(
          hintText: 'Password',
          prefixIcon: Padding(
            padding: EdgeInsets.only(
                left: 20.w, right: 16.w),
            child: Icon(Icons.lock_outline, color: AppColors.primaryGray),
          ),
          suffixIcon: Padding(
            padding:  EdgeInsets.only(right: 12.w),
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
          ),
          filled: true,
          fillColor: Colors.white, // Match container color
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r), // Your updated radius
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 20.h),
        ),
      ),
    );
  }

  // Helper widget for Confirm Password field
  Widget _buildConfirmPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Field background color
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20), // Shadow color
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: _confirmPasswordController, // Attach controller
        obscureText: _isConfirmPasswordObscure,
        decoration: InputDecoration(
          hintText: 'Confirm Password',
          prefixIcon: Padding(
            padding: EdgeInsets.only(
                left: 20.w, right: 16.w),
            child: Icon(Icons.lock_outline, color: AppColors.primaryGray),
          ),
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: IconButton(
              icon: Icon(
                _isConfirmPasswordObscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.primaryGray,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
                });
              },
            ),
          ),
          filled: true,
          fillColor: Colors.white, // Match container color
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r), // Your updated radius
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 20.h),
        ),
      ),
    );
  }

  // Helper widget for Terms and Conditions
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
              _validateForm(); // Re-validate when checkbox changes
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
                    ..onTap = () {
                      // TODO: Open Terms of Service
                    },
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
                    ..onTap = () {
                      // TODO: Open Privacy Policy
                    },
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

  // Helper widget for Sign Up button
  Widget _buildSignUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            'Sign Up',
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 15.w),
        ElevatedButton(
          onPressed: _isLoading || !_canSignUp
              ? null // Setting onPressed to null disables the button
              : _handleGuideSignUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isLoading || !_canSignUp
              ? AppColors.primaryGray.withAlpha(100)
              : AppColors.primaryBlue,
            shape: const StadiumBorder(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color
            : Colors.white)
              : Icon(Icons.arrow_forward, color: Colors.white, size:30.w),
        ),

      ],
    );
  }

  // Helper widget for Sign In footer
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
                  // Navigate back to Login screen
                  Navigator.pushNamed(context, '/login');
                },
            ),
          ],
        ),
      ),
    );
  }
}