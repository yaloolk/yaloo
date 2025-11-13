import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class HostListCard extends StatelessWidget {
  final String name;
  final String location;
  final String rating;
  final String imageUrl;
  final int maxGuests;
  final Map<String, dynamic> hostData; // For passing data to next screen

  const HostListCard({
    super.key,
    required this.name,
    required this.location,
    required this.rating,
    required this.imageUrl,
    required this.maxGuests,
    required this.hostData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: AppColors.primaryGray.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      color: AppColors.primaryWhite,
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    imageUrl,
                    width: 100.w,
                    height: 100.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(width: 100.w, height: 100.h, color: AppColors.secondaryGray),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.headlineLargeBlack.copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      _buildInfoRow(FontAwesomeIcons.mapPin, location),
                      SizedBox(height: 6.h),
                      _buildInfoRow(FontAwesomeIcons.userGroup, 'Max $maxGuests'),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.solidStar, color: Colors.amber, size: 14.w),
                          SizedBox(width: 8.w),
                          Text(
                            rating,
                            style: AppTextStyles.textSmall.copyWith(
                                color: AppColors.primaryBlack,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Divider(color: AppColors.secondaryGray.withOpacity(0.7)),
            SizedBox(height: 8.h),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, size: 14.w, color: iconColor ?? AppColors.primaryGray),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            // TODO: Handle Favorite
          },
          icon: Icon(FontAwesomeIcons.heart, color: AppColors.primaryGray, size: 20.w),
          // style: IconButton.styleFrom(
          //     backgroundColor: AppColors.secondaryGray.withOpacity(0.5),
          //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))
          // ),
        ),
        SizedBox(width: 12.w),
        TextButton(
          onPressed: () {
            // TODO: Navigate to Host Profile
            Navigator.pushNamed(context, '/touristHostProfile', arguments: hostData);
          },
          child: Text(
            'Profile',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primaryGray,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        ElevatedButton(
          onPressed: () {
            // TODO: Navigate to Booking Details for Hosts
            Navigator.pushNamed(
              context,
              '/bookingDetails',
              arguments: { 'name': name, 'image': imageUrl, 'bookingType': 'host' }
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
          ),
          child: Text(
            'Reserve',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}