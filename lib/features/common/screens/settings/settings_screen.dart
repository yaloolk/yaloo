import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- State for Switches ---
  bool _pushNotifications = true;
  bool _emailAlerts = false;
  bool _tourUpdates = true;
  bool _twoFactorAuth = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Settings',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Account Settings ---
            _buildSectionTitle("Account Settings"),

            _buildSettingsTile(
              title: "Edit Profile",
              icon: FontAwesomeIcons.user,
              iconColor: const Color(0xFF0056D2),
              bgColor: const Color(0xFFEBF2FA),
              onTap: () {},
            ),
            _buildSettingsTile(
              title: "Change Password",
              icon: FontAwesomeIcons.lock,
              iconColor: const Color(0xFF0056D2),
              bgColor: const Color(0xFFEBF2FA),
              onTap: () {
                Navigator.pushNamed(context, '/changePassword');
              },
            ),
            _buildSettingsTile(
              title: "Payment Methods",
              icon: FontAwesomeIcons.creditCard,
              iconColor: const Color(0xFF0056D2),
              bgColor: const Color(0xFFEBF2FA),
              onTap: () {},
            ),
            _buildSettingsTile(
              title: "Language",
              icon: FontAwesomeIcons.globe,
              iconColor: const Color(0xFF0056D2),
              bgColor: const Color(0xFFEBF2FA),
              onTap: () {
                Navigator.pushNamed(context, '/language');
              },
            ),

            SizedBox(height: 24.h),

            // --- 2. Notification Settings ---
            _buildSectionTitle("Notification Settings"),

            _buildSettingsTile(
              title: "Push Notifications",
              icon: FontAwesomeIcons.bell,
              iconColor: const Color(0xFF9D174D),
              bgColor: const Color(0xFFFCE7F3),
              isSwitch: true,
              switchValue: _pushNotifications,
              onChanged: (val) => setState(() => _pushNotifications = val),
            ),
            _buildSettingsTile(
              title: "Email Alerts",
              icon: FontAwesomeIcons.envelope,
              iconColor: const Color(0xFF9D174D),
              bgColor: const Color(0xFFFCE7F3),
              isSwitch: true,
              switchValue: _emailAlerts,
              onChanged: (val) => setState(() => _emailAlerts = val),
            ),
            _buildSettingsTile(
              title: "Tour Updates & Offers",
              icon: FontAwesomeIcons.tag,
              iconColor: const Color(0xFF9D174D),
              bgColor: const Color(0xFFFCE7F3),
              isSwitch: true,
              switchValue: _tourUpdates,
              onChanged: (val) => setState(() => _tourUpdates = val),
            ),

            SizedBox(height: 24.h),

            // --- 3. Privacy & Security ---
            _buildSectionTitle("Privacy & Security"),

            _buildSettingsTile(
              title: "Two-Factor Authentication",
              icon: FontAwesomeIcons.shieldHalved,
              iconColor: const Color(0xFF0056D2),
              bgColor: const Color(0xFFEBF2FA),
              isSwitch: true,
              switchValue: _twoFactorAuth,
              onChanged: (val) => setState(() => _twoFactorAuth = val),
            ),
            _buildSettingsTile(
              title: "Visibility Control",
              icon: FontAwesomeIcons.eye,
              iconColor: const Color(0xFF0056D2),
              bgColor: const Color(0xFFEBF2FA),
              onTap: () {},
            ),
            _buildSettingsTile(
              title: "Login Activity",
              icon: FontAwesomeIcons.clockRotateLeft,
              iconColor: const Color(0xFF0056D2),
              bgColor: const Color(0xFFEBF2FA),
              onTap: () {},
            ),

            SizedBox(height: 24.h),

            // --- 4. Support & Help ---
            _buildSectionTitle("Support & Help"),

            _buildSettingsTile(
              title: "Help Center",
              icon: FontAwesomeIcons.circleQuestion,
              iconColor: const Color(0xFF9D174D),
              bgColor: const Color(0xFFFCE7F3),
              onTap: () {Navigator.pushNamed(context, '/helpSupport');},
            ),
            _buildSettingsTile(
              title: "Contact Support",
              icon: FontAwesomeIcons.headset,
              iconColor: const Color(0xFF9D174D),
              bgColor: const Color(0xFFFCE7F3),
              onTap: () {Navigator.pushNamed(context, '/contactSupport');},
            ),
            _buildSettingsTile(
              title: "Terms & Conditions",
              icon: FontAwesomeIcons.fileContract,
              iconColor: const Color(0xFF9D174D),
              bgColor: const Color(0xFFFCE7F3),
              onTap: () {},
            ),
            _buildSettingsTile(
              title: "Privacy Policy",
              icon: FontAwesomeIcons.shield,
              iconColor: const Color(0xFF9D174D),
              bgColor: const Color(0xFFFCE7F3),
              onTap: () {},
            ),

            SizedBox(height: 40.h),

            // --- 5. Logout Button ---
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryRed,
                side: BorderSide(color: AppColors.primaryRed),
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                "Log Out",
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // --- 6. Delete Account ---
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "Delete My Account",
                  style: AppTextStyles.textSmall.copyWith(
                    color: AppColors.primaryGray,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // SECTION TITLE WIDGET
  // -------------------------------
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
          color: const Color(0xFF111827),
        ),
      ),
    );
  }

  // -------------------------------
  // SETTINGS TILE WIDGET
  // -------------------------------
  Widget _buildSettingsTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    VoidCallback? onTap,
    bool isSwitch = false,
    bool switchValue = false,
    Function(bool)? onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: isSwitch ? null : onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Row(
          children: [
            // Icon Circle
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 18.w),
              ),
            ),
            SizedBox(width: 16.w),

            // Title text
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 15.sp,
                  color: const Color(0xFF374151),
                ),
              ),
            ),

            // Trailing: Switch or Arrow
            if (isSwitch)
              Switch(
                value: switchValue,
                onChanged: onChanged,
                activeColor: AppColors.primaryBlue,
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                color: const Color(0xFF9CA3AF),
                size: 16.w,
              ),
          ],
        ),
      ),
    );
  }
}
