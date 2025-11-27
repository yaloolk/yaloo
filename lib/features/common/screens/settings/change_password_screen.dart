import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/custom_primary_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // --- Controllers ---
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // --- State for Visibility Toggles ---
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePassword() {
    // 1. Basic Validation
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New passwords do not match")),
      );
      return;
    }

    // 2. TODO: Call API to update password

    // 3. Success Mockup
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password updated successfully!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Change Password',
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            // --- Current Password ---
            _buildPasswordField(
              label: "Current Password",
              hint: "••••••••••••",
              controller: _currentPasswordController,
              isObscure: _obscureCurrent,
              onToggleVisibility: () {
                setState(() {
                  _obscureCurrent = !_obscureCurrent;
                });
              },
            ),
            SizedBox(height: 24.h),

            // --- New Password ---
            _buildPasswordField(
              label: "New Password",
              hint: "Enter new password",
              controller: _newPasswordController,
              isObscure: _obscureNew,
              onToggleVisibility: () {
                setState(() {
                  _obscureNew = !_obscureNew;
                });
              },
            ),
            SizedBox(height: 24.h),

            // --- Confirm New Password ---
            _buildPasswordField(
              label: "Confirm New Password",
              hint: "Confirm your new password",
              controller: _confirmPasswordController,
              isObscure: _obscureConfirm,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirm = !_obscureConfirm;
                });
              },
            ),

            const Spacer(),

            // --- Update Button ---
            CustomPrimaryButton(
              text: "Update Password",
              onPressed: _updatePassword,
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.textSmall.copyWith(
            color: AppColors.primaryGray, // Gray label as per UI
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: Colors.black, // Dark text input
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.normal,
            ),
            // Eye Icon
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                color: AppColors.primaryGray,
                size: 18.w,
              ),
              onPressed: onToggleVisibility,
            ),
            // Underline Border Style
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryBlue),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          ),
        ),
      ],
    );
  }
}