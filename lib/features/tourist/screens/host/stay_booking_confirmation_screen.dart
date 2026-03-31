// lib/features/tourist/screens/host/stay_booking_confirmation_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/features/tourist/models/stay_booking_model.dart';

const _blue       = Color(0xFF2563EB);
const _blueDark   = Color(0xFF1D4ED8);
const _blueDarker = Color(0xFF1E40AF);
const _bg         = Color(0xFFF8FAFC);
const _dark       = Color(0xFF1F2937);
const _gray       = Color(0xFF6B7280);
const _green      = Color(0xFF10B981);
const _amber      = Color(0xFFF59E0B);
const _red        = Color(0xFFEF4444);

// ─────────────────────────────────────────────────────────────────────────────
// STEP 6 — Booking Confirmation (request sent to host)
// ─────────────────────────────────────────────────────────────────────────────
class StayBookingConfirmationScreen extends StatelessWidget {
  const StayBookingConfirmationScreen({super.key});

  String _fd(String d) {
    try {
      final dt = DateTime.parse(d);
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month-1]} ${dt.year}';
    } catch (_) { return d; }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final StayBookingModel? b = args is Map<String, dynamic>
        ? StayBookingModel.fromJson(args) : args as StayBookingModel?;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(children: [
          const Spacer(),
          // ── Success icon ──────────────────────────────────────────
          Container(
            width: 120.w, height: 120.w,
            decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_blue, _blueDark, _blueDarker],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: _blue.withOpacity(0.38), blurRadius: 32,
                    offset: const Offset(0, 14), spreadRadius: -6)]),
            child: Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.white, size: 60.w),
          ),
          SizedBox(height: 24.h),
          Text('Request Sent!', style: TextStyle(fontSize: 26.sp,
              fontWeight: FontWeight.w800, color: _dark, letterSpacing: -0.5)),
          SizedBox(height: 8.h),
          Text('Your booking request has been sent to the host.\nYou\'ll be notified when they respond.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _gray, fontSize: 14.sp, height: 1.5)),
          SizedBox(height: 30.h),

          // ── Booking detail card ────────────────────────────────────
          if (b != null) Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24.r),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))]),
            child: Column(children: [
              _row(CupertinoIcons.house_fill, 'Stay', b.stayName.isNotEmpty ? b.stayName : 'Your Stay'),
              _div(),
              _row(CupertinoIcons.calendar, 'Check-in', _fd(b.checkinDate)),
              _div(),
              _row(CupertinoIcons.calendar, 'Check-out', _fd(b.checkoutDate)),
              _div(),
              _row(CupertinoIcons.moon_stars_fill, 'Nights', '${b.totalNights}'),
              _div(),
              _row(CupertinoIcons.money_dollar_circle, 'Total', 'LKR ${b.totalAmount.toStringAsFixed(0)}'),
              _div(),
              Row(children: [
                Icon(CupertinoIcons.info_circle, color: _blue, size: 16.w),
                SizedBox(width: 10.w),
                Text('Status', style: TextStyle(color: _gray, fontSize: 12.sp)),
                const Spacer(),
                Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(color: _amber.withOpacity(0.12), borderRadius: BorderRadius.circular(12.r)),
                    child: Text('PENDING', style: TextStyle(color: _amber, fontSize: 11.sp, fontWeight: FontWeight.w800))),
              ]),
            ]),
          ),
          const Spacer(),

          // ── Buttons ────────────────────────────────────────────────
          SizedBox(width: double.infinity, height: 52.h, child: ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/myStayBookings', (_) => false),
            style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white,
                elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r))),
            child: Text('View My Bookings', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
          )),
          SizedBox(height: 12.h),
          SizedBox(width: double.infinity, height: 52.h, child: OutlinedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/touristDashboard', (_) => false),
            style: OutlinedButton.styleFrom(foregroundColor: _blue,
                side: const BorderSide(color: _blue, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r))),
            child: Text('Back to Home', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
          )),
          SizedBox(height: 24.h),
        ]),
      )),
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Row(children: [
      Icon(icon, color: _blue, size: 16.w), SizedBox(width: 10.w),
      Text(label, style: TextStyle(color: _gray, fontSize: 12.sp)),
      const Spacer(),
      Text(value, style: TextStyle(color: _dark, fontSize: 13.sp, fontWeight: FontWeight.w700)),
    ]),
  );
  Widget _div() => Divider(color: Colors.grey.shade100, height: 14.h);
}