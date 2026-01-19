import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  String? selectedIssue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Contact Support'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header text
            Text(
              "How can we help you?",
              style: AppTextStyles.textSmall.copyWith(
                color: AppColors.primaryBlack,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),

            // Issue type buttons grid
            Row(
              children: [
                Expanded(
                  child: _buildIssueCard(
                    icon: FontAwesomeIcons.mobile,
                    label: "Booking Issue",
                    issueType: "booking",
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildIssueCard(
                    icon: FontAwesomeIcons.creditCard,
                    label: "Payment Problem",
                    issueType: "payment",
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildIssueCard(
                    icon: FontAwesomeIcons.userCircle,
                    label: "Account Access",
                    issueType: "account",
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildIssueCard(
                    icon: FontAwesomeIcons.ellipsis,
                    label: "Other",
                    issueType: "other",
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),

            // Contact options
            _buildContactOption(
              icon: FontAwesomeIcons.comment,
              title: "Chat with us",
              subtitle: "Quickest response",
              onTap: () {
                // TODO: Navigate to chat screen
              },
            ),
            SizedBox(height: 12.h),
            _buildContactOption(
              icon: FontAwesomeIcons.envelope,
              title: "Email us",
              subtitle: "We'll reply within 24 hours",
              onTap: () {
                // TODO: Navigate to email screen or open email client
              },
            ),
            SizedBox(height: 12.h),
            _buildContactOption(
              icon: FontAwesomeIcons.phone,
              title: "Give us a call",
              subtitle: "Available Mon-Fri, 9am-5pm",
              onTap: () {
                // TODO: Make phone call
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueCard({
    required IconData icon,
    required String label,
    required String issueType,
  }) {
    final isSelected = selectedIssue == issueType;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIssue = issueType;
        });
      },
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primaryBlue,
                size: 24.w,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryBlack,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 20.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.primaryBlack,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.primaryGray,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryGray,
              size: 16.w,
            ),
          ],
        ),
      ),
    );
  }
}