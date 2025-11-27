import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';

import '../../../core/widgets/custom_icon_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'My Profile',
        actions: [
          CustomIconButton(
            onPressed: () { /* TODO: Settings */ },
            icon: Icon(CupertinoIcons.gear, color: AppColors.primaryBlack, size: 24.w),
          ),
          SizedBox(width: 12.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),

            // --- 1. Profile Header ---
            _buildProfileHeader(),
            SizedBox(height: 24.h),

            // --- 2. Stats Grid ---
            _buildStatsGrid(),
            SizedBox(height: 32.h),

            // --- 3. About Me ---
            _buildSectionHeader('About Me', onEdit: () {}),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB), // Very light gray
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                "Passionate explorer with a love for hidden gems and local cuisine. Always on the lookout for the next adventure, whether it's hiking a mountain or wandering through a historic city. Let's share stories!",
                style: AppTextStyles.textSmall.copyWith(
                    color: AppColors.primaryGray,
                    height: 1.5,
                    fontSize: 14.sp
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // --- 4. Gallery ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gallery',
                style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16.h),
            _buildGalleryGrid(),
            SizedBox(height: 16.h),
            _buildUploadButton(),
            SizedBox(height: 32.h),

            // --- 5. Personal Information ---
            _buildSectionHeader('Personal Information', onEdit: () {
              Navigator.pushNamed(context, '/personalInformation');
            }),
            SizedBox(height: 12.h),
            _buildPersonalInfoList(),
            SizedBox(height: 32.h),

            // --- 6. Travel Preferences ---
            _buildSectionHeader('Travel Preferences', onEdit: () {}),
            SizedBox(height: 12.h),
            _buildPreferencesWrap(),
            SizedBox(height: 32.h),

            // --- 7. Menu Items ---
            _buildMenuItem(CupertinoIcons.heart, "Saved", () {}),
            SizedBox(height: 12.h),
            _buildMenuItem(CupertinoIcons.question_circle, "Help & Support", () {}),

            SizedBox(height: 100.h), // Bottom padding
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: CircleAvatar(
            radius: 50.r,
            backgroundImage: const NetworkImage('https://placehold.co/200x200/png?text=Cora'), // Replace with asset
            // backgroundImage: AssetImage('assets/images/profile_pic.png'),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Cora Hayes',
          style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("United States", "assets/icons/flag_us.png", isIcon: false), // Use flag asset
              _buildStatItem("Member since 2022", FontAwesomeIcons.calendar),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("12 Trips Completed", FontAwesomeIcons.suitcase),
              _buildStatItem("English, Spanish", FontAwesomeIcons.language),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String text, dynamic iconOrAsset, {bool isIcon = true}) {
    return Expanded(
      child: Row(
        children: [
          isIcon
              ? Icon(iconOrAsset as IconData, size: 16.w, color: AppColors.primaryGray)
              : Icon(FontAwesomeIcons.flag, size: 16.w, color: AppColors.primaryGray), // Fallback if no flag asset
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray, fontSize: 13.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onEdit}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: onEdit,
          icon: Icon(FontAwesomeIcons.pen, size: 16.w, color: AppColors.primaryBlue),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildGalleryGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1,
      ),
      itemCount: 6, // 6 placeholders
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Center(
            child: Icon(CupertinoIcons.photo, color: Colors.grey.shade300, size: 24.w),
          ),
        );
      },
    );
  }

  Widget _buildUploadButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF3F8FF), // Very light blue
        foregroundColor: const Color(0xFF1F2937), // Dark gray text
        elevation: 0,
        minimumSize: Size(double.infinity, 52.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.photo_camera, size: 20.w, color: const Color(0xFF1F2937)),
          SizedBox(width: 8.w),
          Text(
            'Upload Photo',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoList() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildInfoRow(CupertinoIcons.mail, "cora***@email.com"),
          SizedBox(height: 16.h),
          _buildInfoRow(CupertinoIcons.phone, "+1 (***) ***-1234"),
          SizedBox(height: 16.h),
          _buildInfoRow(CupertinoIcons.globe, "United States"),
          SizedBox(height: 16.h),
          _buildInfoRow(CupertinoIcons.calendar, "October 26"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6B7280), size: 20.w),
        SizedBox(width: 16.w),
        Text(
          text,
          style: TextStyle(
            color: const Color(0xFF374151),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesWrap() {
    final List<String> prefs = ["Adventure", "Relaxation", "Culture", "Family Friendly"];
    final List<Color> colors = [
      const Color(0xFFBFDBFE), // Blue
      const Color(0xFFDDD6FE), // Purple
      const Color(0xFFBAE6FD), // Sky
      const Color(0xFFFED7AA), // Orange
    ]; // Just example colors, better to use consistent app colors

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: List.generate(prefs.length, (index) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE), // Using a standard light blue for all based on UI
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            prefs[index],
            style: TextStyle(
              color: const Color(0xFF0284C7),
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF4B5563), size: 22.w),
        title: Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: const Color(0xFF1F2937))
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16.w, color: const Color(0xFF9CA3AF)),
      ),
    );
  }
}