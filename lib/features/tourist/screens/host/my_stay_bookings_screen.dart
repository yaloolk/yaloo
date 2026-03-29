// lib/features/tourist/screens/host/my_stay_bookings_screen.dart
//
// Tourists view all their stay bookings in one place.
// Completed bookings show a "Leave Review" button.
// Tapping a booking goes to StayBookingStatusScreen.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:yaloo/features/tourist/models/stay_booking_model.dart';
import 'package:yaloo/features/tourist/providers/stay_booking_provider.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _blue       = Color(0xFF2563EB);
const _blueDark   = Color(0xFF1D4ED8);
const _blueDarker = Color(0xFF1E40AF);
const _bg         = Color(0xFFF8FAFC);
const _dark       = Color(0xFF1F2937);
const _gray       = Color(0xFF6B7280);
const _green      = Color(0xFF10B981);
const _amber      = Color(0xFFF59E0B);
const _red        = Color(0xFFEF4444);

class MyStayBookingsScreen extends StatefulWidget {
  const MyStayBookingsScreen({super.key});
  @override State<MyStayBookingsScreen> createState() =>
      _MyStayBookingsScreenState();
}

class _MyStayBookingsScreenState extends State<MyStayBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StayBookingProvider>().loadMyBookings();
    });
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  List<StayBookingModel> _filter(List<StayBookingModel> all, String? status) {
    if (status == null) return all;
    if (status == 'upcoming') {
      return all.where((b) => b.bookingStatus == 'pending' || b.bookingStatus == 'confirmed').toList();
    }
    if (status == 'cancelled') {
      return all.where((b) => b.bookingStatus == 'cancelled' || b.bookingStatus == 'rejected').toList();
    }
    return all.where((b) => b.bookingStatus == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130.h),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [_blue, _blueDark, _blueDarker],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: SafeArea(bottom: false, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0), child: Row(children: [
                Container(padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r)),
                    child: Icon(CupertinoIcons.house, color: Colors.white, size: 20.w)),
                SizedBox(width: 12.w),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('My Stays', style: TextStyle(color: Colors.white, fontSize: 20.sp,
                      fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  Text('Track your homestay bookings',
                      style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12.sp)),
                ]),
              ])),
              SizedBox(height: 8.h),
              TabBar(
                controller: _tabCtrl, isScrollable: true, tabAlignment: TabAlignment.start,
                labelColor: Colors.white, unselectedLabelColor: Colors.white.withOpacity(0.55),
                labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                unselectedLabelStyle: TextStyle(fontSize: 13.sp),
                indicator: UnderlineTabIndicator(
                    borderSide: const BorderSide(width: 2.5, color: Colors.white),
                    insets: EdgeInsets.symmetric(horizontal: 14.w)),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                  Tab(text: 'Pending'),
                ],
              ),
            ],
          )),
        ),
      ),
      body: Consumer<StayBookingProvider>(
        builder: (_, prov, __) {
          if (prov.myLoading) return const Center(child: CircularProgressIndicator(color: _blue));
          return TabBarView(controller: _tabCtrl, children: [
            _BookingList(bookings: prov.myBookings, onCancel: _cancel, showReview: true),
            _BookingList(bookings: _filter(prov.myBookings, 'upcoming'), onCancel: _cancel),
            _BookingList(bookings: _filter(prov.myBookings, 'completed'), onCancel: null, showReview: true),
            _BookingList(bookings: _filter(prov.myBookings, 'cancelled'), onCancel: null),
            _BookingList(bookings: _filter(prov.myBookings, 'pending'),  onCancel: _cancel),
          ]);
        },
      ),
    );
  }

  Future<void> _cancel(String bookingId) async {
    final prov = context.read<StayBookingProvider>();
    final ok   = await prov.cancelBooking(bookingId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Booking cancelled' : 'Failed to cancel'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ok ? _green : _red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _BookingList extends StatelessWidget {
  final List<StayBookingModel> bookings;
  final Future<void> Function(String)? onCancel;
  final bool showReview;
  const _BookingList({required this.bookings, this.onCancel, this.showReview = false});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) return _empty();
    return RefreshIndicator(
      color: _blue,
      onRefresh: () => context.read<StayBookingProvider>().loadMyBookings(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        physics: const BouncingScrollPhysics(),
        itemCount: bookings.length,
        itemBuilder: (_, i) => _StayBookingCard(
          booking: bookings[i],
          onCancel: onCancel,
          showReview: showReview,
        ),
      ),
    );
  }

  Widget _empty() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_blue.withOpacity(0.1), _blue.withOpacity(0.05)]),
            shape: BoxShape.circle),
        child: Icon(CupertinoIcons.house, color: _blue, size: 48.w)),
    SizedBox(height: 18.h),
    Text('No Stays Yet', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: _dark)),
    SizedBox(height: 6.h),
    Text('Your homestay bookings will appear here', style: TextStyle(color: _gray, fontSize: 13.sp)),
  ]));
}

// ─────────────────────────────────────────────────────────────────────────────
class _StayBookingCard extends StatelessWidget {
  final StayBookingModel booking;
  final Future<void> Function(String)? onCancel;
  final bool showReview;
  const _StayBookingCard({required this.booking, this.onCancel, this.showReview = false});

