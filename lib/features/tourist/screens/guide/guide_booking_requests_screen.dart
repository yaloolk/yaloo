// lib/features/guide/screens/guide/guide_booking_requests_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

import '../../models/guide_booking_model.dart';
import '../../providers/guide_booking_provider.dart';

class GuideBookingRequestsScreen extends StatefulWidget {
  const GuideBookingRequestsScreen({super.key});

  @override
  State<GuideBookingRequestsScreen> createState() =>
      _GuideBookingRequestsScreenState();
}

class _GuideBookingRequestsScreenState
    extends State<GuideBookingRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuideBookingProvider>().loadAllGuideBookings();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Bookings',
          style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.primaryGray,
          indicatorColor: AppColors.primaryBlue,
          labelStyle: AppTextStyles.textSmall
              .copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Requests'),
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Consumer<GuideBookingProvider>(
        builder: (context, provider, _) {
          if (provider.guideReqLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tab,
            children: [
              // ── Requests ───────────────────────────────────────────────
              _buildRequestsTab(provider),
              // ── Upcoming ───────────────────────────────────────────────
              _buildListTab(provider.guideUpcoming, provider, upcoming: true),
              // ── History ────────────────────────────────────────────────
              _buildListTab(provider.guideHistory, provider),
            ],
          );
        },
      ),
    );
  }

  // ── Requests tab ──────────────────────────────────────────────────────────
  Widget _buildRequestsTab(GuideBookingProvider provider) {
    if (provider.guideRequests.isEmpty) {
      return _empty('No pending requests', 'New booking requests will appear here');
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadGuideRequests(),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        itemCount: provider.guideRequests.length,
        itemBuilder: (_, i) => _RequestCard(
          booking: provider.guideRequests[i],
          onAccept: () => _respond(provider.guideRequests[i].id, 'accept', provider),
          onReject: () => _respond(provider.guideRequests[i].id, 'reject', provider),
        ),
      ),
    );
  }

  // ── Upcoming + History tab ─────────────────────────────────────────────────
  Widget _buildListTab(
      List<GuideBookingModel> bookings, GuideBookingProvider provider,
      {bool upcoming = false}) {
    if (bookings.isEmpty) {
      return _empty(
        upcoming ? 'No upcoming bookings' : 'No history yet',
        upcoming
            ? 'Confirmed bookings will appear here'
            : 'Completed and past bookings will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: upcoming
          ? () => provider.loadGuideUpcoming()
          : () => provider.loadGuideHistory(),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        itemCount: bookings.length,
        itemBuilder: (_, i) => _HistoryCard(
          booking: bookings[i],
          onComplete: upcoming
              ? () => _complete(bookings[i].id, provider)
              : null,
        ),
      ),
    );
  }

  Future<void> _respond(String bookingId, String action,
      GuideBookingProvider provider) async {
    String? note;

    if (action == 'reject') {
      note = await _showNoteDialog(context, 'Rejection Reason (optional)');
    }

    final success = await provider.respondToBooking(
      bookingId: bookingId,
      action:    action,
      guideResponseNote: note,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Booking ${action == "accept" ? "accepted" : "rejected"}'
            : provider.guideReqError),
        backgroundColor: success
            ? (action == 'accept' ? Colors.green : Colors.red)
            : Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _complete(String bookingId, GuideBookingProvider provider) async {
    final ok = await provider.completeBooking(bookingId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Booking marked as completed' : provider.guideReqError),
        backgroundColor: ok ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<String?> _showNoteDialog(BuildContext ctx, String hint) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(hint),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Enter a note...'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Skip')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Send')),
        ],
      ),
    );
  }

  Widget _empty(String title, String subtitle) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(CupertinoIcons.calendar, color: AppColors.primaryGray, size: 56.w),
        SizedBox(height: 16.h),
        Text(title,
            style: AppTextStyles.bodyLarge
                .copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp)),
        SizedBox(height: 8.h),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.textSmall
                .copyWith(color: AppColors.primaryGray)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REQUEST CARD  (pending — has accept/reject)
