import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class HostStayRequestDetails extends StatelessWidget {
  final Map<String, dynamic> data;

  const HostStayRequestDetails({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final guestName = data['guestName'] ?? 'Emil Carter';
    final guestImage = data['guestImage'] ?? 'https://placehold.co/100x100/4A8BDF/white?text=EC';
    final status = data['status'] ?? 'Confirmed';

    final stayDates = data['stayDates'] ?? 'October 05 - October 07 (2 Nights)';
    final family = data['family'] ?? '2 Adults, 1 Child';

    final checkIn = data['checkIn'] ?? '2:00 P.M';
    final checkOut = data['checkOut'] ?? '11:00 A.M';

    final meal = data['meal'] ?? 'Non-Veg';
    final note = data['note'] ?? 'We would love to learn about local traditions during stay';

    final rate = data['rate'] ?? '\$20 x 2 = \$40';
    final fee = data['fee'] ?? '-\$4';
    final total = data['total'] ?? '\$36';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Stay Details',
                style: AppTextStyles.headlineLargeBlack.copyWith(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
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
                      _statusChip(status),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.h),
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
                      'Stay Details',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _detailRow(FontAwesomeIcons.calendar, stayDates),
                    _detailRow(FontAwesomeIcons.userGroup, family),
                    _detailRow(FontAwesomeIcons.clock, 'Check in: $checkIn'),
                    _detailRow(FontAwesomeIcons.clock, 'Check out: $checkOut'),
                    _detailRow(FontAwesomeIcons.bowlFood, meal),
                    _detailRow(FontAwesomeIcons.pen, 'Special Note: "$note"'),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
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
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _paymentRow('Rate/night:', rate),
                    _paymentRow('Platform Fee (10%):', fee),
                    Divider(height: 20.h, color: AppColors.secondaryGray),
                    _paymentRow('Total Payout:', total, isTotal: true),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056D2),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Message Client',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(
                          context,
                          '/hostStayCancellation',
                          arguments: {
                            'guestName': guestName,
                            'guestImage': guestImage,
                          },
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryRed,
                        side: BorderSide(color: AppColors.primaryRed),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Cancel Stay',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _statusChip(String status) {
    Color bg = AppColors.secondaryGreen;
    Color text = AppColors.primaryGreen;

    if (status.toLowerCase() == 'pending') {
      bg = const Color(0xFFFFF8E1);
      text = const Color(0xFFB45309);
    }

    if (status.toLowerCase() == 'declined') {
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
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.w, color: AppColors.primaryGray),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.textSmall.copyWith(
                color: const Color(0xFF4A4A4A),
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(String label, String value, {bool isTotal = false}) {
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
              fontSize: isTotal ? 14.sp : 12.sp,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.textSmall.copyWith(
              color: isTotal ? const Color(0xFF0056D2) : AppColors.primaryBlack,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 14.sp : 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