  _StatusCfg get _cfg {
    switch (booking.bookingStatus) {
      case 'confirmed': return _StatusCfg(_green, const Color(0xFF059669), FontAwesomeIcons.circleCheck, 'Confirmed');
      case 'completed': return _StatusCfg(_blue, _blueDark, FontAwesomeIcons.flagCheckered, 'Completed');
      case 'rejected':  return _StatusCfg(_red, const Color(0xFFB91C1C), FontAwesomeIcons.circleXmark, 'Rejected');
      case 'cancelled': return _StatusCfg(_gray, const Color(0xFF4B5563), FontAwesomeIcons.ban, 'Cancelled');
      default:          return _StatusCfg(_amber, const Color(0xFFD97706), FontAwesomeIcons.hourglassHalf, 'Pending');
    }
  }

  String _fmtDate(String d) {
    try { final dt = DateTime.parse(d); const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month-1]}'; }
    catch (_) { return d; }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _cfg;
    final canCancel = (booking.bookingStatus == 'pending' || booking.bookingStatus == 'confirmed') && onCancel != null;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/stayBookingStatus', arguments: booking.toJson()),
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24.r),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Column(children: [
            // Status banner
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(gradient: LinearGradient(
                  colors: [cfg.color, cfg.colorDark], begin: Alignment.centerLeft, end: Alignment.centerRight)),
              child: Row(children: [
                Icon(cfg.icon, color: Colors.white, size: 13.w),
                SizedBox(width: 7.w),
                Text(cfg.label, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w800)),
                const Spacer(),
                Icon(CupertinoIcons.chevron_right, color: Colors.white.withOpacity(0.8), size: 13.w),
              ]),
            ),

            // Stay photo + info
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: booking.stayCoverPhoto.isNotEmpty
                      ? CachedNetworkImage(imageUrl: booking.stayCoverPhoto, width: 64.w, height: 72.h, fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _photoFb())
                      : _photoFb(),
                ),
                SizedBox(width: 12.w),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(booking.stayName.isNotEmpty ? booking.stayName : 'Stay',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: _dark),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 3.h),
                  Row(children: [
                    Icon(CupertinoIcons.map_pin, color: _gray, size: 11.w), SizedBox(width: 3.w),
                    Flexible(child: Text(booking.cityName, style: TextStyle(color: _gray, fontSize: 11.sp), overflow: TextOverflow.ellipsis)),
                  ]),
                  SizedBox(height: 3.h),
                  Text('Hosted by ${booking.hostName}', style: TextStyle(color: _gray, fontSize: 11.sp), overflow: TextOverflow.ellipsis),
                ])),
              ]),
            ),

            // Dates & cost
            Container(
              margin: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12.r)),
              child: Column(children: [
                _infoRow(CupertinoIcons.calendar,
                    '${_fmtDate(booking.checkinDate)} → ${_fmtDate(booking.checkoutDate)}  (${booking.totalNights} night${booking.totalNights > 1 ? 's' : ''})'),
                SizedBox(height: 5.h),
                _infoRow(CupertinoIcons.person_2,
                    '${booking.roomCount} room${booking.roomCount > 1 ? 's' : ''}  ·  ${booking.guestCount} guest${booking.guestCount > 1 ? 's' : ''}'),
                SizedBox(height: 5.h),
                _infoRow(CupertinoIcons.money_dollar_circle, 'LKR ${booking.totalAmount.toStringAsFixed(0)}  (${_capitalize(booking.paymentStatus)})'),
              ]),
            ),

            // Action buttons
            if (canCancel) Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: SizedBox(width: double.infinity, child: OutlinedButton.icon(
                onPressed: () => _confirmCancel(context),
                icon: Icon(FontAwesomeIcons.ban, size: 12.w),
                label: Text('Cancel Booking', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                    foregroundColor: _red, side: BorderSide(color: _red.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    padding: EdgeInsets.symmetric(vertical: 10.h)),
              )),
            )
            else if (showReview && booking.bookingStatus == 'completed') Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/stayReview', arguments: booking),
                icon: Icon(FontAwesomeIcons.solidStar, size: 14.w),
                label: Text('Leave a Review', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _amber, foregroundColor: Colors.white, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    padding: EdgeInsets.symmetric(vertical: 11.h)),
              )),
            )
            else SizedBox(height: 2.h),
          ]),
        ),
      ),
    );
  }

  Widget _photoFb() => Container(width: 64.w, height: 72.h, decoration: BoxDecoration(color: _blue.withOpacity(0.08)),
      child: Icon(CupertinoIcons.house, color: _blue.withOpacity(0.35), size: 22.w));

  Widget _infoRow(IconData icon, String value) => Row(children: [
    Icon(icon, color: _blue, size: 13.w), SizedBox(width: 8.w),
    Expanded(child: Text(value, style: TextStyle(color: _dark, fontSize: 12.sp, fontWeight: FontWeight.w600))),
  ]);

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('Cancel Booking?'),
        content: const Text('Are you sure you want to cancel this stay booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Keep', style: TextStyle(color: _gray))),
          ElevatedButton(
              onPressed: () { Navigator.pop(context); onCancel!(booking.id); },
              style: ElevatedButton.styleFrom(backgroundColor: _red, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
              child: const Text('Cancel', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

class _StatusCfg {
  final Color color, colorDark;
  final IconData icon;
  final String label;
  const _StatusCfg(this.color, this.colorDark, this.icon, this.label);
}