// ─────────────────────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final GuideBookingModel booking;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestCard({
    required this.booking,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(25),
            blurRadius: 14,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Tourist info
          Row(children: [
            _avatar(booking.touristPhoto),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.touristName.isNotEmpty
                        ? booking.touristName
                        : 'Tourist',
                        style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 15.sp)),
                    if (booking.touristPhone.isNotEmpty)
                      Row(children: [
                        Icon(CupertinoIcons.phone,
                            size: 13.w, color: AppColors.primaryGray),
                        SizedBox(width: 4.w),
                        Text(booking.touristPhone,
                            style: AppTextStyles.textSmall
                                .copyWith(color: AppColors.primaryGray)),
                      ]),
                  ]),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(25),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text('Pending',
                  style: AppTextStyles.textSmall.copyWith(
                      color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
          ]),
          SizedBox(height: 12.h),

          // Details
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.fourthBlue,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(children: [
              _row(CupertinoIcons.calendar, booking.bookingDate),
              SizedBox(height: 6.h),
              _row(CupertinoIcons.time,
                  '${_fmt(booking.startTime)} – ${_fmt(booking.endTime)}  (${booking.totalHours.toStringAsFixed(1)} hrs)'),
              SizedBox(height: 6.h),
              _row(CupertinoIcons.person_2,
                  '${booking.guestCount} guest${booking.guestCount > 1 ? "s" : ""}'),
              if (booking.specialNote != null &&
                  booking.specialNote!.isNotEmpty) ...[
                SizedBox(height: 6.h),
                _row(CupertinoIcons.doc_text, booking.specialNote!),
              ],
            ]),
          ),
          SizedBox(height: 8.h),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              'LKR ${booking.totalAmount.toStringAsFixed(2)}',
              style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
            ),
            Row(children: [
              // Reject
              OutlinedButton(
                onPressed: onReject,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text('Reject',
                    style: AppTextStyles.textSmall
                        .copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: 10.w),
              // Accept
              ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text('Accept',
                    style: AppTextStyles.textSmall.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ]),
          ]),
        ]),
      ),
    );
  }

  Widget _avatar(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: url.isNotEmpty
          ? CachedNetworkImage(
        imageUrl: url,
        width: 48.w, height: 52.h, fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _avatarBox(),
      )
          : _avatarBox(),
    );
  }

  Widget _avatarBox() => Container(
    width: 48.w, height: 52.h,
    color: AppColors.secondaryGray,
    child: Icon(CupertinoIcons.person_fill,
        color: AppColors.primaryGray),
  );

  Widget _row(IconData icon, String text) => Row(children: [
    Icon(icon, size: 14.w, color: AppColors.primaryGray),
    SizedBox(width: 8.w),
    Expanded(
      child: Text(text,
          style: AppTextStyles.textSmall
              .copyWith(color: AppColors.primaryBlack)),
    ),
  ]);

  String _fmt(String t) {
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
}

// ─────────────────────────────────────────────────────────────────────────────
// HISTORY / UPCOMING CARD
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final GuideBookingModel booking;
  final VoidCallback? onComplete;

  const _HistoryCard({required this.booking, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _avatar(booking.touristPhoto),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              booking.touristName.isNotEmpty ? booking.touristName : 'Tourist',
              style: AppTextStyles.bodyLarge
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 15.sp),
            ),
          ),
          _StatusBadge(status: booking.bookingStatus),
        ]),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.fourthBlue,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(children: [
            Icon(CupertinoIcons.calendar,
                color: AppColors.primaryGray, size: 14.w),
            SizedBox(width: 6.w),
            Text(booking.bookingDate,
                style: AppTextStyles.textSmall
                    .copyWith(color: AppColors.primaryBlack)),
            const Spacer(),
            Text(
              'LKR ${booking.totalAmount.toStringAsFixed(2)}',
              style: AppTextStyles.textSmall.copyWith(
                  color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
            ),
          ]),
        ),
        if (onComplete != null && booking.bookingStatus == 'confirmed') ...[
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text('Mark Complete',
                  style: AppTextStyles.textSmall.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _avatar(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: url.isNotEmpty
          ? CachedNetworkImage(
        imageUrl: url,
        width: 44.w, height: 48.h, fit: BoxFit.cover,
        errorWidget: (_, __, ___) => Container(
            width: 44.w, height: 48.h,
            color: AppColors.secondaryGray),
      )
          : Container(
        width: 44.w, height: 48.h,
        color: AppColors.secondaryGray,
        child: Icon(CupertinoIcons.person_fill,
            color: AppColors.primaryGray),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, text;
    switch (status) {
      case 'confirmed':
        bg = Colors.green.withAlpha(25); text = Colors.green; break;
      case 'completed':
        bg = AppColors.primaryBlue.withAlpha(25);
        text = AppColors.primaryBlue; break;
      case 'rejected':
      case 'cancelled':
        bg = Colors.red.withAlpha(25); text = Colors.red; break;
      default:
        bg = Colors.orange.withAlpha(25); text = Colors.orange;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8.r)),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: AppTextStyles.textSmall
            .copyWith(color: text, fontWeight: FontWeight.bold, fontSize: 11.sp),
      ),
    );
  }
}