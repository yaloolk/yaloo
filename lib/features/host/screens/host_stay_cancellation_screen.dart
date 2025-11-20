import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';

class HostStayCancellationScreen extends StatefulWidget {
  const HostStayCancellationScreen({super.key});

  @override
  State<HostStayCancellationScreen> createState() =>
      _HostStayCancellationScreenState();
}

class _HostStayCancellationScreenState
    extends State<HostStayCancellationScreen> {
  // --- State for Checkboxes ---
  final Map<String, bool> _cancellationReasons = {
    'Emergency / Personal reasons': false,
    'Bad weather or unsafe conditions': false,
    'Overlapping schedule': false,
    'Tourist-related issues': false,
    'Health issues': false,
    'Payment issues': false,
    'Other (please specify)': false,
  };

  final TextEditingController _otherReasonController = TextEditingController();
  bool _isConfirming = false;

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- Receive booking data ---
    final bookingData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};
    final String touristName = bookingData['touristName'] ?? 'Emil Carter';
    final String touristImage =
        bookingData['touristImage'] ?? 'https://placehold.co/100x100/e9c46a/white?text=Emil';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Booking Cancel'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 24.h),
              _buildBookingHeader(touristName, touristImage),
              SizedBox(height: 32.h),
              _buildReasonForm(),
              SizedBox(height: 40.h),
              _buildActionButtons(context),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingHeader(String name, String image) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30.r,
          backgroundImage: NetworkImage(image),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: AppTextStyles.headlineLargeBlack.copyWith(
                  fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.secondaryGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Confirmed',
                style: AppTextStyles.textExtraSmall.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReasonForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why are you Cancelling?',
          style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937), // Dark gray
              fontSize: 18.sp),
        ),
        SizedBox(height: 16.h),
        ..._cancellationReasons.keys.map((reason) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                SizedBox(
                  height: 24.h,
                  width: 24.w,
                  child: Checkbox(
                    value: _cancellationReasons[reason],
                    activeColor: AppColors.primaryBlue,
                    side: BorderSide(color: AppColors.secondaryGray, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r)),
                    onChanged: (bool? value) {
                      setState(() {
                        _cancellationReasons[reason] = value ?? false;
                      });
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  reason,
                  style: AppTextStyles.textSmall.copyWith(
                      color: AppColors.primaryGray, fontSize: 14.sp),
                ),
              ],
            ),
          );
        }).toList(),

        // Show text area only if "Other" is checked (optional, but good UX)
        if (_cancellationReasons['Other (please specify)'] == true) ...[
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.secondaryGray),
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              controller: _otherReasonController,
              maxLines: 3,
              style: AppTextStyles.textSmall.copyWith(color: Colors.black),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Please provide more details...',
                hintStyle: AppTextStyles.textSmall
                    .copyWith(color: AppColors.primaryGray.withOpacity(0.5)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Check if at least one reason is selected
    bool isReasonSelected = _cancellationReasons.values.contains(true);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryGray,
              side: BorderSide(color: AppColors.secondaryGray),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(
              'Back to Booking',
              style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGray),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton(
            onPressed: (isReasonSelected && !_isConfirming)
                ? () {
              setState(() => _isConfirming = true);
              // TODO: Handle Cancellation Logic (API Call)
              Future.delayed(const Duration(seconds: 2), () {
                // After success, go back to home or bookings
                Navigator.of(context).popUntil((route) => route.isFirst);
              });
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryRed,
              side: BorderSide(color: AppColors.primaryRed), // Red border
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              elevation: 0,
            ),
            child: _isConfirming
                ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: CircularProgressIndicator(
                    color: AppColors.primaryRed, strokeWidth: 2))
                : Text(
              'Confirm Cancelation',
              style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 14.sp, // Slightly smaller to fit text
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRed),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}