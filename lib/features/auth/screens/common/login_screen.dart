import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_text_field.dart';
import '../../../../core/widgets/social_auth_button.dart';
import '../../../../core/widgets/pill_action_button.dart';

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
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
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

                    // --- REFACTORED ---
                    CustomTextField(
                      hintText: 'E-mail',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress, hint: '',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: _isPasswordObscure,
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
                      ), hint: '',
                    ),
                    // --- END REFACTOR ---

                    const SizedBox(height: 20),
                    _buildRememberAndForgotRow(),
                    const SizedBox(height: 30),

                    // --- REFACTORED ---
                    PillActionButton(
                      label: 'Sign in',
                      onPressed: () {
                        // TODO: Implement Sign In Logic

                      },
                    ),
                    // --- END REFACTOR ---

                    const SizedBox(height: 40),
                    _buildSeparator(),
                    const SizedBox(height: 20),
                    _buildSocialLoginRow(),
                    const SizedBox(height: 40),
                    _buildSignUpFooter(context),
                    const SizedBox(height: 20),
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

  Widget _buildSocialLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20.0,
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