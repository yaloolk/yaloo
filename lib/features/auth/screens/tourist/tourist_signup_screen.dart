import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/social_auth_button.dart';
import '../../../../core/widgets/pill_action_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  bool _agreeToTerms = false;
  bool _canSignUp = false;
  bool _isLoading = false;

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
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _confirmPasswordController.removeListener(_validateForm);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    // Check if all fields are not empty and terms are agreed to
    final bool fieldsAreValid = _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;

    // We only set state if the value has changed to avoid unnecessary rebuilds
    if (_canSignUp != (fieldsAreValid && _agreeToTerms)) {
      setState(() {
        _canSignUp = fieldsAreValid && _agreeToTerms;
      });
    }
  }

  Future<void> _handleTouristSignUp() async {
    if (!_canSignUp) return;

    setState(() { _isLoading = true; });

    // --- MOCKUP: Simulate success ---
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _isLoading = false; });

    // UPDATED: Pass email AND role as arguments
    Navigator.pushReplacementNamed(
      context,
      '/verifyEmail',
      arguments: {
        'email': _emailController.text.trim(),
        'role': 'Tourist', // <-- Pass the role
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
                      'Let\'s Get Started!',
                      style: AppTextStyles.headlineLarge
                          .copyWith(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sign up with Social or fill the form to continue.',
                      style: AppTextStyles.textSmall
                          .copyWith(color: AppColors.primaryGray, fontSize: 16),
                    ),
                    const SizedBox(height: 40),

                    // --- REFACTORED ---
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'E-mail',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress, hint: '',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
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
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      icon: Icons.lock_outline,
                      obscureText: _isConfirmPasswordObscure,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: IconButton(
                          icon: Icon(
                            _isConfirmPasswordObscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.primaryGray,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordObscure =
                              !_isConfirmPasswordObscure;
                            });
                          },
                        ),
                      ), hint: '',
                    ),
                    // --- END REFACTOR ---

                    const SizedBox(height: 8),
                    Text(
                      'At least 8 characters, 1 uppercase letter, 1 number, 1 symbol',
                      style: AppTextStyles.textSmall
                          .copyWith(color: AppColors.primaryGray, fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    _buildTermsAndConditionsRow(),
                    const SizedBox(height: 30),

                    // --- REFACTORED ---
                    PillActionButton(
                      label: 'Sign Up',
                      onPressed: _canSignUp
                          ? () {
                        // TODO: Implement Sign Up Logic
                        Navigator.pushNamed(context, '/profileCompletion');
                      }
                          : null,
                    ),
                    // --- END REFACTOR ---

                    const SizedBox(height: 40),
                    _buildSeparator(),
                    const SizedBox(height: 20),
                    _buildSocialLoginRow(),
                    const SizedBox(height: 40),
                    _buildSignInFooter(context),
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

  Widget _buildTermsAndConditionsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24.0,
          width: 24.0,
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
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray, fontSize: 13),
              children: [
                const TextSpan(text: 'By Signing up, you agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: AppTextStyles.textSmall.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13
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
                      fontSize: 13
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