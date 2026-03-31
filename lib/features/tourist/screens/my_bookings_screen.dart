// lib/features/tourist/screens/my_bookings_screen.dart


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../models/guide_booking_model.dart';
import '../models/stay_booking_model.dart';
import '../providers/guide_booking_provider.dart';
import '../providers/stay_booking_provider.dart';

const _blue       = Color(0xFF2563EB);
const _blueDark   = Color(0xFF1D4ED8);
const _blueDarker = Color(0xFF1E40AF);
const _bg         = Color(0xFFF8FAFC);
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
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuideBookingProvider>().loadMyBookings();
      context.read<StayBookingProvider>().loadMyBookings();
    });
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130.h),
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_blue, _blueDark, _blueDarker],
                  begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: SafeArea(bottom: false, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0), child: Row(children: [
                Container(padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r)),
                    child: Icon(CupertinoIcons.calendar, color: Colors.white, size: 20.w)),
                SizedBox(width: 12.w),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('My Bookings', style: TextStyle(color: Colors.white, fontSize: 20.sp,
                      fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  Text('Track all your bookings',
                      style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12.sp)),
                ]),
              ])),
              SizedBox(height: 8.h),
              TabBar(
                controller: _tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.55),
                labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                unselectedLabelStyle: TextStyle(fontSize: 14.sp),
                indicator: UnderlineTabIndicator(
                    borderSide: const BorderSide(width: 2.5, color: Colors.white),
                    insets: EdgeInsets.symmetric(horizontal: 24.w)),
                tabs: const [
                  Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.explore, size: 16), SizedBox(width: 6), Text('Guide Tours'),
                  ])),
                  Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.house_outlined, size: 16), SizedBox(width: 6), Text('Stays'),
                  ])),
                ],
              ),
            ],
          )),
        ),
      ),
      body: TabBarView(controller: _tab, children: [
        _GuideBookingsTab(),
        _StayBookingsTab(),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — Guide Bookings
// ─────────────────────────────────────────────────────────────────────────────
class _GuideBookingsTab extends StatefulWidget {
  @override State<_GuideBookingsTab> createState() => _GuideBookingsTabState();
}

class _GuideBookingsTabState extends State<_GuideBookingsTab>
    with SingleTickerProviderStateMixin {
  late TabController _inner;
  @override
  void initState() {
    super.initState();
    _inner = TabController(length: 5, vsync: this);
  }
  @override
  void dispose() { _inner.dispose(); super.dispose(); }

  List<GuideBookingModel> _filter(List<GuideBookingModel> all, String? s) {
    if (s == null) return all;
    if (s == 'upcoming') return all.where((b) => b.bookingStatus == 'pending' || b.bookingStatus == 'confirmed').toList();
    if (s == 'cancelled') return all.where((b) => b.bookingStatus == 'cancelled' || b.bookingStatus == 'rejected').toList();
    return all.where((b) => b.bookingStatus == s).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GuideBookingProvider>(
      builder: (_, prov, __) {
        if (prov.bookingsLoading) return const Center(child: CircularProgressIndicator(color: _blue));
        return Column(children: [
          Container(color: Colors.white, child: TabBar(
            controller: _inner, isScrollable: true, tabAlignment: TabAlignment.start,
            labelColor: _blue, unselectedLabelColor: _gray,
            labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
            indicatorColor: _blue, indicatorWeight: 2.5,
            tabs: [
              _tab('All', prov.myBookings.length),
              _tab('Upcoming', _filter(prov.myBookings, 'upcoming').length),
              _tab('Completed', _filter(prov.myBookings, 'completed').length),
              _tab('Cancelled', _filter(prov.myBookings, 'cancelled').length),
              _tab('Pending', _filter(prov.myBookings, 'pending').length),
            ],
          )),
          Expanded(child: TabBarView(controller: _inner, children: [
            _GuideList(bookings: prov.myBookings,                        onCancel: _cancel),
            _GuideList(bookings: _filter(prov.myBookings, 'upcoming'),   onCancel: _cancel),
            _GuideList(bookings: _filter(prov.myBookings, 'completed'),  onCancel: null),
            _GuideList(bookings: _filter(prov.myBookings, 'cancelled'),  onCancel: null),
            _GuideList(bookings: _filter(prov.myBookings, 'pending'),    onCancel: _cancel),
          ])),
        ]);
      },
    );
  }

  Tab _tab(String label, int count) => Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
    Text(label),
    if (count > 0) ...[SizedBox(width: 4.w),
      Container(padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
          decoration: BoxDecoration(color: _blue.withOpacity(0.12), borderRadius: BorderRadius.circular(10.r)),
          child: Text('$count', style: TextStyle(fontSize: 9.sp, color: _blue, fontWeight: FontWeight.w800)))],
  ]));

  Future<void> _cancel(String bookingId) async {
    final prov = context.read<GuideBookingProvider>();
    final ok = await prov.cancelBooking(bookingId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Booking cancelled' : 'Failed to cancel'),
        backgroundColor: ok ? _green : _red, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ));
    }
  }
}

