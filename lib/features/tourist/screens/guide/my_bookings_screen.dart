// lib/features/tourist/screens/guide/my_bookings_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import '../../models/guide_booking_model.dart';
import '../../providers/guide_booking_provider.dart';

const _blue     = Color(0xFF2563EB);
const _blueDark = Color(0xFF1D4ED8);
const _bgPage   = Color(0xFFF8FAFC);
const _dark     = Color(0xFF1F2937);
const _gray     = Color(0xFF6B7280);
const _green    = Color(0xFF10B981);
const _amber    = Color(0xFFF59E0B);

const _tabs = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});
  @override State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuideBookingProvider>().loadMyBookings();
    });
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: CustomAppBar(title: 'My Bookings'),
      body: Consumer<GuideBookingProvider>(
        builder: (_, prov, __) => Column(children: [
          _tabBar(),
          Expanded(child: prov.bookingsLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
            controller: _tabs,
            children: [
              _BookingList(bookings: prov.myBookings,           onCancel: _cancel),
              _BookingList(bookings: _filter(prov, 'pending'),   onCancel: _cancel),
              _BookingList(bookings: _filter(prov, 'confirmed'), onCancel: _cancel),
              _BookingList(bookings: _filter(prov, 'completed'), onCancel: null),
              _BookingList(bookings: _filter(prov, 'cancelled'), onCancel: null),
            ],
          )),
        ]),
      ),
    );
  }

  List<GuideBookingModel> _filter(GuideBookingProvider p, String status) =>
      p.myBookings.where((b) => b.bookingStatus == status).toList();

  Widget _tabBar() => Container(
    color: Colors.white,
    child: TabBar(
      controller: _tabs,
      isScrollable: true,
      labelColor: _blue,
      unselectedLabelColor: _gray,
      labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
      indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 2.5, color: _blue),
          insets: EdgeInsets.symmetric(horizontal: 16.w)),
      tabAlignment: TabAlignment.start,
      tabs: const [
        Tab(text: 'All'),
        Tab(text: 'Pending'),
        Tab(text: 'Confirmed'),
        Tab(text: 'Completed'),
        Tab(text: 'Cancelled'),
      ],
    ),
  );

  Future<void> _cancel(String bookingId) async {
    final prov = context.read<GuideBookingProvider>();
    final ok   = await prov.cancelBooking(bookingId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Booking cancelled' : 'Failed to cancel'),
          behavior: SnackBarBehavior.floating));
    }
  }
}

// ── Booking list ───────────────────────────────────────────────────────────────
class _BookingList extends StatelessWidget {
  final List<GuideBookingModel> bookings;
  final Future<void> Function(String)? onCancel;
  const _BookingList({required this.bookings, this.onCancel});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) return _empty();
    return RefreshIndicator(
      onRefresh: () =>
          context.read<GuideBookingProvider>().loadMyBookings(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        physics: const BouncingScrollPhysics(),
        itemCount: bookings.length,
        itemBuilder: (_, i) => _BookingCard(
          booking: bookings[i],
          onCancel: onCancel,
        ),
      ),
    );
  }

  Widget _empty() => Center(child: Column(
      mainAxisSize: MainAxisSize.min, children: [
    Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
            color: _blue.withOpacity(0.08), shape: BoxShape.circle),
        child: Icon(CupertinoIcons.calendar, color: _blue, size: 44.w)),
    SizedBox(height: 16.h),
    Text('No Bookings', style: TextStyle(
        fontSize: 18.sp, fontWeight: FontWeight.w800, color: _dark)),
    SizedBox(height: 6.h),
    Text('Your guide bookings will appear here',
        style: TextStyle(color: _gray, fontSize: 13.sp)),
  ]));
}

// ── Booking card ───────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final GuideBookingModel booking;
  final Future<void> Function(String)? onCancel;
  const _BookingCard({required this.booking, this.onCancel});

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

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed':  return _green;
      case 'completed':  return _green;
      case 'rejected':   return Colors.red.shade400;
      case 'cancelled':  return Colors.orange.shade400;
      default:           return _amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = booking.bookingStatus;
    final canCancel =
        (status == 'pending' || status == 'confirmed') && onCancel != null;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 16, offset: const Offset(0, 4))]),
      child: Column(children: [
        // Top row — guide + status
        Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _photo(),
            SizedBox(width: 12.w),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.guideName.isNotEmpty
                      ? booking.guideName : 'Guide',
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w800, color: _dark)),
                  SizedBox(height: 3.h),
                  if (booking.cityName.isNotEmpty)
                    Row(children: [
                      Icon(CupertinoIcons.map_pin, color: _gray, size: 11.w),
                      SizedBox(width: 3.w),
                      Text(booking.cityName, style: TextStyle(
                          color: _gray, fontSize: 11.sp)),
                    ]),
                ])),
            _statusPill(status),
          ]),
        ),

        // Info rows
        Container(
          margin: EdgeInsets.symmetric(horizontal: 14.w),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
              color: _bgPage, borderRadius: BorderRadius.circular(14.r)),
          child: Column(children: [
            _infoRow(CupertinoIcons.calendar,
                booking.bookingDate.toString()),
            SizedBox(height: 6.h),
            _infoRow(CupertinoIcons.time,
                '${_fmt(booking.startTime.toString())} – ${_fmt(booking.endTime.toString())}'),
            SizedBox(height: 6.h),
            _infoRow(CupertinoIcons.money_dollar_circle,
                'LKR ${booking.totalAmount.toStringAsFixed(2)}'),
          ]),
        ),
        SizedBox(height: 12.h),

        // Cancel button
        if (canCancel)
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _confirmCancel(context),
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    side: BorderSide(color: Colors.red.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                    padding: EdgeInsets.symmetric(vertical: 10.h)),
                child: Text('Cancel Booking', style: TextStyle(
                    fontSize: 13.sp, fontWeight: FontWeight.w700)),
              ),
            ),
          )
        else
          SizedBox(height: 2.h),
      ]),
    );
  }

  Widget _photo() {
    final pic = booking.guidePhoto;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: pic.isNotEmpty
          ? CachedNetworkImage(
          imageUrl: pic, width: 52.w, height: 60.h, fit: BoxFit.cover,
          placeholder:  (_, __) => _photoFb(),
          errorWidget: (_, __, ___) => _photoFb())
          : _photoFb(),
    );
  }

  Widget _photoFb() => Container(
      width: 52.w, height: 60.h,
      decoration: BoxDecoration(color: _blue.withOpacity(0.08)),
      child: Icon(CupertinoIcons.person_fill,
          color: _blue.withOpacity(0.35), size: 22.w));

  Widget _statusPill(String status) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
    decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _statusColor(status).withOpacity(0.4))),
    child: Text(status.toUpperCase(), style: TextStyle(
        color: _statusColor(status),
        fontSize: 10.sp, fontWeight: FontWeight.w800)),
  );

  Widget _infoRow(IconData icon, String value) => Row(children: [
    Icon(icon, color: _blue, size: 13.w),
    SizedBox(width: 8.w),
    Text(value, style: TextStyle(
        color: _dark, fontSize: 12.sp, fontWeight: FontWeight.w600)),
  ]);

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('Cancel Booking?'),
        content: const Text(
            'Are you sure you want to cancel this booking? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Keep', style: TextStyle(color: _gray))),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onCancel!(booking.id.toString());
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  elevation: 0),
              child: const Text('Cancel', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}