// lib/features/tourist/screens/guide/my_bookings_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/guide_booking_model.dart';
import '../providers/guide_booking_provider.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _blue       = Color(0xFF2563EB);
const _blueDark   = Color(0xFF1D4ED8);
const _blueDarker = Color(0xFF1E40AF);
const _bgPage     = Color(0xFFF8FAFC);
const _dark       = Color(0xFF1F2937);
const _gray       = Color(0xFF6B7280);
const _green      = Color(0xFF10B981);
const _amber      = Color(0xFFF59E0B);
const _red        = Color(0xFFEF4444);

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});
  @override State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuideBookingProvider>().loadMyBookings();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(116.h),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_blue, _blueDark, _blueDarker],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                  child: Row(children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(CupertinoIcons.calendar,
                          color: Colors.white, size: 20.w),
                    ),
                    SizedBox(width: 12.w),
                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My Bookings',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3)),
                          Text('Track & manage your tours',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 12.sp)),
                        ]),
                  ]),
                ),
                SizedBox(height: 8.h),
                _tabBar(),
              ],
            ),
          ),
        ),
      ),

      body: Consumer<GuideBookingProvider>(
        builder: (_, prov, __) {
          if (prov.bookingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabCtrl,
            children: [
              _BookingList(bookings: prov.myBookings,                                            onCancel: _cancel),
              _BookingList(bookings: _filterActive(prov),                                        onCancel: _cancel, isActive: true),
              _BookingList(bookings: _filter(prov, 'pending'),                                   onCancel: _cancel),
              _BookingList(bookings: _filter(prov, 'confirmed'),                                 onCancel: _cancel),
              _BookingList(bookings: _filter(prov, 'completed'),                                 onCancel: null),
              _BookingList(bookings: [..._filter(prov, 'cancelled'), ..._filter(prov, 'rejected')], onCancel: null),
            ],
          );
        },
      ),
    );
  }

  List<GuideBookingModel> _filter(GuideBookingProvider p, String status) =>
      p.myBookings.where((b) => b.bookingStatus == status).toList();

  // Active = confirmed booking whose time window is NOW
  List<GuideBookingModel> _filterActive(GuideBookingProvider p) {
    final now = DateTime.now();
    return p.myBookings.where((b) {
      if (b.bookingStatus != 'confirmed') return false;
      try {
        final sp = b.startTime.split(':');
        final ep = b.endTime.split(':');
        final d  = DateTime.parse(b.bookingDate);
        final start = DateTime(d.year, d.month, d.day, int.parse(sp[0]), int.parse(sp[1]));
        final end   = DateTime(d.year, d.month, d.day, int.parse(ep[0]), int.parse(ep[1]));
        return now.isAfter(start) && now.isBefore(end);
      } catch (_) { return false; }
    }).toList();
  }

  Widget _tabBar() => TabBar(
    controller: _tabCtrl,
    isScrollable: true,
    tabAlignment: TabAlignment.start,
    labelColor: Colors.white,
    unselectedLabelColor: Colors.white.withOpacity(0.55),
    labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
    unselectedLabelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
    indicator: UnderlineTabIndicator(
        borderSide: const BorderSide(width: 2.5, color: Colors.white),
        insets: EdgeInsets.symmetric(horizontal: 14.w)),
    tabs: const [
      Tab(text: 'All'),
      Tab(child: _ActiveTabLabel()),
      Tab(text: 'Pending'),
      Tab(text: 'Confirmed'),
      Tab(text: 'Completed'),
      Tab(text: 'Cancelled'),
    ],
  );

  Future<void> _cancel(String bookingId) async {
    final prov = context.read<GuideBookingProvider>();
    final ok   = await prov.cancelBooking(bookingId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Booking cancelled' : 'Failed to cancel'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ok ? _green : _red,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r))));
    }
  }
}

// Pulsing "Active" tab label
class _ActiveTabLabel extends StatefulWidget {
  const _ActiveTabLabel();
  @override State<_ActiveTabLabel> createState() => _ActiveTabLabelState();
}
class _ActiveTabLabelState extends State<_ActiveTabLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _a = Tween(begin: 0.4, end: 1.0).animate(_c);
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    FadeTransition(opacity: _a, child: Container(
        width: 7, height: 7,
        decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle))),
    const SizedBox(width: 5),
    const Text('Active'),
  ]);
}

class _BookingList extends StatelessWidget {
  final List<GuideBookingModel> bookings;
  final Future<void> Function(String)? onCancel;
  final bool isActive;
  const _BookingList({required this.bookings, this.onCancel, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) return _empty();
    return RefreshIndicator(
      color: _blue,
      onRefresh: () => context.read<GuideBookingProvider>().loadMyBookings(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        physics: const BouncingScrollPhysics(),
        itemCount: bookings.length,
        itemBuilder: (_, i) =>
            _BookingCard(bookings: bookings[i], onCancel: onCancel),
      ),
    );
  }

  Widget _empty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [_blue.withOpacity(0.1), _blue.withOpacity(0.05)]),
            shape: BoxShape.circle),
        child: Icon(CupertinoIcons.calendar, color: _blue, size: 48.w),
      ),
      SizedBox(height: 18.h),
      Text('No Bookings Yet',
          style: TextStyle(
              fontSize: 18.sp, fontWeight: FontWeight.w800, color: _dark)),
      SizedBox(height: 6.h),
      Text('Your guide bookings will appear here',
          style: TextStyle(color: _gray, fontSize: 13.sp)),
    ]),
  );
}

