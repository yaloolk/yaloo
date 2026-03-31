// lib/features/tourist/screens/guide/guide_booking_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import '../../providers/guide_booking_provider.dart';

class GuideBookingScreen extends StatefulWidget {
  const GuideBookingScreen({super.key});

  @override
  State<GuideBookingScreen> createState() => _GuideBookingScreenState();
}

class _GuideBookingScreenState extends State<GuideBookingScreen> {
  final _noteController    = TextEditingController();
  final _addressController = TextEditingController();

  int _guestCount = 1;

  // Passed from GuideDetailScreen
  late Map<String, dynamic> _guide;
  late String _bookingDate;
  late String _startTime;
  late String _endTime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _guide       = args['guide'] as Map<String, dynamic>;
      _bookingDate = args['booking_date'] ?? '';
      _startTime   = args['start_time'] ?? '';
      _endTime     = args['end_time'] ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ── Cost calculation ──────────────────────────────────────────────────────
  double get _totalHours {
    try {
      final start = _parseTime(_startTime);
      final end   = _parseTime(_endTime);
      final diffMins =
          (end.hour * 60 + end.minute) - (start.hour * 60 + start.minute);
      return diffMins / 60.0;
    } catch (_) {
      return 1.0;
    }
  }

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  double get _totalAmount =>
      _totalHours * (_guide['rate_per_hour'] ?? 0).toDouble();

