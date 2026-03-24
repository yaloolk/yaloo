// lib/features/guide/screens/guide_tour_request_details.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/features/tourist/models/guide_booking_model.dart';
import 'package:yaloo/features/tourist/services/guide_booking_service.dart';

class GuideTourRequestDetailsScreen extends StatefulWidget {
  const GuideTourRequestDetailsScreen({super.key});
  @override
  State<GuideTourRequestDetailsScreen> createState() => _State();
}

class _State extends State<GuideTourRequestDetailsScreen> {
  final _service = GuideBookingService();
  bool _isAccepting = false;
  bool _isDeclining = false;

  // ── Accept ───────────────────────────────────────────────────────────────
  Future<void> _accept(GuideBookingModel b) async {
    setState(() => _isAccepting = true);
    try {
      await _service.respondToBooking(bookingId: b.id, action: 'accept');
      if (!mounted) return;
      _snack('Booking accepted ✓', AppColors.primaryGreen);
      Navigator.of(context).pop(true);           // pop → list refreshes
    } catch (e) {
      if (mounted) {
        _snack(e.toString(), AppColors.primaryRed);
        setState(() => _isAccepting = false);
      }
    }
  }

  // ── Reject (with optional note dialog) ──────────────────────────────────
  Future<void> _reject(GuideBookingModel b) async {
    final ctrl = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        title: Text('Decline Booking',
            style: TextStyle(
                fontSize: 18.sp, fontWeight: FontWeight.w800,
                color: AppColors.primaryBlack)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Add a note for the tourist (optional):',
              style: TextStyle(fontSize: 13.sp,
                  color: AppColors.primaryGray)),
          SizedBox(height: 12.h),
          TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: InputDecoration(
                  hintText: 'Reason for declining…',
                  hintStyle: TextStyle(color: AppColors.primaryGray,
                      fontSize: 13.sp),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  contentPadding: EdgeInsets.all(12.w))),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: Text('Cancel',
                  style: TextStyle(color: AppColors.primaryGray))),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r))),
              child: const Text('Decline',
                  style: TextStyle(color: Colors.white))),
        ],
      ),
    );

    if (note == null || !mounted) return;   // cancelled

    setState(() => _isDeclining = true);
    try {
      await _service.respondToBooking(
        bookingId: b.id,
        action: 'reject',
        guideResponseNote: note.isEmpty ? null : note,
      );
      if (!mounted) return;
      _snack('Booking declined', AppColors.primaryGray);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        _snack(e.toString(), AppColors.primaryRed);
        setState(() => _isDeclining = false);
      }
    }
  }

  // ── Complete booking ─────────────────────────────────────────────────────
  Future<void> _complete(GuideBookingModel b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        title: const Text('Mark as Completed?'),
        content: const Text(
            'This will mark the tour as completed and update your earnings.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r))),
              child: const Text('Confirm',
                  style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      await _service.completeBooking(b.id);
      if (!mounted) return;
      _snack('Booking marked as completed ✓', AppColors.primaryGreen);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) _snack(e.toString(), AppColors.primaryRed);
    }
  }

  void _snack(String msg, Color bg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // The previous screen always passes {'booking': GuideBookingModel}
    final args = ModalRoute.of(context)?.settings.arguments
    as Map<String, dynamic>? ?? {};
    final b = args['booking'] as GuideBookingModel?;

    if (b == null) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Tour Request'),
        body: const Center(child: Text('No booking data found.')),
      );
    }

    final isPending   = b.bookingStatus == 'pending';
    final isConfirmed = b.bookingStatus == 'confirmed';
    final isLoading   = _isAccepting || _isDeclining;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: isPending ? 'Tour Request' : 'Booking Detail'),
      body: Stack(children: [

        // ── Scrollable content ────────────────────────────────────────────
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                _touristCard(b),
                SizedBox(height: 20.h),
                _tourDetailsCard(b),
                SizedBox(height: 20.h),
                _paymentCard(b),
                if (b.guideResponseNote != null &&
                    b.guideResponseNote!.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  _responseNoteCard(b.guideResponseNote!),
                ],
                // Bottom padding so content clears the action bar
                SizedBox(height: (isPending || isConfirmed) ? 180.h : 40.h),
              ],
            ),
          ),
        ),

        // ── Sticky action bar (only for pending / confirmed) ──────────────
        if (isPending || isConfirmed)
          Positioned(
              bottom: 0, left: 0, right: 0,
              child: _actionBar(b, isLoading, isPending, isConfirmed)),
      ]),
    );
  }

  // ── Tourist info card ─────────────────────────────────────────────────────
  Widget _touristCard(GuideBookingModel b) {
    final name = b.touristName.isNotEmpty ? b.touristName : 'Tourist';
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(children: [
          Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.3), width: 2.5)),
              child: CircleAvatar(
                  radius: 30.r,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  backgroundImage: b.touristPhoto.isNotEmpty
                      ? CachedNetworkImageProvider(b.touristPhoto) : null,
                  child: b.touristPhoto.isEmpty
                      ? Icon(CupertinoIcons.person,
                      color: AppColors.primaryBlue, size: 24.w) : null)),
          SizedBox(width: 16.w),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.headlineLargeBlack.copyWith(
                    fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                if (b.touristPhone.isNotEmpty)
                  Text(b.touristPhone, style: AppTextStyles.textSmall.copyWith(
                      color: AppColors.primaryGray)),
                SizedBox(height: 6.h),
                _statusChip(b.bookingStatus),
              ])),
          GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/touristPublicProfile',
                  arguments: {'userId': b.touristProfileId}),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: 28.h),
                    Text('View Profile →', style: AppTextStyles.textSmall.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold, fontSize: 12.sp)),
                  ])),
        ]),
      ),
    );
  }

  // ── Tour details card ─────────────────────────────────────────────────────
  Widget _tourDetailsCard(GuideBookingModel b) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tour Details', style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          _detailRow(FontAwesomeIcons.calendar, _fmtDate(b.bookingDate)),
          _detailRow(FontAwesomeIcons.clock,
              '${_fmtTime(b.startTime)} – ${_fmtTime(b.endTime)} '
                  '(${b.totalHours.toStringAsFixed(1)}h)'),
          _detailRow(FontAwesomeIcons.userGroup,
              '${b.guestCount} guest${b.guestCount > 1 ? 's' : ''}'),
          if (b.cityName.isNotEmpty)
            _detailRow(FontAwesomeIcons.mapPin, b.cityName),
          if (b.pickupAddress != null && b.pickupAddress!.isNotEmpty)
            _detailRow(FontAwesomeIcons.locationArrow, b.pickupAddress!),
          if (b.specialNote != null && b.specialNote!.isNotEmpty)
            _detailRow(FontAwesomeIcons.noteSticky,
                'Note: "${b.specialNote}"', isNote: true),
        ]),
      ),
    );
  }

  // ── Payment card ──────────────────────────────────────────────────────────
  Widget _paymentCard(GuideBookingModel b) {
    final rate      = b.ratePerHour;
    final hours     = b.totalHours;
    final gross     = rate * hours;
    final fee       = gross * 0.10;   // 10% platform fee
    final payout    = b.totalAmount;

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Payment Summary', style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          _payRow('Rate/hour:', 'LKR ${rate.toStringAsFixed(0)}'),
          _payRow('Duration:', '${hours.toStringAsFixed(1)}h'),
          _payRow('Sub-total:', 'LKR ${gross.toStringAsFixed(0)}'),
          _payRow('Platform fee (10%):', '− LKR ${fee.toStringAsFixed(0)}'),
          Divider(height: 20.h, color: Colors.black.withOpacity(0.06)),
          _payRow('Your payout:', 'LKR ${payout.toStringAsFixed(0)}',
              isTotal: true),
          if (b.tipAmount > 0) ...[
            SizedBox(height: 6.h),
            _payRow('Tip received:', '+ LKR ${b.tipAmount.toStringAsFixed(0)}',
                isTotal: true),
          ],
        ]),
      ),
    );
  }

  // ── Guide response note card ──────────────────────────────────────────────
  Widget _responseNoteCard(String note) => Card(
    elevation: 4,
    shadowColor: Colors.black.withOpacity(0.06),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
    color: Colors.white,
    child: Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your Response Note',
            style: AppTextStyles.headlineLargeBlack.copyWith(
                fontSize: 16.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 10.h),
        Text(note, style: AppTextStyles.textSmall.copyWith(
            color: AppColors.primaryGray, fontStyle: FontStyle.italic,
            height: 1.5)),
      ]),
    ),
  );

  // ── Bottom action bar ─────────────────────────────────────────────────────
  Widget _actionBar(GuideBookingModel b, bool isLoading,
      bool isPending, bool isConfirmed) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.primaryBlack.withOpacity(0.9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        // ── Action buttons ────────────────────────────────────────────────
        Row(children: [
          if (isPending) ...[
            Expanded(child: ElevatedButton(
              onPressed: isLoading ? null : () => _accept(b),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r))),
              child: _isAccepting
                  ? _loader()
                  : Text('Accept Request',
                  style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            )),
            SizedBox(width: 16.w),
            Expanded(child: ElevatedButton(
              onPressed: isLoading ? null : () => _reject(b),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGray.withOpacity(0.3),
                  foregroundColor: Colors.white, elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r))),
              child: _isDeclining
                  ? _loader()
                  : Text('Decline',
                  style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            )),
          ],

          if (isConfirmed)
            Expanded(child: ElevatedButton.icon(
              onPressed: isLoading ? null : () => _complete(b),
              icon: Icon(Icons.check_circle_outline, size: 18.w),
              label: const Text('Mark as Completed'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r))),
            )),
        ]),

        SizedBox(height: 14.h),

        // ── Safety tips ───────────────────────────────────────────────────
        _safetyTip(FontAwesomeIcons.shieldHalved,
            'Free cancellation up to 24h before tour.'),
        SizedBox(height: 4.h),
        _safetyTip(FontAwesomeIcons.locationArrow,
            'Meet only at safe & agreed locations.'),
      ]),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'confirmed':  color = AppColors.primaryGreen;  break;
      case 'rejected':   color = AppColors.primaryRed;    break;
      case 'cancelled':  color = AppColors.primaryGray;   break;
      case 'completed':  color = AppColors.primaryBlue;   break;
      default:           color = const Color(0xFFF59E0B); // amber = pending
    }
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20.r)),
        child: Text(status[0].toUpperCase() + status.substring(1),
            style: TextStyle(color: color, fontSize: 11.sp,
                fontWeight: FontWeight.w700)));
  }

  Widget _detailRow(IconData icon, String text, {bool isNote = false}) =>
      Padding(
          padding: EdgeInsets.symmetric(vertical: 7.h),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: AppColors.primaryGray, size: 15.w),
            SizedBox(width: 12.w),
            Expanded(child: Text(text, style: AppTextStyles.textSmall.copyWith(
                color: isNote ? AppColors.primaryBlack : AppColors.primaryGray,
                fontStyle: isNote ? FontStyle.italic : FontStyle.normal,
                height: 1.4))),
          ]));

  Widget _payRow(String label, String value, {bool isTotal = false}) =>
      Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: isTotal
                    ? AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue)
                    : AppTextStyles.textSmall.copyWith(
                    color: AppColors.primaryGray)),
                Text(value, style: isTotal
                    ? AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue)
                    : AppTextStyles.textSmall.copyWith(
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.w600)),
              ]));

  Widget _safetyTip(IconData icon, String text) => Row(children: [
    Icon(icon, color: AppColors.primaryGray, size: 12.w),
    SizedBox(width: 8.w),
    Flexible(child: Text(text, style: AppTextStyles.textSmall.copyWith(
        color: AppColors.primaryGray, fontSize: 11.sp))),
  ]);

  Widget _loader() => SizedBox(
      height: 20.h, width: 20.w,
      child: const CircularProgressIndicator(
          color: Colors.white, strokeWidth: 2));

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