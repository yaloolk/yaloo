import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class ProfileListCard extends StatelessWidget {
  final String name;
  final String location;
  final String rating;
  final String imageUrl;

  const ProfileListCard({
    super.key,
    required this.name,
    required this.location,
    required this.rating,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w, // Wider than the guide card
      margin: EdgeInsets.only(left: 24.w, bottom: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        image: DecorationImage(
          image: imageUrl.startsWith('assets/')
              ? AssetImage(imageUrl) as ImageProvider
              : NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(50),
            blurRadius: 10.r,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dark gradient for text
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ),
            ),
          ),
          // Favorite Icon
          Positioned(
            top: 12.h,
            right: 12.w,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(FontAwesomeIcons.heart, color: Colors.white, size: 20.w),
            ),
          ),
          // Host Info
          Positioned(
            bottom: 16.h,
            left: 16.w,
            right: 16.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.mapPin, color: Colors.white, size: 12.w),
                    SizedBox(width: 4.w),
                    Text(
                      location,
                      style: AppTextStyles.textSmall.copyWith(color: Colors.white),
                    ),
                    const Spacer(),
                    Icon(FontAwesomeIcons.solidStar, color: Colors.amber, size: 12.w),
                    SizedBox(width: 4.w),
                    Text(
                      rating,
                      style: AppTextStyles.textSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}