import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'About Yaloo'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Hero Banner ───────────────────────────────────────────────
            _HeroBanner(),

            // ─── Body Content ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Version Chip
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF2FA),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "Version 1.0.0",
                        style: AppTextStyles.textSmall.copyWith(
                          color: const Color(0xFF0056D2),
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // Mission Section
                  _buildSectionTitle("Our Mission"),
                  SizedBox(height: 8.h),
                  Text(
                    "Yaloo is your all-in-one travel companion - built to make every journey seamless, memorable, and stress-free. "
                        "We connect travelers with the best tours, guides, and experiences around the world, putting the joy of exploration back in your hands.",
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: 14.sp,
                      height: 1.65,
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // Feature Highlights
                  _buildSectionTitle("What We Offer"),
                  SizedBox(height: 12.h),
                  _buildFeatureRow(
                    icon: FontAwesomeIcons.mapLocationDot,
                    iconColor: const Color(0xFF0056D2),
                    bgColor: const Color(0xFFEBF2FA),
                    title: "Curated Tours",
                    subtitle: "Handpicked experiences for every type of traveler.",
                  ),
                  _buildFeatureRow(
                    icon: FontAwesomeIcons.star,
                    iconColor: const Color(0xFF9D174D),
                    bgColor: const Color(0xFFFCE7F3),
                    title: "Verified Reviews",
                    subtitle: "Honest ratings from real travelers like you.",
                  ),
                  _buildFeatureRow(
                    icon: FontAwesomeIcons.headset,
                    iconColor: const Color(0xFF0056D2),
                    bgColor: const Color(0xFFEBF2FA),
                    title: "24/7 Support",
                    subtitle: "Our team is always here whenever you need help.",
                  ),
                  _buildFeatureRow(
                    icon: FontAwesomeIcons.shieldHalved,
                    iconColor: const Color(0xFF9D174D),
                    bgColor: const Color(0xFFFCE7F3),
                    title: "Secure Payments",
                    subtitle: "Your bookings and data are always protected.",
                  ),

                  SizedBox(height: 28.h),

                  // Connect Section
                  _buildSectionTitle("Connect With Us"),
                  SizedBox(height: 12.h),
                  _buildLinkTile(
                    icon: FontAwesomeIcons.earthAmericas,
                    iconColor: const Color(0xFF0056D2),
                    bgColor: const Color(0xFFEBF2FA),
                    label: "Visit our Website",
                    value: "www.yaloo.lk",
                    onTap: () {},
                  ),
                  _buildLinkTile(
                    icon: FontAwesomeIcons.envelope,
                    iconColor: const Color(0xFF9D174D),
                    bgColor: const Color(0xFFFCE7F3),
                    label: "Email Us",
                    value: "yalooteam@gmail.com",
                    onTap: () {},
                  ),
                  _buildLinkTile(
                    icon: FontAwesomeIcons.instagram,
                    iconColor: const Color(0xFF9D174D),
                    bgColor: const Color(0xFFFCE7F3),
                    label: "Instagram",
                    value: "@yaloo.lk",
                    onTap: () {},
                  ),
                  _buildLinkTile(
                    icon: FontAwesomeIcons.facebook,
                    iconColor: const Color(0xFF0056D2),
                    bgColor: const Color(0xFFEBF2FA),
                    label: "Facebook",
                    value: "Yaloo",
                    onTap: () {},
                  ),

                  SizedBox(height: 28.h),

                  // Legal Links
                  _buildSectionTitle("Legal"),
                  SizedBox(height: 12.h),
                  _buildLegalRow(
                    label: "Terms & Conditions",
                    onTap: () {},
                  ),
                  _buildLegalRow(
                    label: "Privacy Policy",
                    onTap: () {},
                  ),

                  SizedBox(height: 36.h),

                  // Copyright
                  Center(
                    child: Text(
                      "© 2026 Yaloo. All rights reserved.",
                      style: AppTextStyles.textSmall.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Hero Banner ────────────────────────────────────────────────────────────
  Widget _HeroBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 36.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0056D2), Color(0xFF003A8C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // App Icon placeholder
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                FontAwesomeIcons.mapLocationDot,
                color: const Color(0xFF0056D2),
                size: 36.w,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "Yaloo",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "Explore. Discover. Travel.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13.sp,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Title ───────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyLarge.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 16.sp,
        color: const Color(0xFF111827),
      ),
    );
  }

  // ─── Feature Row ─────────────────────────────────────────────────────────────
  Widget _buildFeatureRow({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Center(child: Icon(icon, color: iconColor, size: 18.w)),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: AppTextStyles.textSmall.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Link Tile ───────────────────────────────────────────────────────────────
  Widget _buildLinkTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Center(child: Icon(icon, color: iconColor, size: 18.w)),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  Text(
                    value,
                    style: AppTextStyles.textSmall.copyWith(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF9CA3AF),
              size: 14.w,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Legal Row ───────────────────────────────────────────────────────────────
  Widget _buildLegalRow({
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 14.sp,
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF9CA3AF),
              size: 14.w,
            ),
          ],
        ),
      ),
    );
  }
}