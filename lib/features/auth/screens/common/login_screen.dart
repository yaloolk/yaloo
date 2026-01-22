import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_text_field.dart';
import 'package:yaloo/core/widgets/social_auth_button.dart';
import 'package:yaloo/core/widgets/pill_action_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordObscure = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String _logoPath = 'assets/images/yaloo_logo.png';
  final String _googleIconPath = 'assets/icons/google.png';
  final String _facebookIconPath = 'assets/icons/facebook.png';
  final String _appleIconPath = 'assets/icons/apple.png';

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Email and password required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Supabase sign in
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        _showError('Invalid login credentials.');
        return;
      }

      // Check if email is verified
      if (user.emailConfirmedAt == null) {
        _showError('Please verify your email before logging in.');
        return;
      }

      // Fetch user profile to get role
      final profileRes = await Supabase.instance.client
          .from('user_profile')
          .select('user_role')
          .eq('auth_user_id', user.id)
          .single();

      final user_role = profileRes['user_role'] as String?;

      if (user_role == null) {
        _showError('User role not found.');
        return;
      }

      // Navigate based on role
      if (user_role.toLowerCase() == 'tourist') {
        Navigator.pushReplacementNamed(context, '/profileCompletion');
      } else if (user_role.toLowerCase() == 'guide') {
        Navigator.pushReplacementNamed(context, '/guideProfileCompletion');
      } else if (user_role.toLowerCase() == 'host') {
        Navigator.pushReplacementNamed(context, '/hostProfileCompletion');
      } else {
        _showError('Unknown user role.');
      }
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (e) {
      _showError('Unexpected error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  _logoPath,
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome Back!',
                  style: AppTextStyles.headlineLarge
                      .copyWith(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Sign in to continue to your account.',
                  style: AppTextStyles.textSmall.copyWith(
                      color: AppColors.primaryGray, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // Email
                CustomTextField(
                  controller: _emailController,
                  hintText: 'E-mail',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  hint: '',
                ),
                const SizedBox(height: 16),

                // Password
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
                const SizedBox(height: 20),

                // Login Button
                PillActionButton(
                  label: _isLoading ? 'Logging In...' : 'Login',
                  onPressed: _isLoading ? null : _login,
                ),

                const SizedBox(height: 40),

                // Social Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialAuthButton(
                      iconPath: _googleIconPath,
                      onPressed: () {}, // TODO: Google login
                    ),
                    const SizedBox(width: 20),
                    SocialAuthButton(
                      iconPath: _facebookIconPath,
                      onPressed: () {}, // TODO: Facebook login
                    ),
                    const SizedBox(width: 20),
                    SocialAuthButton(
                      iconPath: _appleIconPath,
                      onPressed: () {}, // TODO: Apple login
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Footer
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/userSelection');
                    },
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: AppTextStyles.textSmall.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