class _GuideList extends StatelessWidget {
  final List<GuideBookingModel> bookings;
  final Future<void> Function(String)? onCancel;
  const _GuideList({required this.bookings, this.onCancel});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) return _empty('No guide bookings', Icons.explore_outlined);
    return RefreshIndicator(color: _blue,
      onRefresh: () => context.read<GuideBookingProvider>().loadMyBookings(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 32.h),
        physics: const BouncingScrollPhysics(),
        itemCount: bookings.length,
        itemBuilder: (_, i) => _GuideCard(booking: bookings[i], onCancel: onCancel),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final GuideBookingModel booking;
  final Future<void> Function(String)? onCancel;
  const _GuideCard({required this.booking, this.onCancel});

  _StatusCfg get _cfg {
    switch (booking.bookingStatus) {
      case 'confirmed': return _StatusCfg(_green, const Color(0xFF059669), FontAwesomeIcons.circleCheck, 'Confirmed');
      case 'completed': return _StatusCfg(_blue, _blueDark, FontAwesomeIcons.flagCheckered, 'Completed');
      case 'rejected':  return _StatusCfg(_red, const Color(0xFFB91C1C), FontAwesomeIcons.circleXmark, 'Rejected');
      case 'cancelled': return _StatusCfg(_gray, const Color(0xFF4B5563), FontAwesomeIcons.ban, 'Cancelled');
      default:          return _StatusCfg(_amber, const Color(0xFFD97706), FontAwesomeIcons.hourglassHalf, 'Pending');
    }
  }

  String _fd(String d) {
    try { final dt = DateTime.parse(d);
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month-1]}'; } catch (_) { return d; }
  }
  String _ft(String t) {
    try { final p = t.split(':'); int h = int.parse(p[0]); final m = p[1].padLeft(2,'0');
    final ap = h >= 12 ? 'PM' : 'AM'; if (h == 0) h = 12; else if (h > 12) h -= 12;
    return '$h:$m $ap'; } catch (_) { return t; }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _cfg;
    final canCancel = (booking.bookingStatus == 'pending' || booking.bookingStatus == 'confirmed') && onCancel != null;

    return GestureDetector(
      onTap: () {
        if (booking.bookingStatus == 'completed') {
          Navigator.pushNamed(context, '/tourCompletion', arguments: booking.toJson());
        } else {
          Navigator.pushNamed(context, '/bookingStatus', arguments: booking.toJson());
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 4))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Column(children: [
            // Status banner
            Container(padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [cfg.color, cfg.colorDark],
                    begin: Alignment.centerLeft, end: Alignment.centerRight)),
                child: Row(children: [
                  Icon(cfg.icon, color: Colors.white, size: 12.w), SizedBox(width: 6.w),
                  Text(cfg.label, style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text('Guide Tour', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10.sp)),
                ])),
            Padding(padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 10.h), child: Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(10.r),
                  child: booking.guidePhoto.isNotEmpty
                      ? CachedNetworkImage(imageUrl: booking.guidePhoto, width: 50.w, height: 58.h, fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _photoFb())
                      : _photoFb()),
              SizedBox(width: 12.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(booking.guideName.isNotEmpty ? booking.guideName : 'Guide',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: _dark),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 2.h),
                Text('${_fd(booking.bookingDate.toString())}  ·  ${_ft(booking.startTime.toString())} – ${_ft(booking.endTime.toString())}',
                    style: TextStyle(color: _gray, fontSize: 11.sp)),
                Text('LKR ${booking.totalAmount.toStringAsFixed(0)}  ·  ${booking.cityName}',
                    style: TextStyle(color: _dark, fontSize: 11.sp, fontWeight: FontWeight.w700)),
              ])),
            ])),
            if (canCancel) Padding(padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
                child: SizedBox(width: double.infinity, child: OutlinedButton(
                  onPressed: () => _askCancel(context),
                  style: OutlinedButton.styleFrom(foregroundColor: _red,
                      side: BorderSide(color: _red.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 8.h)),
                  child: Text('Cancel', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                )))
            else SizedBox(height: 4.h),
          ]),
        ),
      ),
    );
  }

  Widget _photoFb() => Container(width: 50.w, height: 58.h, color: _blue.withOpacity(0.08),
      child: Icon(CupertinoIcons.person_fill, color: _blue.withOpacity(0.35), size: 20.w));

  void _askCancel(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: const Text('Cancel Booking?'),
      content: const Text('This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Keep', style: TextStyle(color: _gray))),
        ElevatedButton(onPressed: () { Navigator.pop(context); onCancel!(booking.id.toString()); },
            style: ElevatedButton.styleFrom(backgroundColor: _red, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
            child: const Text('Cancel', style: TextStyle(color: Colors.white))),
      ],
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — Stay Bookings
// ─────────────────────────────────────────────────────────────────────────────
class _StayBookingsTab extends StatefulWidget {
  @override State<_StayBookingsTab> createState() => _StayBookingsTabState();
}

