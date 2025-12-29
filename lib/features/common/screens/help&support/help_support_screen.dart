import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Help and Support'),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            // --- Search Bar ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r), // Fully rounded like UI
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'What can we help you with?',
                  hintStyle: TextStyle(color: AppColors.primaryGray),
                  prefixIcon: Icon(Icons.search, color: AppColors.primaryGray, size: 24.w),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // --- Grid of Cards ---
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 0.85, // Taller cards
                children: [
                  _buildSupportCard(
                    title: "FAQs",
                    icon: FontAwesomeIcons.circleQuestion,
                    iconColor: const Color(0xFF0056D2), // Blue
                    bgColor: const Color(0xFFEBF2FA),
                    onTap: () { Navigator.pushNamed(context, '/faqs'); },
                  ),
                  _buildSupportCard(
                    title: "Tutorials",
                    icon: FontAwesomeIcons.graduationCap,
                    iconColor: const Color(0xFF0056D2),
                    bgColor: const Color(0xFFEBF2FA),
                    onTap: () {},
                  ),
                  _buildSupportCard(
                    title: "Troubleshooting",
                    icon: FontAwesomeIcons.wrench,
                    iconColor: const Color(0xFF0056D2),
                    bgColor: const Color(0xFFEBF2FA),
                    onTap: () {},
                  ),
                  _buildSupportCard(
                    title: "Contact Support",
                    icon: FontAwesomeIcons.headset,
                    iconColor: const Color(0xFF9D174D), // Pinkish
                    bgColor: const Color(0xFFFCE7F3),
                    onTap: () {Navigator.pushNamed(context, '/contactSupport');},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28.w),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }
}