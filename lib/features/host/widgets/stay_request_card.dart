import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class StayRequestCard extends StatelessWidget {
  final String touristName;
  final String touristImage;
  final String touristCountryCode;
  final String duration;
  final String price;
  final int guests;
  final int rooms;
  final String date;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const StayRequestCard({
    super.key,
    required this.touristName,
    required this.touristImage,
    required this.touristCountryCode,
    required this.duration,
    required this.price,
    required this.guests,
    required this.rooms,
    required this.date,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: AppColors.primaryGray.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      color: Colors.white,
      margin: EdgeInsets.only(left: 24.w, right: 8.w, bottom: 8.h),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/hostStayRequestDetails',
          );
        },
        borderRadius: BorderRadius.circular(18.r),
        child: SizedBox(
          child: Padding(
            padding: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
                top: 13.h,
                bottom: 6.h // <--- Reduced bottom padding here
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 24.h),
                  _buildDetails(),
                  SizedBox(height: 24.h),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22.r,
          backgroundImage: AssetImage(touristImage),
          // Added fallback background in case image fails to load
          backgroundColor: AppColors.secondaryGray,
        ),
        SizedBox(width: 10.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Name + Flag
              Row(
                children: [
                  Flexible(
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
                  SizedBox(width: 6.w),
                  _buildFlag(),
                ],
              ),
              SizedBox(height: 4.h),
              // Bottom Row: Duration + Price
              Row(
                children: [
                  _buildBadge(duration, AppColors.thirdBlue, AppColors.primaryBlue),
                  SizedBox(width: 6.w),
                  _buildBadge(price, AppColors.secondaryGreen, AppColors.primaryGreen),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlag() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.r),
      child: Image.network(
        'https://flagcdn.com/w40/${touristCountryCode.toLowerCase()}.png',
        width: 20.w,
        height: 13.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 20.w,
          height: 13.h,
          color: Colors.grey.shade300,
          child: Icon(Icons.flag, size: 10.sp, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: AppTextStyles.textSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: fg,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Row(
      children: [
        _buildDetailItem(FontAwesomeIcons.userGroup, '$guests'),
        SizedBox(width: 16.w),
        _buildDetailItem(FontAwesomeIcons.bed, '$rooms'),
        SizedBox(width: 26.w),
        Flexible(
          child: Text(
            date,
            style: AppTextStyles.textSmall.copyWith(
                color: AppColors.primaryBlack,
                fontSize: 12.sp
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.w, color: AppColors.primaryGray),
        SizedBox(width: 6.w),
        Text(
          text,
          style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryBlack),
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