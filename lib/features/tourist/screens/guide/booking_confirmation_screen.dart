// lib/features/tourist/screens/guide/booking_confirmation_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import '../../models/guide_booking_model.dart';

const _blue     = Color(0xFF2563EB);
const _blueDark = Color(0xFF1D4ED8);
const _bgPage   = Color(0xFFF8FAFC);
const _dark     = Color(0xFF1F2937);
const _gray     = Color(0xFF6B7280);
const _green    = Color(0xFF10B981);

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  String _fmt(String t) {
    try {
      final p = t.split(':');
      int h = int.parse(p[0]);
      final m = p[1];
      final ap = h >= 12 ? 'PM' : 'AM';
      if (h == 0) h = 12; else if (h > 12) h -= 12;
      return '$h:$m $ap';
    } catch (_) { return t; }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final GuideBookingModel? booking = args?['booking'] as GuideBookingModel?;

    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success animation container — matches home hero gradient
              Container(
                width: 120.w, height: 120.w,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_blue, _blueDark],
                        begin: Alignment.topLeft, end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                        color: _blue.withOpacity(0.38),
                        blurRadius: 32, offset: const Offset(0, 14),
                        spreadRadius: -6)]),
                child: Icon(CupertinoIcons.checkmark_circle_fill,
                    color: Colors.white, size: 60.w),
              ),
              SizedBox(height: 24.h),

              Text('Booking Sent!', style: TextStyle(
                  fontSize: 26.sp, fontWeight: FontWeight.w800, color: _dark)),
              SizedBox(height: 8.h),
              Text(
                  'Your booking request has been sent.\nThe guide will confirm shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _gray, fontSize: 14.sp, height: 1.5)),
              SizedBox(height: 30.h),

              // Booking detail card
              if (booking != null) ...[
                Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.045),
                          blurRadius: 16, offset: const Offset(0, 4))]),
                  child: Column(children: [
                    _row(CupertinoIcons.person_fill,
                        'Guide', booking.guideName.isNotEmpty
                            ? booking.guideName : 'Your Guide'),
                    _div(),
                    _row(CupertinoIcons.calendar,
                        'Date', booking.bookingDate.toString()),
                    _div(),
                    _row(CupertinoIcons.time,
                        'Time',
                        '${_fmt(booking.startTime.toString())} – '
                            '${_fmt(booking.endTime.toString())}'),
                    _div(),
                    _row(CupertinoIcons.money_dollar_circle,
                        'Total', 'LKR ${booking.totalAmount.toStringAsFixed(2)}'),
                    _div(),
                    _statusRow(booking.bookingStatus),
                  ]),
                ),
                SizedBox(height: 28.h),
              ],

              const Spacer(),

              // Buttons
              SizedBox(
                width: double.infinity, height: 52.h,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/myBookings', (_) => false),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r)),
                      elevation: 0),
                  child: Text('View My Bookings', style: TextStyle(
                      color: Colors.white, fontSize: 15.sp,
                      fontWeight: FontWeight.w700)),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity, height: 52.h,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/touristHome', (_) => false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _blue,
                    side: const BorderSide(color: _blue, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r)),
                  ),
                  child: Text('Back to Home', style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.w700)),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) =>
      Padding(padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(children: [
            Icon(icon, color: _blue, size: 16.w),
            SizedBox(width: 10.w),
            Text(label, style: TextStyle(color: _gray, fontSize: 12.sp)),
            const Spacer(),
            Text(value, style: TextStyle(
                color: _dark, fontSize: 13.sp, fontWeight: FontWeight.w700)),
          ]));

  Widget _div() => Divider(color: Colors.grey.shade100, height: 14.h);

  Widget _statusRow(String status) => Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Row(children: [
      Icon(CupertinoIcons.info_circle, color: _blue, size: 16.w),
      SizedBox(width: 10.w),
      Text('Status', style: TextStyle(color: _gray, fontSize: 12.sp)),
      const Spacer(),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
            color: _statusColor(status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: _statusColor(status).withOpacity(0.4))),
        child: Text(status.toUpperCase(), style: TextStyle(
            color: _statusColor(status), fontSize: 11.sp,
            fontWeight: FontWeight.w800)),
      ),
    ]),
  );

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed':  return _green;
      case 'rejected':   return Colors.red;
      case 'cancelled':  return Colors.orange;
      default:           return _blue;
    }
  }
}