class _StayBookingsTabState extends State<_StayBookingsTab>
    with SingleTickerProviderStateMixin {
  late TabController _inner;
  @override void initState() { super.initState(); _inner = TabController(length: 5, vsync: this); }
  @override void dispose() { _inner.dispose(); super.dispose(); }

  List<StayBookingModel> _filter(List<StayBookingModel> all, String? s) {
    if (s == null) return all;
    if (s == 'upcoming') return all.where((b) => b.bookingStatus == 'pending' || b.bookingStatus == 'confirmed').toList();
    if (s == 'cancelled') return all.where((b) => b.bookingStatus == 'cancelled' || b.bookingStatus == 'rejected').toList();
    return all.where((b) => b.bookingStatus == s).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StayBookingProvider>(
      builder: (_, prov, __) {
        if (prov.myLoading) return const Center(child: CircularProgressIndicator(color: _blue));
        return Column(children: [
          Container(color: Colors.white, child: TabBar(
            controller: _inner, isScrollable: true, tabAlignment: TabAlignment.start,
            labelColor: _blue, unselectedLabelColor: _gray,
            labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
            indicatorColor: _blue, indicatorWeight: 2.5,
            tabs: [
              _tab('All', prov.myBookings.length),
              _tab('Upcoming', _filter(prov.myBookings, 'upcoming').length),
              _tab('Completed', _filter(prov.myBookings, 'completed').length),
              _tab('Cancelled', _filter(prov.myBookings, 'cancelled').length),
              _tab('Pending', _filter(prov.myBookings, 'pending').length),
            ],
          )),
          Expanded(child: TabBarView(controller: _inner, children: [
            _StayList(bookings: prov.myBookings,                        onCancel: _cancel, showReview: false),
            _StayList(bookings: _filter(prov.myBookings, 'upcoming'),   onCancel: _cancel, showReview: false),
            _StayList(bookings: _filter(prov.myBookings, 'completed'),  onCancel: null,    showReview: true),
            _StayList(bookings: _filter(prov.myBookings, 'cancelled'),  onCancel: null,    showReview: false),
            _StayList(bookings: _filter(prov.myBookings, 'pending'),    onCancel: _cancel, showReview: false),
          ])),
        ]);
      },
    );
  }

  Tab _tab(String label, int count) => Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
    Text(label),
    if (count > 0) ...[SizedBox(width: 4.w),
      Container(padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
          decoration: BoxDecoration(color: _blue.withOpacity(0.12), borderRadius: BorderRadius.circular(10.r)),
          child: Text('$count', style: TextStyle(fontSize: 9.sp, color: _blue, fontWeight: FontWeight.w800)))],
  ]));

  Future<void> _cancel(String bookingId) async {
    final prov = context.read<StayBookingProvider>();
    final ok = await prov.cancelBooking(bookingId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Booking cancelled' : 'Failed to cancel'),
        backgroundColor: ok ? _green : _red, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ));
    }
  }
}

class _StayList extends StatelessWidget {
  final List<StayBookingModel> bookings;
  final Future<void> Function(String)? onCancel;
  final bool showReview;
  const _StayList({required this.bookings, this.onCancel, required this.showReview});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) return _empty('No stay bookings', Icons.house_outlined);
    return RefreshIndicator(color: _blue,
      onRefresh: () => context.read<StayBookingProvider>().loadMyBookings(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 32.h),
        physics: const BouncingScrollPhysics(),
        itemCount: bookings.length,
        itemBuilder: (_, i) => _StayCard(booking: bookings[i], onCancel: onCancel, showReview: showReview),
      ),
    );
  }
}

