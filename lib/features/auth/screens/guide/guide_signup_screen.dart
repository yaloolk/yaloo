import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

// This screen is for *Guide* signup. It only collects Email/Password.
class GuideSignupScreen extends StatefulWidget {
  const GuideSignupScreen({Key? key}) : super(key: key);

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
    // Pass the user's email to the verification screen
    Navigator.pushReplacementNamed(
      context,
      '/verifyEmail',
      arguments: _emailController.text.trim(),
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

                    // Welcome Text
                    Text(
                      'Become a Guide', // <-- UPDATED TITLE
                      style: AppTextStyles.headlineLarge
                          .copyWith(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Create your account to get started.', // <-- UPDATED SUBTITLE
                      style: AppTextStyles.textSmall
                          .copyWith(color: AppColors.primaryGray, fontSize: 16),
                    ),
                    const SizedBox(height: 40),

                    // Email Field
                    _buildEmailField(),
                    const SizedBox(height: 16),

                    // Password Field
                    _buildPasswordField(),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    _buildConfirmPasswordField(),
                    const SizedBox(height: 8),

                    // Password hint text
                    Text(
                      'At least 8 characters, 1 uppercase letter, 1 number, 1 symbol',
                      style: AppTextStyles.textSmall
                          .copyWith(color: AppColors.primaryGray, fontSize: 12),
                    ),
                    const SizedBox(height: 20),

                    // Terms and Conditions
                    _buildTermsAndConditionsRow(),
                    const SizedBox(height: 10),

                    // Show error message
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          _errorMessage,
                          style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryRed),
                        ),
                      ),

                    // Sign Up Button
                    _buildSignUpButton(),
                    const SizedBox(height: 40),

                    // Sign In Footer
                    _buildSignInFooter(context),
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
        controller: _emailController, // Attach controller
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
          contentPadding: EdgeInsets.only(top: 20.0, bottom: 20.0, right: 20.0),
        ),
      ),
    );
  }

  // Helper widget for Password field
  Widget _buildPasswordField() {
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
        controller: _passwordController, // Attach controller
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

  // Helper widget for Confirm Password field
  Widget _buildConfirmPasswordField() {
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
        controller: _confirmPasswordController, // Attach controller
        obscureText: _isConfirmPasswordObscure,
        decoration: InputDecoration(
          hintText: 'Confirm Password',
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
                left: 20.0, right: 16.0),
            child: Icon(Icons.lock_outline, color: AppColors.primaryGray),
          ),
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
                  _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
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

  // Helper widget for Terms and Conditions
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

  // Helper widget for Sign Up button
  Widget _buildSignUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            'Sign Up',
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 15),
        ElevatedButton(
          onPressed: _isLoading || !_canSignUp
              ? null // Setting onPressed to null disables the button
              : _handleGuideSignUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isLoading || !_canSignUp
              ? AppColors.primaryGray.withAlpha(100)
              : AppColors.primaryBlue,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color
            : Colors.white)
              : const Icon(Icons.arrow_forward, color: Colors.white, size:30),
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