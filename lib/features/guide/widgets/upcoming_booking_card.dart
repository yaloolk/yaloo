import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class UpcomingBookingCard extends StatelessWidget {
  final String title;
  final String location;
  final int guests;
  final String date;
  final String duration;
  final String price;
  final String imageUrl;

  const UpcomingBookingCard({
    super.key,
    required this.title,
    required this.location,
    required this.guests,
    required this.date,
    required this.duration,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Card height chosen to be slightly smaller than the parent ListView height (260.h)
    final cardHeight = 180.h;
    final imageHeight = 160.h;

    return Card(
      elevation: 6,
      shadowColor: AppColors.primaryGray.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(left: 24.w, right: 8.w, bottom: 12.h),
      child: SizedBox(
        width: 250.w,
        height: cardHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageHeader(imageHeight),
            _buildInfoBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(double height) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // Use Image.asset if your images are local assets, otherwise Image.network.
          // Keep a fallback via errorBuilder.
          Image.asset(
            imageUrl,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(height: height, color: AppColors.secondaryGray),
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
                  color: AppColors.primaryBlack,
                ),
              ),
            ),
          ),

          Positioned(
            top: 10.h,
            right: 10.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                duration,
                style: AppTextStyles.textSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBody() {
    return Expanded(
      // Expanded ensures the info body fills remaining space without pushing past parent.
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.headlineLargeBlack.copyWith(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10.h),

            // Details row (guests, location, price)
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.userGroup,
                  size: 13.sp,
                  color: AppColors.primaryGray,
                ),
                SizedBox(width: 6.w),
                Text(
                  '$guests Guests',
                  style: AppTextStyles.textSmall.copyWith(
                    color: AppColors.primaryGray,
                    fontSize: 12.sp,
                  ),
                ),

                SizedBox(width: 12.w),

                Icon(
                  FontAwesomeIcons.mapPin,
                  size: 13.sp,
                  color: AppColors.primaryGray,
                ),
                SizedBox(width: 6.w),

                // Location should shrink if space is tight
                Expanded(
                  child: Text(
                    location,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.textSmall.copyWith(
                      color: AppColors.primaryGray,
                      fontSize: 12.sp,
                    ),
                  ),
                ),

                SizedBox(width: 8.w),

                Text(
                  price,
                  style: AppTextStyles.headlineLargeBlack.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