class _StayCard extends StatelessWidget {
  final StayBookingModel booking;
  final Future<void> Function(String)? onCancel;
  final bool showReview;
  const _StayCard({required this.booking, this.onCancel, required this.showReview});

  _StatusCfg get _cfg {
    switch (booking.bookingStatus) {
      case 'confirmed': return _StatusCfg(_green, const Color(0xFF059669), FontAwesomeIcons.circleCheck, 'Confirmed');
      case 'completed': return _StatusCfg(_blue, _blueDark, FontAwesomeIcons.flagCheckered, 'Completed');
      case 'rejected':  return _StatusCfg(_red, const Color(0xFFB91C1C), FontAwesomeIcons.circleXmark, 'Rejected');
      case 'cancelled': return _StatusCfg(_gray, const Color(0xFF4B5563), FontAwesomeIcons.ban, 'Cancelled');
      default:          return _StatusCfg(_amber, const Color(0xFFD97706), FontAwesomeIcons.hourglassHalf, 'Pending');
    }
  }

  String _fd(String d) {
    try { final dt = DateTime.parse(d);
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month-1]}'; } catch (_) { return d; }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _cfg;
    final canCancel = (booking.bookingStatus == 'pending' || booking.bookingStatus == 'confirmed') && onCancel != null;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/stayBookingStatus', arguments: booking.toJson()),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 4))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Column(children: [
            Container(padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [cfg.color, cfg.colorDark],
                    begin: Alignment.centerLeft, end: Alignment.centerRight)),
                child: Row(children: [
                  Icon(cfg.icon, color: Colors.white, size: 12.w), SizedBox(width: 6.w),
                  Text(cfg.label, style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text('Homestay', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10.sp)),
                ])),
            Padding(padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 10.h), child: Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(10.r),
                  child: booking.stayCoverPhoto.isNotEmpty
                      ? CachedNetworkImage(imageUrl: booking.stayCoverPhoto, width: 50.w, height: 58.h, fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _stayFb())
                      : _stayFb()),
              SizedBox(width: 12.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(booking.stayName.isNotEmpty ? booking.stayName : 'Stay',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: _dark),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 2.h),
                Text('${_fd(booking.checkinDate)} → ${_fd(booking.checkoutDate)}  (${booking.totalNights} nights)',
                    style: TextStyle(color: _gray, fontSize: 11.sp)),
                Text('LKR ${booking.totalAmount.toStringAsFixed(0)}  ·  ${booking.cityName}',
                    style: TextStyle(color: _dark, fontSize: 11.sp, fontWeight: FontWeight.w700)),
              ])),
            ])),
            if (canCancel)
              Padding(padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
                  child: SizedBox(width: double.infinity, child: OutlinedButton(
                    onPressed: () => _askCancel(context),
                    style: OutlinedButton.styleFrom(foregroundColor: _red,
                        side: BorderSide(color: _red.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 8.h)),
                    child: Text('Cancel', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                  )))
            else if (showReview && booking.bookingStatus == 'completed')
              Padding(padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
                  child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/stayReview', arguments: booking),
                    icon: Icon(FontAwesomeIcons.solidStar, size: 12.w),
                    label: Text('Leave Review', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(backgroundColor: _amber, foregroundColor: Colors.white,
                        elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 9.h)),
                  )))
            else SizedBox(height: 4.h),
          ]),
        ),
      ),
    );
  }

  Widget _stayFb() => Container(width: 50.w, height: 58.h, color: _blue.withOpacity(0.08),
      child: Icon(CupertinoIcons.house, color: _blue.withOpacity(0.35), size: 20.w));

  void _askCancel(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: const Text('Cancel Booking?'), content: const Text('This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Keep', style: TextStyle(color: _gray))),
        ElevatedButton(onPressed: () { Navigator.pop(context); onCancel!(booking.id); },
            style: ElevatedButton.styleFrom(backgroundColor: _red, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
            child: const Text('Cancel', style: TextStyle(color: Colors.white))),
      ],
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
class _StatusCfg {
  final Color color, colorDark;
  final IconData icon;
  final String label;
  const _StatusCfg(this.color, this.colorDark, this.icon, this.label);
}

Widget _empty(String msg, IconData icon) => Center(child: Column(
    mainAxisSize: MainAxisSize.min, children: [
  Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(
      color: _blue.withOpacity(0.07), shape: BoxShape.circle),
      child: Icon(icon, color: _blue, size: 48)),
  const SizedBox(height: 16),
  Text(msg, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _dark)),
  const SizedBox(height: 6),
  Text('Your bookings will appear here', style: TextStyle(color: _gray, fontSize: 13)),
]));