  // ── Book ──────────────────────────────────────────────────────────────────
  Future<void> _onConfirm() async {
    final provider = context.read<GuideBookingProvider>();

    final success = await provider.createBooking(
      guideProfileId: _guide['guide_profile_id'] ?? '',
      bookingDate:    _bookingDate,
      startTime:      _startTime,
      endTime:        _endTime,
      guestCount:     _guestCount,
      pickupAddress:  _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      specialNote: _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : null,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(
        context,
        '/bookingConfirmation',
        arguments: {'booking': provider.lastCreatedBooking},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.bookingsError.isNotEmpty
              ? provider.bookingsError
              : 'Booking failed. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Confirm Booking'),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildGuideCard(),
          SizedBox(height: 20.h),
          _buildBookingDetails(),
          SizedBox(height: 20.h),
          _buildGuestCount(),
          SizedBox(height: 20.h),
          _buildPickupAddress(),
          SizedBox(height: 20.h),
          _buildSpecialNote(),
          SizedBox(height: 20.h),
          _buildPriceSummary(),
        ]),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── Guide card ────────────────────────────────────────────────────────────
  Widget _buildGuideCard() {
    final pic = _guide['profile_pic'] ?? '';
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.fourthBlue,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: pic.isNotEmpty
              ? CachedNetworkImage(
            imageUrl: pic,
            width: 64.w, height: 72.h, fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(width: 64.w, height: 72.h,
                    color: AppColors.secondaryGray),
            errorWidget: (_, __, ___) =>
                Container(width: 64.w, height: 72.h,
                    color: AppColors.secondaryGray),
          )
              : Container(
            width: 64.w, height: 72.h,
            color: AppColors.secondaryGray,
            child: Icon(CupertinoIcons.person_fill,
                color: AppColors.primaryGray, size: 32.w),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_guide['full_name'] ?? '',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp)),
            SizedBox(height: 4.h),
            Row(children: [
              Icon(CupertinoIcons.map_pin,
                  color: AppColors.primaryGray, size: 13.w),
              SizedBox(width: 4.w),
              Text(
                (_guide['city'] as Map?)?['name'] ?? '',
                style: AppTextStyles.textSmall
                    .copyWith(color: AppColors.primaryGray),
              ),
            ]),
            SizedBox(height: 4.h),
            Row(children: [
              Icon(CupertinoIcons.star_fill, color: Colors.amber, size: 13.w),
              SizedBox(width: 4.w),
              Text(
                '${(_guide['avg_rating'] ?? 0).toStringAsFixed(1)}',
                style: AppTextStyles.textSmall
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ]),
          ]),
        ),
        Text(
          'LKR ${(_guide['rate_per_hour'] ?? 0).toStringAsFixed(0)}/hr',
          style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 13.sp),
        ),
      ]),
    );
  }

  // ── Booking details ────────────────────────────────────────────────────────
  Widget _buildBookingDetails() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.secondaryGray),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(children: [
        _detailRow(CupertinoIcons.calendar, 'Date', _bookingDate),
        SizedBox(height: 10.h),
        _detailRow(CupertinoIcons.time, 'Start Time', _fmtDisplay(_startTime)),
        SizedBox(height: 10.h),
        _detailRow(
            CupertinoIcons.time_solid, 'End Time', _fmtDisplay(_endTime)),
        SizedBox(height: 10.h),
        _detailRow(
            CupertinoIcons.clock, 'Duration', '${_totalHours.toStringAsFixed(1)} hours'),
      ]),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: AppColors.primaryBlue, size: 18.w),
      SizedBox(width: 12.w),
      Text(label,
          style: AppTextStyles.textSmall
              .copyWith(color: AppColors.primaryGray)),
      const Spacer(),
      Text(value,
          style: AppTextStyles.textSmall
              .copyWith(fontWeight: FontWeight.bold)),
    ]);
  }

  String _fmtDisplay(String t) {
    try {
      final parts = t.split(':');
      int h = int.parse(parts[0]);
      final m = parts[1];
      final s = h >= 12 ? 'PM' : 'AM';
      if (h == 0) h = 12;
      if (h > 12) h -= 12;
      return '$h:$m $s';
    } catch (_) {
      return t;
    }
  }

  // ── Guest count ────────────────────────────────────────────────────────────
  Widget _buildGuestCount() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Number of Guests'),
      SizedBox(height: 10.h),
      Row(children: [
        _counterBtn(CupertinoIcons.minus,
                () => setState(() { if (_guestCount > 1) _guestCount--; })),
        SizedBox(width: 20.w),
        Text('$_guestCount',
            style: AppTextStyles.headlineLarge
                .copyWith(fontWeight: FontWeight.bold, fontSize: 20.sp)),
        SizedBox(width: 20.w),
        _counterBtn(CupertinoIcons.plus,
                () => setState(() => _guestCount++)),
      ]),
    ]);
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w, height: 40.h,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondaryGray, width: 1.5),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: AppColors.primaryBlack, size: 18.w),
      ),
    );
  }

  // ── Pickup address ─────────────────────────────────────────────────────────
  Widget _buildPickupAddress() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Pickup Address (optional)'),
      SizedBox(height: 10.h),
      TextField(
        controller: _addressController,
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'e.g., Hotel name or landmark',
          hintStyle:
          AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
          filled: true,
          fillColor: AppColors.fourthBlue,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    ]);
  }

  // ── Special note ──────────────────────────────────────────────────────────
  Widget _buildSpecialNote() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Special Note (optional)'),
      SizedBox(height: 10.h),
      TextField(
        controller: _noteController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Any specific requests or preferences...',
          hintStyle:
          AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
          filled: true,
          fillColor: AppColors.fourthBlue,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    ]);
  }

  // ── Price summary ─────────────────────────────────────────────────────────
  Widget _buildPriceSummary() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.fourthBlue,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(children: [
        _priceRow('Rate per hour',
            'LKR ${(_guide['rate_per_hour'] ?? 0).toStringAsFixed(0)}'),
        SizedBox(height: 8.h),
        _priceRow('Duration', '${_totalHours.toStringAsFixed(1)} hrs'),
        Divider(color: AppColors.secondaryGray, height: 20.h),
        _priceRow(
          'Total',
          'LKR ${_totalAmount.toStringAsFixed(2)}',
          bold: true,
          valueColor: AppColors.primaryBlue,
        ),
      ]),
    );
  }

  Widget _priceRow(String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Row(children: [
      Text(label,
          style: AppTextStyles.textSmall
              .copyWith(color: AppColors.primaryGray)),
      const Spacer(),
      Text(
        value,
        style: AppTextStyles.textSmall.copyWith(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: valueColor ?? AppColors.primaryBlack,
          fontSize: bold ? 16.sp : null,
        ),
      ),
    ]);
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Consumer<GuideBookingProvider>(
      builder: (_, provider, __) => Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGray.withAlpha(40),
              blurRadius: 16,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.primaryGray)),
              Text(
                'LKR ${_totalAmount.toStringAsFixed(2)}',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: provider.createLoading ? null : _onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: const StadiumBorder(),
              minimumSize: Size(double.infinity, 52.h),
            ),
            child: provider.createLoading
                ? SizedBox(
                width: 24.w, height: 24.h,
                child: const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : Text(
              'Confirm Booking',
              style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: AppTextStyles.bodyLarge
        .copyWith(fontWeight: FontWeight.bold, fontSize: 14.sp),
  );
}