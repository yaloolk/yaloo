// lib/features/guide/screens/guide_booking_cancellation_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/features/tourist/models/guide_booking_model.dart';
import 'package:yaloo/features/tourist/services/guide_booking_service.dart';

class GuideBookingCancellationScreen extends StatefulWidget {
  const GuideBookingCancellationScreen({super.key});
  @override
  State<GuideBookingCancellationScreen> createState() => _State();
}

class _State extends State<GuideBookingCancellationScreen> {
  final _service = GuideBookingService();

  final Map<String, bool> _reasons = {
    'Emergency / Personal reasons':    false,
    'Bad weather or unsafe conditions': false,
    'Overlapping schedule':             false,
    'Tourist-related issues':           false,
    'Health issues':                    false,
    'Payment issues':                   false,
    'Other (please specify)':           false,
  };

  final _otherCtrl = TextEditingController();
  bool _confirming = false;

  @override
  void dispose() {
    _otherCtrl.dispose();
    super.dispose();
  }

  bool get _hasReason => _reasons.values.contains(true);

  Future<void> _confirm(String bookingId) async {
    setState(() => _confirming = true);
    try {
      await _service.cancelBooking(bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Booking cancelled successfully',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
      ));
      // Pop all the way back to home tab
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString(),
              style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r)),
        ));
        setState(() => _confirming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    GuideBookingModel? booking;
    String touristName  = 'Tourist';
    String touristImage = '';
    String bookingId    = '';

    if (args is Map<String, dynamic>) {
      if (args['booking'] is GuideBookingModel) {
        booking      = args['booking'] as GuideBookingModel;
        touristName  = booking.touristName.isNotEmpty
            ? booking.touristName : 'Tourist';
        touristImage = booking.touristPhoto;
        bookingId    = booking.id;
      } else {
        // Legacy plain-map fallback
        touristName  = args['touristName'] ?? 'Tourist';
        touristImage = args['touristImage'] ?? '';
        bookingId    = args['bookingId'] ?? '';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Cancel Booking'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(children: [
            SizedBox(height: 24.h),
            _header(touristName, touristImage, booking),
            SizedBox(height: 32.h),
            _reasonForm(),
            SizedBox(height: 40.h),
            _buttons(context, bookingId),
            SizedBox(height: 40.h),
          ]),
        ),
      ),
    );
  }

  // ── Tourist header ────────────────────────────────────────────────────────
  Widget _header(String name, String imageUrl, GuideBookingModel? b) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircleAvatar(
            radius: 30.r,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            backgroundImage: imageUrl.isNotEmpty
                ? CachedNetworkImageProvider(imageUrl) : null,
            child: imageUrl.isEmpty
                ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 20.sp,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold)) : null),
        SizedBox(width: 16.w),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          if (b != null) ...[
            Text('${_fmtDate(b.bookingDate)} · '
                '${_fmtTime(b.startTime)} – ${_fmtTime(b.endTime)}',
                style: AppTextStyles.textSmall.copyWith(
                    color: AppColors.primaryGray)),
            SizedBox(height: 4.h),
          ],
          Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                  color: AppColors.secondaryGreen.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20.r)),
              child: Text(b?.bookingStatus ?? 'Confirmed',
                  style: AppTextStyles.textExtraSmall.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp))),
        ]),
      ]);

  // ── Reason form ───────────────────────────────────────────────────────────
  Widget _reasonForm() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Why are you cancelling?',
            style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
                fontSize: 18.sp)),
        SizedBox(height: 16.h),
        ..._reasons.keys.map((reason) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(children: [
              SizedBox(
                  height: 24.h, width: 24.w,
                  child: Checkbox(
                      value: _reasons[reason],
                      activeColor: AppColors.primaryBlue,
                      side: BorderSide(
                          color: AppColors.secondaryGray, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r)),
                      onChanged: (v) =>
                          setState(() => _reasons[reason] = v ?? false))),
              SizedBox(width: 12.w),
              Expanded(child: Text(reason,
                  style: AppTextStyles.textSmall.copyWith(
                      color: AppColors.primaryGray, fontSize: 14.sp))),
            ]))),

        if (_reasons['Other (please specify)'] == true) ...[
          SizedBox(height: 12.h),
          Container(
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.secondaryGray),
                  borderRadius: BorderRadius.circular(12.r)),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: TextField(
                  controller: _otherCtrl, maxLines: 3,
                  style: AppTextStyles.textSmall.copyWith(color: Colors.black),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Please provide more details…',
                      hintStyle: AppTextStyles.textSmall.copyWith(
                          color: AppColors.primaryGray.withOpacity(0.5))))),
        ],
      ]);

  // ── Action buttons ────────────────────────────────────────────────────────
  Widget _buttons(BuildContext context, String bookingId) => Row(children: [
    Expanded(child: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryGray,
            side: BorderSide(color: AppColors.secondaryGray),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r))),
        child: Text('Back to Booking',
            style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16.sp, fontWeight: FontWeight.bold,
                color: AppColors.primaryGray)))),
    SizedBox(width: 16.w),
    Expanded(child: ElevatedButton(
        onPressed: (_hasReason && !_confirming && bookingId.isNotEmpty)
            ? () => _confirm(bookingId) : null,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryRed,
            side: BorderSide(color: AppColors.primaryRed),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            elevation: 0),
        child: _confirming
            ? SizedBox(height: 20.h, width: 20.w,
            child: CircularProgressIndicator(
                color: AppColors.primaryRed, strokeWidth: 2))
            : Text('Confirm Cancel',
            style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 14.sp, fontWeight: FontWeight.bold,
                color: AppColors.primaryRed),
            textAlign: TextAlign.center))),
  ]);

  String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      const m = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    } catch (_) { return d; }
  }

  String _fmtTime(String t) {
    try {
      final p = t.split(':');
      int h = int.parse(p[0]);
      final min = p[1].padLeft(2, '0');
      final ap = h >= 12 ? 'PM' : 'AM';
      if (h == 0) h = 12; else if (h > 12) h -= 12;
      return '$h:$min $ap';
    } catch (_) { return t; }
  }
}