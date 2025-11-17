import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class GuideBookingDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const GuideBookingDetailsDialog({Key? key, required this.bookingData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Extract Data (with fallbacks) ---
    final String guestName = bookingData['guestName'] ?? 'Emil Carter';
    final String guestImage = bookingData['guestImage'] ?? 'https://placehold.co/100x100/e9c46a/white?text=Emil';
    final String status = bookingData['status'] ?? 'Confirmed';
    final String location = bookingData['location'] ?? 'Ella';
    final String dateTime = bookingData['dateTime'] ?? 'October 05, 10:00 A.M - 2:00 P.M';
    final String type = bookingData['type'] ?? 'Couple';
    final String meetingPoint = bookingData['meetingPoint'] ?? 'Ella Station';
    final String note = bookingData['note'] ?? "We'd love to see hike Ella mountain.";

    // Payment Data
    final String rateCalc = bookingData['rateCalc'] ?? '\$10 x 4h = \$40';
    final String fee = bookingData['fee'] ?? '-\$4';
    final String totalPayout = bookingData['totalPayout'] ?? '\$36';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Title ---
              Text(
                'Booking Details',
                style: AppTextStyles.headlineLargeBlack.copyWith(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),

              // --- Guest Profile ---
              Row(
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundImage: NetworkImage(guestImage),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guestName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      _buildStatusChip(status),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // --- Tour Details Section ---
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGray.withOpacity(0.1), // Light grey background
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tour Details',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildDetailRow(FontAwesomeIcons.locationDot, location),
                    _buildDetailRow(FontAwesomeIcons.calendar, dateTime),
                    _buildDetailRow(FontAwesomeIcons.userGroup, type),
                    _buildDetailRow(FontAwesomeIcons.clock, meetingPoint), // Icon matches UI
                    _buildDetailRow(FontAwesomeIcons.userPen, 'Special Note: "$note"'),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // --- Payment Summary Section ---
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGray.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Summary',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildPaymentRow("Rate/hour:", rateCalc),
                    _buildPaymentRow("Platform Fee (10%):", fee),
                    Divider(height: 20.h, color: AppColors.secondaryGray),
                    _buildPaymentRow("Total Payout:", totalPayout, isTotal: true),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // --- Action Buttons ---
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Handle Message Client
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056D2), // Dark Blue from UI
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        'Message Client',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Handle Cancel
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryRed,
                        side: BorderSide(color: AppColors.primaryRed),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        'Cancel Booking',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg = AppColors.secondaryGreen;
    Color text = AppColors.primaryGreen;

    if (status.toLowerCase() == 'pending') {
      bg = const Color(0xFFFFF8E1); // Yellow
      text = const Color(0xFFB45309);
    } else if (status.toLowerCase() == 'declined') {
      bg = AppColors.primaryRed.withOpacity(0.1);
      text = AppColors.primaryRed;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status,
        style: AppTextStyles.textExtraSmall.copyWith(
            color: text,
            fontWeight: FontWeight.bold,
            fontSize: 10.sp
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top for long notes
        children: [
          Icon(icon, size: 14.w, color: AppColors.primaryGray),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.textSmall.copyWith(
                  color: const Color(0xFF4A4A4A), // Darker gray
                  fontSize: 13.sp,
                  height: 1.4
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.textSmall.copyWith(
                color: isTotal ? const Color(0xFF0056D2) : AppColors.primaryGray,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 14.sp : 12.sp
            ),
          ),
          Text(
            value,
            style: AppTextStyles.textSmall.copyWith(
                color: isTotal ? const Color(0xFF0056D2) : AppColors.primaryBlack,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 14.sp : 12.sp
            ),
          ),
        ],
      ),
    );
  }
}