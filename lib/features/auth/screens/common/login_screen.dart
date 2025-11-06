import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
                // UPDATED: This controls the WIDTH of the fields
                // Increase 'horizontal' to make fields narrower
                // Decrease 'horizontal' to make fields wider
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),

                    Image.asset(
                      _logoPath,
                      width: 80,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.public_rounded,
                            color: AppColors.primaryBlue,
                            size: 40,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Welcome Text
                    Text(
                      'Welcome',
                      style: AppTextStyles.headlineLarge
                          .copyWith(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sign in with Social or fill the form to continue.',
                      style: AppTextStyles.textSmall
                          .copyWith(color: AppColors.primaryGray, fontSize: 16),
                    ),
                    const SizedBox(height: 40),

                    // Email Field
                    _buildEmailField(),
                    const SizedBox(height: 16),

                    // Password Field
                    _buildPasswordField(),
                    const SizedBox(height: 20),

                    // Forgotten Password
                    _buildRememberAndForgotRow(),
                    const SizedBox(height: 30),

                    // Sign in Button
                    _buildSignInButton(),
                    const SizedBox(height: 40),

                    // "Or sign in with" Separator
                    _buildSeparator(),
                    const SizedBox(height: 20),

                    // Social Login
                    _buildSocialLoginRow(),
                    const SizedBox(height: 40),

                    // Sign Up Footer
                    _buildSignUpFooter(context),
                    const SizedBox(height: 20), // For bottom padding
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
    // UPDATED: Wrap in a Container to add shadow
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Field background color
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20), // Shadow color
            blurRadius: 20,
            offset: Offset(0, 5), // Shadow position
          ),
        ],
      ),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'E-mail',
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
                left: 20.0, right: 16.0), // Add space left and right of icon
            child: Icon(Icons.email_outlined, color: AppColors.primaryGray),
          ),
          filled: true,
          fillColor: Colors.white, // Match container color
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24), // Your updated radius
            borderSide: BorderSide.none,
          ),
          // UPDATED: Added right padding
          contentPadding: EdgeInsets.only(top: 20.0, bottom: 20.0, right: 20.0),
        ),
      ),
    );
  }

  // Helper widget for Password field
  Widget _buildPasswordField() {
    // UPDATED: Wrap in a Container to add shadow
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Field background color
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20), // Shadow color
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        obscureText: _isPasswordObscure,
        decoration: InputDecoration(
          hintText: 'Password',
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
                left: 20.0, right: 16.0),
            child: Icon(Icons.lock_outline, color: AppColors.primaryGray),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12.0),
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
            borderRadius: BorderRadius.circular(24), // Your updated radius
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 20.0),
        ),
      ),
    );
  }

  // Helper widget for Forgotten Password row
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
            style: AppTextStyles.textSmall // Your updated style
                .copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // Helper widget for Sign in button
  Widget _buildSignInButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // Your updated alignment
      children: [
        Text(
          'Sign in',
          style: AppTextStyles.headlineLarge.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 15), // Your updated spacing
        // FloatingActionButton(
        //   onPressed: () {
        //     // TODO: Implement Sign In Logic
        //   },
        //   backgroundColor: AppColors.primaryBlue,
        //   shape: const CircleBorder(),
        //   child: const Icon(Icons.arrow_forward, color: Colors.white), // Your updated shape
        // ),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement Sign In Logic
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            shape: const StadiumBorder(), // This makes it a "pill"
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          child: const Icon(Icons.arrow_forward, color: Colors.white, size: 28,),
        ),
      ],
    );
  }

  // Helper widget for "Or sign in with" separator
  Widget _buildSeparator() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.secondaryGray, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

  // Helper widget for Social Login buttons
  Widget _buildSocialLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(_googleIconPath),
        const SizedBox(width: 20),
        _buildSocialIcon(_facebookIconPath),
        const SizedBox(width: 20),
        _buildSocialIcon(_appleIconPath),
      ],
    );
  }

  Widget _buildSocialIcon(String assetPath) {
    return OutlinedButton(
      onPressed: () {
        // TODO: Implement Social Login
      },
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        side: BorderSide(color: AppColors.secondaryGray),
      ),
      // Using Image.asset for your .png icons
      child: Image.asset(
        assetPath,
        height: 28, // Adjust size as needed
        width: 28,
        errorBuilder: (context, error, stackTrace) {
          // Fallback icon
          return Icon(Icons.public, color: AppColors.primaryGray, size: 28);
        },
      ),
    );
  }

  // Helper widget for Sign Up footer
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