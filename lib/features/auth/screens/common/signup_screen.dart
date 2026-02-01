// lib/features/auth/presentation/screens/signup_screen.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/social_auth_button.dart';
import '../../../../core/widgets/pill_action_button.dart';
import 'package:yaloo/core/storage/secure_storage.dart'; // ADD THIS

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final SecureStorage _secureStorage = SecureStorage(); // ADD THIS

  late final String selectedRole;

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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedRole = ModalRoute.of(context)!.settings.arguments as String;
  }

  void _validateForm() {
    final valid = _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _agreeToTerms &&
        _passwordController.text == _confirmPasswordController.text;

    if (_canSignUp != valid) {
      setState(() {
        _canSignUp = valid;
      });
    }
  }

  Future<void> _handleSignup() async {
    if (_isLoading) return;

    // Validate password strength
    final password = _passwordController.text.trim();
    if (!_isPasswordValid(password)) {
      _showError(
          'Password must be at least 8 characters with 1 uppercase, 1 number, and 1 symbol'
      );
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();

    try {
      print('🔐 Starting signup process...');
      print('Email: $email');
      print('Role: $selectedRole');

      // Create user in Supabase Auth with metadata
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': selectedRole, // This will be stored in user_metadata
        },
      );

      if (res.session != null) {
        final token = res.session!.accessToken;
        await _secureStorage.setAccessToken(token); // ADD THIS
        print('✅ Token saved after signup');
      }

      final user = res.user;
      if (user == null) {
        _showError('Signup failed - no user returned');
        return;
      }

      print('✅ Supabase user created: ${user.id}');
      print('User metadata: ${user.userMetadata}');

      // Create user_profile record in Supabase database
      try {
        await _createUserProfile(user.id, selectedRole);
        print('✅ User profile created in database');
      } catch (e) {
        print('⚠️ Profile creation error: $e');
        // Continue anyway - Django will create it on first login if needed
      }

      if (!mounted) return;
      _showSuccessDialog(email);

    } on AuthException catch (e) {
      print('❌ Auth Exception: ${e.message}');
      // Check if email already exists
      if (e.message.toLowerCase().contains('already')) {
        _showAccountExistsDialog();
      } else {
        _showError(e.message);
      }
    } catch (e) {
      print('❌ Unexpected error: $e');
      if (!mounted) return;
      _showError('Unexpected error occurred: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Create user profile in Supabase database
  Future<void> _createUserProfile(String authUserId, String role) async {
    try {
      // Check if profile already exists
      final existing = await Supabase.instance.client
          .from('user_profile')
          .select()
          .eq('auth_user_id', authUserId)
          .maybeSingle();

      if (existing != null) {
        print('Profile already exists');
        return;
      }

      // Create new profile
      await Supabase.instance.client.from('user_profile').insert({
        'auth_user_id': authUserId,
        'user_role': role,
        'profile_status': 'active',
        'is_complete': false,
      });

      print('User profile created successfully');
    } catch (e) {
      print('Error creating user profile: $e');
      // Don't throw - let it fail silently as Django will create it later
    }
  }

  /// Validate password strength
  bool _isPasswordValid(String password) {
    if (password.length < 8) return false;

    // Check for uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) return false;

    // Check for number
    if (!password.contains(RegExp(r'[0-9]'))) return false;

    // Check for special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;

    return true;
  }

  void _showSuccessDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Verify Your Email',
                style: AppTextStyles.headlineMedium,
              ),
            ),
          ],
        ),
        content: Text(
          'We\'ve sent a verification link to $email.\n\n'
              'Please check your inbox and click the link to verify your account before logging in.\n\n'
              '💡 Check your spam folder if you don\'t see it.',
          style: AppTextStyles.bodySmall,
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Go to Login',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showAccountExistsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 28.w),
            SizedBox(width: 12.w),
            Text('Account Exists', style: AppTextStyles.headlineMedium),
          ],
        ),
        content: Text(
          'This email is already registered. Would you like to log in instead?',
          style: AppTextStyles.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryGray,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Log In',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                Image.asset(_logoPath, width: 80.w, height: 80.h),
                SizedBox(height: 20.h),
                Text(
                  'Let\'s Get Started!',
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Sign up with Social or fill the form to continue.',
                  style: AppTextStyles.textSmall.copyWith(
                    color: AppColors.primaryGray,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 40.h),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'E-mail',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  hint: '',
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: _isPasswordObscure,
                  suffixIcon: IconButton(
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
                  hint: '',
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  icon: Icons.lock_outline,
                  obscureText: _isConfirmPasswordObscure,
                  suffixIcon: IconButton(
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
                  hint: '',
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16.w,
                      color: AppColors.primaryGray,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'At least 8 characters, 1 uppercase letter, 1 number, 1 symbol',
                        style: AppTextStyles.textSmall.copyWith(
                          color: AppColors.primaryGray,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildTermsAndConditionsRow(),
                SizedBox(height: 30.h),
                PillActionButton(
                  label: _isLoading ? 'Signing Up...' : 'Sign Up',
                  onPressed: _canSignUp && !_isLoading ? _handleSignup : null,
                ),
                SizedBox(height: 40.h),
                _buildSeparator(),
                SizedBox(height: 20.h),
                _buildSocialLoginRow(),
                SizedBox(height: 40.h),
                _buildSignInFooter(context),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsAndConditionsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (val) {
            setState(() => _agreeToTerms = val ?? false);
            _validateForm();
          },
          activeColor: AppColors.primaryBlue,
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
              children: [
                const TextSpan(text: 'By Signing up, you agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: AppTextStyles.textSmall.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // TODO: Navigate to Terms of Service
                      print('Navigate to Terms of Service');
                    },
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: AppTextStyles.textSmall.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // TODO: Navigate to Privacy Policy
                      print('Navigate to Privacy Policy');
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
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('Or sign up with'),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialAuthButton(
          iconPath: _googleIconPath,
          onPressed: () {
            _showError('Google signup coming soon!');
          },
        ),
        SizedBox(width: 20.w),
        SocialAuthButton(
          iconPath: _facebookIconPath,
          onPressed: () {
            _showError('Facebook signup coming soon!');
          },
        ),
        SizedBox(width: 20.w),
        SocialAuthButton(
          iconPath: _appleIconPath,
          onPressed: () {
            _showError('Apple signup coming soon!');
          },
        ),
      ],
    );
  }

  Widget _buildSignInFooter(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryGray),
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