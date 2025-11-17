import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class TourRequestCard extends StatelessWidget {
  final String touristName;
  final String touristImage;
  final String touristCountryCode;
  final String duration;
  final String price;
  final int guests;
  final String location;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const TourRequestCard({
    super.key,
    required this.touristName,
    required this.touristImage,
    required this.touristCountryCode,
    required this.duration,
    required this.price,
    required this.guests,
    required this.location,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: AppColors.primaryGray.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
      ),
      color: Colors.white,
      margin: EdgeInsets.only(left: 24.w, right: 8.w,  bottom: 6.h),
        child: InkWell(
          onTap: () {
            // Navigate to the details screen, passing the full request data
            Navigator.pushNamed(
              context,
              '/guideTourRequestDetails',
              // arguments: requestData,
            );
          },
          borderRadius: BorderRadius.circular(20.r),
        child: Container(
          width: 280.w,
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 14.h),
              _buildDetails(),
              SizedBox(height: 28.h),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundImage: AssetImage(touristImage),
        ),

        SizedBox(width: 10.w),

        Expanded(
          child: Text(
            touristName,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),

        SizedBox(width: 8.w),

        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Image.network(
            'https://flagcdn.com/w40/${touristCountryCode.toLowerCase()}.png',
            width: 22.w,
            height: 14.h,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 22.w,
                height: 14.h,
                color: Colors.grey,
                alignment: Alignment.center,
                child: Text(
                  touristCountryCode,
                  style: TextStyle(fontSize: 8.sp, color: Colors.white),
                ),
              );
            },
          ),
        ),

        SizedBox(width: 10.w),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: AppColors.secondaryGray.withOpacity(0.4),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            duration,
            style: AppTextStyles.textSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        SizedBox(width: 6.w),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: AppColors.secondaryGreen,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            price,
            style: AppTextStyles.textSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Row(
      children: [
        Icon(FontAwesomeIcons.userGroup, size: 13.w, color: AppColors.primaryGray),
        SizedBox(width: 6.w),
        Text(
          guests.toString(),
          style: AppTextStyles.textSmall.copyWith(
            color: AppColors.primaryBlack,
            fontSize: 12.sp,
          ),
        ),

        SizedBox(width: 14.w),

        Icon(FontAwesomeIcons.mapPin, size: 13.w, color: AppColors.primaryGray),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            location,
            style: AppTextStyles.textSmall.copyWith(
              color: AppColors.primaryBlack,
              fontSize: 12.sp,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.h),
            ),
            child: Text(
              'Accept',
              style: AppTextStyles.textSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),

        SizedBox(width: 10.w),

        Expanded(
          child: ElevatedButton(
            onPressed: onReject,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryGray.withOpacity(0.4),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.h),
            ),
            child: Text(
              'Reject',
              style: AppTextStyles.textSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGray,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
