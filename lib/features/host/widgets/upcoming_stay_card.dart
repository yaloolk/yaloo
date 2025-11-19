import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class UpcomingStayCard extends StatelessWidget {
  final String title;
  final int guests;
  final String date;
  final String duration;
  final String price;
  final String imageUrl;
  final String checkInDate;

  const UpcomingStayCard({
    super.key,
    required this.title,
    required this.guests,
    required this.date,
    required this.duration,
    required this.price,
    required this.imageUrl,
    required this.checkInDate,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 6,
      shadowColor: AppColors.primaryGray.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(left: 24.w, right: 8.w, bottom: 12.h),
      child: SizedBox(
        width: 250.w,
        height: 240.h,
        child: Column(
          children: [
            // SECTION 1: IMAGE (Takes 60% of vertical space)
            Expanded(
              flex: 6,
              child: _buildImageHeader(),
            ),
            // SECTION 2: TEXT INFO (Takes 40% of vertical space)
            Expanded(
              flex: 4,
              child: _buildInfoBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(color: AppColors.secondaryGray),
        ),
        Positioned(
          top: 10.h,
          left: 10.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              date.toUpperCase(),
              style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                  color: AppColors.primaryBlack),
            ),
          ),
        ),
        Positioned(
          top: 10.h,
          right: 10.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              duration,
              style: AppTextStyles.textSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                  color: AppColors.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBody() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineLargeBlack.copyWith(
                    fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(FontAwesomeIcons.userGroup,
                    size: 12.sp, color: AppColors.primaryGray),
                SizedBox(width: 4.w),
                Text(
                  '$guests',
                  style: AppTextStyles.textSmall.copyWith(
                    color: AppColors.primaryGray,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Icon(FontAwesomeIcons.arrowRightToBracket,
                    size: 12.sp, color: AppColors.primaryGray),
                SizedBox(width: 4.w),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 80.w),
                  child: Text(
                    checkInDate,
                    style: AppTextStyles.textSmall
                        .copyWith(color: AppColors.primaryGray, fontSize: 12.sp),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),

                SizedBox(width: 40.w),
                Text(
                  price,
                  style: AppTextStyles.headlineLargeBlack.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}