class _BookingCard extends StatelessWidget {
  final GuideBookingModel bookings;
  final Future<void> Function(String)? onCancel;
  const _BookingCard({required this.bookings, this.onCancel});

  _StatusConfig _cfg(String s) {
    switch (s) {
      case 'confirmed': return _StatusConfig(_green, const Color(0xFF059669), FontAwesomeIcons.circleCheck, 'Confirmed');
      case 'completed': return _StatusConfig(_blue, _blueDark, FontAwesomeIcons.flagCheckered, 'Completed');
      case 'rejected': return _StatusConfig(_red, const Color(0xFFB91C1C), FontAwesomeIcons.circleXmark, 'Rejected');
      case 'cancelled': return _StatusConfig(_gray, const Color(0xFF4B5563), FontAwesomeIcons.ban, 'Cancelled');
      default: return _StatusConfig(_amber, const Color(0xFFD97706), FontAwesomeIcons.hourglassHalf, 'Pending');
    }
  }

  String _fmt(String t) {
    try {
      final p = t.split(':');
      int h = int.parse(p[0]);
      final m = p[1].padLeft(2, '0');
      final ap = h >= 12 ? 'PM' : 'AM';
      if (h == 0) h = 12; else if (h > 12) h -= 12;
      return '$h:$m $ap';
    } catch (_) { return t; }
  }

  String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) { return d; }
  }

  @override
  Widget build(BuildContext context) {
    final status = bookings.bookingStatus;
    final cfg    = _cfg(status);
    final canCancel = (status == 'pending' || status == 'confirmed') && onCancel != null;

    return GestureDetector(
      onTap: () {
        if (status == 'completed') {
          Navigator.pushNamed(context, '/tourCompletion', arguments: bookings.toJson());
        } else {
          Navigator.pushNamed(context, '/bookingStatus', arguments: bookings.toJson());
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Column(children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [cfg.color, cfg.colorDark], begin: Alignment.centerLeft, end: Alignment.centerRight)),
              child: Row(children: [
                Icon(cfg.icon, color: Colors.white, size: 13.w),
                SizedBox(width: 7.w),
                Text(cfg.label, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w800)),
                const Spacer(),
                Icon(CupertinoIcons.chevron_right, color: Colors.white.withOpacity(0.8), size: 13.w),
              ]),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                _photo(),
                SizedBox(width: 12.w),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                      bookings.guideName.isNotEmpty ? bookings.guideName : 'Your Guide',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: _dark),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 3.h),
                  if (bookings.cityName.isNotEmpty)
                    Row(children: [
                      Icon(CupertinoIcons.map_pin, color: _gray, size: 11.w),
                      SizedBox(width: 3.w),
                      Flexible(child: Text(bookings.cityName,
                          style: TextStyle(color: _gray, fontSize: 11.sp),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                ])),
              ]),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(color: _bgPage, borderRadius: BorderRadius.circular(14.r)),
              child: Column(children: [
                _infoRow(CupertinoIcons.calendar, _fmtDate(bookings.bookingDate.toString())),
                SizedBox(height: 6.h),
                _infoRow(CupertinoIcons.time, '${_fmt(bookings.startTime.toString())} – ${_fmt(bookings.endTime.toString())}'),
                SizedBox(height: 6.h),
                _infoRow(CupertinoIcons.money_dollar_circle, 'LKR ${bookings.totalAmount.toStringAsFixed(2)}'),
              ]),
            ),
            if (canCancel)
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmCancel(context),
                    icon: Icon(FontAwesomeIcons.ban, size: 12.w),
                    label: Text('Cancel Booking', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: _red,
                        side: BorderSide(color: _red.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        padding: EdgeInsets.symmetric(vertical: 10.h)),
                  ),
                ),
              )
            else SizedBox(height: 2.h),
          ]),
        ),
      ),
    );
  }

  Widget _photo() {
    final pic = bookings.guidePhoto;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: pic.isNotEmpty
          ? CachedNetworkImage(imageUrl: pic, width: 52.w, height: 60.h, fit: BoxFit.cover, placeholder: (_, __) => _photoFb(), errorWidget: (_, __, ___) => _photoFb())
          : _photoFb(),
    );
  }

  Widget _photoFb() => Container(width: 52.w, height: 60.h, decoration: BoxDecoration(color: _blue.withOpacity(0.08)), child: Icon(CupertinoIcons.person_fill, color: _blue.withOpacity(0.35), size: 22.w));

  Widget _infoRow(IconData icon, String value) => Row(children: [
    Icon(icon, color: _blue, size: 13.w),
    SizedBox(width: 8.w),
    Expanded(child: Text(value, style: TextStyle(color: _dark, fontSize: 12.sp, fontWeight: FontWeight.w600))),
  ]);

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('Cancel Booking?'),
        content: const Text('Are you sure you want to cancel this booking? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Keep', style: TextStyle(color: _gray))),
          ElevatedButton(
              onPressed: () { Navigator.pop(context); onCancel!(bookings.id.toString()); },
              style: ElevatedButton.styleFrom(backgroundColor: _red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)), elevation: 0),
              child: const Text('Cancel', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

class _StatusConfig {
  final Color color;
  final Color colorDark;
  final IconData icon;
  final String label;
  const _StatusConfig(this.color, this.colorDark, this.icon, this.label);
}