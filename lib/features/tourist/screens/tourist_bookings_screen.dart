// lib/features/tourist/screens/tourist_bookings_screen.dart


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/features/tourist/models/guide_booking_model.dart';
import 'package:yaloo/features/tourist/services/guide_booking_service.dart';

// ── Design tokens (mirrors tourist_home_screen) ───────────────────────────────
const _blue       = Color(0xFF2563EB);
const _blueDark   = Color(0xFF1D4ED8);
const _blueDarker = Color(0xFF1E40AF);
const _bg         = Color(0xFFF8FAFC);
const _dark       = Color(0xFF1F2937);
const _gray       = Color(0xFF6B7280);
const _amber      = Color(0xFFF59E0B);
const _green      = Color(0xFF10B981);
const _red        = Color(0xFFEF4444);

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});
  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  final _service = GuideBookingService();
  late final TabController _tabs;

  List<GuideBookingModel> _all = [];
  bool   _loading = true;
  String _error   = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = ''; });
    try {
      final list = await _service.getMyBookings();
      if (mounted) setState(() { _all = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<GuideBookingModel> _filtered(String? status) {
    if (status == null) return _all;
    return _all.where((b) => b.bookingStatus == status).toList();
  }

  List<GuideBookingModel> get _upcoming =>
      _all.where((b) => b.bookingStatus == 'pending' ||
          b.bookingStatus == 'confirmed').toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(children: [
          _header(),
          _tabBar(),
          Expanded(child: TabBarView(controller: _tabs, children: [
            _tabBody(null),
            _tabBody('upcoming'),   // pending + confirmed
            _tabBody('completed'),
            _tabBody('cancelled'),  // cancelled + rejected
          ])),
        ]),
      ),
    );
  }

  // ── HEADER — blue gradient matching home screen ───────────────────────────
  Widget _header() => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [_blue, _blueDark, _blueDarker],
            begin: Alignment.topLeft, end: Alignment.bottomRight)),
    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('My Bookings', style: TextStyle(
            color: Colors.white, fontSize: 26.sp,
            fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        _glassChip('${_all.length} total'),
      ]),
      SizedBox(height: 6.h),
      Text('Track your guide tours & experiences',
          style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 13.sp, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _glassChip(String label) => Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withOpacity(0.3))),
      child: Text(label, style: TextStyle(
          color: Colors.white, fontSize: 12.sp,
          fontWeight: FontWeight.w600)));

  // ── TAB BAR ───────────────────────────────────────────────────────────────
  Widget _tabBar() => Container(
    color: Colors.white,
    child: TabBar(
      controller: _tabs,
      labelColor: _blue,
      unselectedLabelColor: _gray,
      labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontSize: 12.sp),
      indicatorColor: _blue,
      indicatorWeight: 2.5,
      tabs: [
        _tab('All',       _all.length),
        _tab('Upcoming',  _upcoming.length),
        _tab('Completed', _filtered('completed').length),
        _tab('Cancelled', _filtered('cancelled').length +
            _filtered('rejected').length),
      ],
    ),
  );

  Widget _tab(String label, int count) => Tab(
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label),
        if (count > 0) ...[
          SizedBox(width: 4.w),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              decoration: BoxDecoration(
                  color: _blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.r)),
              child: Text('$count', style: TextStyle(
                  fontSize: 9.sp, color: _blue, fontWeight: FontWeight.w800))),
        ],
      ]));

  // ── TAB BODY ──────────────────────────────────────────────────────────────
  Widget _tabBody(String? statusFilter) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error.isNotEmpty) return Center(child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(CupertinoIcons.exclamationmark_circle, color: _red, size: 40.w),
          SizedBox(height: 12.h),
          Text(_error, textAlign: TextAlign.center,
              style: TextStyle(color: _dark, fontSize: 13.sp)),
          SizedBox(height: 16.h),
          ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r))),
              child: const Text('Retry', style: TextStyle(color: Colors.white))),
        ])));

    // determine list for this tab
    List<GuideBookingModel> items;
    if (statusFilter == null) {
      items = _all;
    } else if (statusFilter == 'upcoming') {
      items = _upcoming;
    } else if (statusFilter == 'cancelled') {
      items = [..._filtered('cancelled'), ..._filtered('rejected')];
    } else {
      items = _filtered(statusFilter);
    }

    if (items.isEmpty) return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.calendar, size: 52.w,
              color: _gray.withOpacity(0.3)),
          SizedBox(height: 14.h),
          Text('No bookings here', style: TextStyle(
              color: _gray, fontSize: 15.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 6.h),
          Text('Pull down to refresh',
              style: TextStyle(color: _gray.withOpacity(0.6), fontSize: 12.sp)),
        ]));

    return RefreshIndicator(
      onRefresh: _load,
      color: _blue,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
        itemCount: items.length,
        itemBuilder: (_, i) => _card(items[i]),
      ),
    );
  }

  // ── BOOKING CARD ──────────────────────────────────────────────────────────
  Widget _card(GuideBookingModel b) {
    final sInfo = _statusInfo(b.bookingStatus);
    final name  = b.guideName.isNotEmpty ? b.guideName : 'Guide';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.06), blurRadius: 14,
              offset: const Offset(0, 4))]),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () {
            if (b.bookingStatus == 'completed') {
              Navigator.pushNamed(context, '/tourCompletion', arguments: b);
            } else {
              Navigator.pushNamed(context, '/bookingStatus', arguments: b);
            }
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(children: [
              // Avatar
              Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: sInfo['color'].withOpacity(0.3), width: 2)),
                  child: CircleAvatar(
                      radius: 24.r,
                      backgroundColor: sInfo['color'].withOpacity(0.1),
                      backgroundImage: b.guidePhoto.isNotEmpty
                          ? CachedNetworkImageProvider(b.guidePhoto) : null,
                      child: b.guidePhoto.isEmpty
                          ? Icon(CupertinoIcons.person,
                          color: sInfo['color'], size: 18.w) : null)),

              SizedBox(width: 14.w),

              // Info
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(
                        fontSize: 15.sp, fontWeight: FontWeight.w700,
                        color: _dark)),
                    SizedBox(height: 3.h),
                    Row(children: [
                      Icon(FontAwesomeIcons.calendar,
                          size: 10.w, color: _gray),
                      SizedBox(width: 5.w),
                      Text(_fmtDate(b.bookingDate),
                          style: TextStyle(fontSize: 12.sp, color: _gray)),
                      SizedBox(width: 10.w),
                      Icon(FontAwesomeIcons.clock,
                          size: 10.w, color: _gray),
                      SizedBox(width: 5.w),
                      Text('${_fmtTime(b.startTime)} – ${_fmtTime(b.endTime)}',
                          style: TextStyle(fontSize: 12.sp, color: _gray)),
                    ]),
                    SizedBox(height: 4.h),
                    Row(children: [
                      Icon(FontAwesomeIcons.locationDot,
                          size: 10.w, color: _gray),
                      SizedBox(width: 5.w),
                      Text(b.cityName.isNotEmpty ? b.cityName : 'Sri Lanka',
                          style: TextStyle(fontSize: 12.sp, color: _gray)),
                      SizedBox(width: 10.w),
                      Text('LKR ${b.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 12.sp, color: _dark,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ])),

              SizedBox(width: 10.w),

              // Status chip + arrow
              Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 9.w, vertical: 5.h),
                        decoration: BoxDecoration(
                            color: sInfo['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                                color: sInfo['color'].withOpacity(0.3))),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(sInfo['icon'], size: 10.w,
                              color: sInfo['color']),
                          SizedBox(width: 4.w),
                          Text(sInfo['label'], style: TextStyle(
                              color: sInfo['color'], fontSize: 10.sp,
                              fontWeight: FontWeight.w700)),
                        ])),
                    SizedBox(height: 8.h),
                    Icon(CupertinoIcons.chevron_right,
                        size: 14.w, color: _gray.withOpacity(0.5)),
                  ]),
            ]),
          ),
        ),
      ),
    );
  }

  // ── STATUS CONFIG ─────────────────────────────────────────────────────────
  Map<String, dynamic> _statusInfo(String s) {
    switch (s) {
      case 'confirmed':
        return {'label': 'Confirmed', 'color': _green,
          'icon': FontAwesomeIcons.circleCheck};
      case 'completed':
        return {'label': 'Completed', 'color': _blue,
          'icon': FontAwesomeIcons.flagCheckered};
      case 'cancelled':
        return {'label': 'Cancelled', 'color': _gray,
          'icon': FontAwesomeIcons.ban};
      case 'rejected':
        return {'label': 'Declined', 'color': _red,
          'icon': FontAwesomeIcons.xmark};
      default: // pending
        return {'label': 'Pending', 'color': _amber,
          'icon': FontAwesomeIcons.clock};
    }
  }

  // ── FORMATTERS ────────────────────────────────────────────────────────────
  String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      const m = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month - 1]}';
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