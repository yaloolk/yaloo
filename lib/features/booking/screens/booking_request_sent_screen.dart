import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_primary_button.dart';

class BookingRequestSentScreen extends StatelessWidget {
  const BookingRequestSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String guideName = "Hadhi Ahamed";
    const String guideImage = "assets/images/guide_1.jpg";
    const String date = "Mon, Oct 25, 2025";
    const String time = "10:00 AM";
    const String total = "\$ 20.00";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                ),
                child: Icon(
                  FontAwesomeIcons.check,
                  color: AppColors.primaryBlue,
                  size: 48.w,
                ),
              ),
              SizedBox(height: 24.h),

              Text(
                'Booking Request Sent!',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineLargeBlack.copyWith(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),

              Text(
                'Your booking request has been sent to your selected guide. Payment is securely held and will only be charged once confirmed.',
                textAlign: TextAlign.center,
                style: AppTextStyles.textSmall.copyWith(
                  color: AppColors.primaryGray,
                  fontSize: 16.sp,
                  height: 1.5.h,
                ),
              ),
              SizedBox(height: 32.h),

              _buildBookingSummaryCard(guideName, guideImage, date, time, total),
              SizedBox(height: 34.h),

              CustomPrimaryButton(
                text: 'View Booking Details',
                onPressed: () {
                  Navigator.pushNamed(context, '/bookingStatus');
                },
              ),
              SizedBox(height: 16.h),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryRed,
                  minimumSize: Size(double.infinity, 52.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(
                      color: AppColors.secondaryGray,
                      width: 1.5.w,
                    ),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Cancel Request',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingSummaryCard(
      String name, String image, String date, String time, String total) {
    return Card(
      elevation: 6,
      shadowColor: AppColors.primaryGray.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundImage: AssetImage(image),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "GUIDE",
                      style: AppTextStyles.textExtraSmall.copyWith(
                        color: AppColors.primaryGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primaryBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: AppTextStyles.textSmall.copyWith(
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      time,
                      style: AppTextStyles.textSmall.copyWith(
                        color: AppColors.primaryGray,
                      ),
                    ),
                  ],
                ),
                Text(
                  total,
                  style: AppTextStyles.headlineLargeBlack.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.clock,
                    color: const Color(0xFFF59E0B),
                    size: 16.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Pending Confirmation',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: const Color(0xFFB45309),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
