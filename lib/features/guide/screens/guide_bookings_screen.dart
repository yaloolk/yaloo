// lib/features/guide/screens/guide_bookings_screen.dart


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/features/tourist/models/guide_booking_model.dart';
import 'package:yaloo/features/tourist/services/guide_booking_service.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _blue   = Color(0xFF2563EB);
const _dark   = Color(0xFF1F2937);
const _gray   = Color(0xFF6B7280);
const _green  = Color(0xFF22C55E);
const _amber  = Color(0xFFF59E0B);
const _red    = Color(0xFFEF4444);
const _purple = Color(0xFF8B5CF6);
const _bg     = Color(0xFFF8FAFC);

class HostBookingsScreen extends StatefulWidget {
  const HostBookingsScreen({super.key});
  @override
  State<HostBookingsScreen> createState() => _State();
}

class _State extends State<HostBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _service = GuideBookingService();

  List<GuideBookingModel> _upcoming = [];
  bool   _upLoad = true;
  String _upErr  = '';

  List<GuideBookingModel> _history = [];
  bool   _hiLoad = true;
  String _hiErr  = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadUpcoming();
    _loadHistory();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadUpcoming() async {
    if (mounted) setState(() { _upLoad = true; _upErr = ''; });
    try {
      final list = await _service.getGuideUpcoming();
      if (mounted) setState(() { _upcoming = list; _upLoad = false; });
    } catch (e) {
      if (mounted) setState(() { _upErr = e.toString(); _upLoad = false; });
    }
  }

  Future<void> _loadHistory() async {
    if (mounted) setState(() { _hiLoad = true; _hiErr = ''; });
    try {
      final list = await _service.getGuideHistory();
      if (mounted) setState(() { _history = list; _hiLoad = false; });
    } catch (e) {
      if (mounted) setState(() { _hiErr = e.toString(); _hiLoad = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: CustomAppBar(title: 'My Bookings'),
      body: Column(children: [
        // ── Tab bar ───────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14.r),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.06), blurRadius: 10,
                    offset: const Offset(0, 2))]),
            child: TabBar(
              controller: _tabs,
              labelColor: Colors.white,
              unselectedLabelColor: _gray,
              labelStyle: TextStyle(
                  fontSize: 13.sp, fontWeight: FontWeight.w700),
              unselectedLabelStyle: TextStyle(
                  fontSize: 13.sp, fontWeight: FontWeight.w500),
              indicator: BoxDecoration(
                  color: _blue, borderRadius: BorderRadius.circular(12.r)),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available_outlined, size: 16.w),
                      SizedBox(width: 6.w),
                      Text('Upcoming'),
                      if (!_upLoad && _upcoming.isNotEmpty) ...[
                        SizedBox(width: 6.w),
                        _countBadge(_upcoming.length, _blue),
                      ],
                    ])),
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 16.w),
                      SizedBox(width: 6.w),
                      Text('History'),
                      if (!_hiLoad && _history.isNotEmpty) ...[
                        SizedBox(width: 6.w),
                        _countBadge(_history.length, _gray),
                      ],
                    ])),
              ],
            ),
          ),
        ),

        SizedBox(height: 8.h),

        // ── Tab views ─────────────────────────────────────────────────────
        Expanded(child: TabBarView(controller: _tabs, children: [
          _tabContent(
            loading: _upLoad,
            error: _upErr,
            items: _upcoming,
            onRefresh: _loadUpcoming,
            emptyMsg: 'No upcoming bookings',
            emptyIcon: CupertinoIcons.calendar,
          ),
          _tabContent(
            loading: _hiLoad,
            error: _hiErr,
            items: _history,
            onRefresh: _loadHistory,
            emptyMsg: 'No booking history yet',
            emptyIcon: Icons.history,
            isHistory: true,
          ),
        ])),
      ]),
    );
  }

  Widget _countBadge(int count, Color color) => Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10.r)),
      child: Text('$count', style: TextStyle(
          fontSize: 10.sp, fontWeight: FontWeight.w800, color: color)));

  Widget _tabContent({
    required bool loading,
    required String error,
    required List<GuideBookingModel> items,
    required Future<void> Function() onRefresh,
    required String emptyMsg,
    required IconData emptyIcon,
    bool isHistory = false,
  }) {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (error.isNotEmpty) return Center(child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(CupertinoIcons.exclamationmark_circle, color: _red, size: 40.w),
          SizedBox(height: 12.h),
          Text(error, textAlign: TextAlign.center,
              style: TextStyle(color: _dark, fontSize: 14.sp)),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)))),
        ])));

    if (items.isEmpty) return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(emptyIcon, size: 56.w, color: _gray.withOpacity(0.35)),
          SizedBox(height: 16.h),
          Text(emptyMsg, style: TextStyle(
              color: _gray, fontSize: 16.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.h),
          Text('Pull down to refresh',
              style: TextStyle(
                  color: _gray.withOpacity(0.6), fontSize: 13.sp)),
        ]));

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: _blue,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
        itemCount: items.length,
        itemBuilder: (_, i) => _bookingCard(items[i], isHistory: isHistory),
      ),
    );
  }

  Widget _bookingCard(GuideBookingModel b, {bool isHistory = false}) {
    final name   = b.touristName.isNotEmpty ? b.touristName : 'Tourist';
    final status = b.bookingStatus;
    final color  = _statusColor(status);

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 14,
              offset: const Offset(0, 4))]),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () async {
            await Navigator.pushNamed(
                context, '/guideTourRequestDetails',
                arguments: {'booking': b});
            // Refresh after returning (guide may have marked it complete)
            _loadUpcoming();
            _loadHistory();
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
                Row(children: [
                  Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: color.withOpacity(0.35), width: 2)),
                      child: CircleAvatar(
                          radius: 22.r,
                          backgroundColor: color.withOpacity(0.1),
                          backgroundImage: b.touristPhoto.isNotEmpty
                              ? CachedNetworkImageProvider(b.touristPhoto) : null,
                          child: b.touristPhoto.isEmpty
                              ? Icon(CupertinoIcons.person,
                              color: color, size: 16.w) : null)),
                  SizedBox(width: 12.w),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(
                            fontSize: 15.sp, fontWeight: FontWeight.w700,
                            color: _dark)),
                        SizedBox(height: 2.h),
                        Text('${b.guestCount} guest${b.guestCount > 1 ? 's' : ''}',
                            style: TextStyle(fontSize: 11.sp, color: _gray)),
                      ])),
                  _statusBadge(status),
                ]),

                Divider(height: 16.h,
                    color: Colors.black.withOpacity(0.06)),

                // ── Details ───────────────────────────────────────────────
                Row(children: [
                  Expanded(child: _infoChip(
                      FontAwesomeIcons.calendar, _fmtDate(b.bookingDate))),
                  SizedBox(width: 8.w),
                  Expanded(child: _infoChip(
                      FontAwesomeIcons.clock,
                      '${_fmtTime(b.startTime)} – ${_fmtTime(b.endTime)}')),
                ]),
                SizedBox(height: 8.h),
                Row(children: [
                  Expanded(child: _infoChip(
                      FontAwesomeIcons.userGroup,
                      '${b.guestCount} person${b.guestCount > 1 ? 's' : ''}')),
                  SizedBox(width: 8.w),
                  Expanded(child: _infoChip(
                      FontAwesomeIcons.dollarSign,
                      'LKR ${b.totalAmount.toStringAsFixed(0)}')),
                ]),

                // Payment / tip (history)
                if (isHistory && b.bookingStatus == 'completed') ...[
                  SizedBox(height: 10.h),
                  Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                          color: _green.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                              color: _green.withOpacity(0.2))),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Earnings received',
                                style: TextStyle(fontSize: 12.sp,
                                    color: _green, fontWeight: FontWeight.w600)),
                            Text('LKR ${b.totalAmount.toStringAsFixed(0)}',
                                style: TextStyle(fontSize: 13.sp,
                                    color: _green, fontWeight: FontWeight.w800)),
                          ])),
                ],

                // Guide response note
                if (b.guideResponseNote != null &&
                    b.guideResponseNote!.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                          color: _blue.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                              color: _blue.withOpacity(0.1))),
                      child: Row(children: [
                        Icon(FontAwesomeIcons.circleInfo,
                            size: 11.w, color: _blue),
                        SizedBox(width: 8.w),
                        Expanded(child: Text(b.guideResponseNote!,
                            style: TextStyle(fontSize: 11.sp,
                                color: _dark, fontStyle: FontStyle.italic),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis)),
                      ])),
                ],

                // View details prompt
                SizedBox(height: 10.h),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('View Details →', style: TextStyle(
                          color: _blue, fontSize: 12.sp,
                          fontWeight: FontWeight.w700)),
                    ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) => Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
          color: _bg, borderRadius: BorderRadius.circular(10.r)),
      child: Row(children: [
        Icon(icon, size: 11.w, color: _gray),
        SizedBox(width: 6.w),
        Expanded(child: Text(text, style: TextStyle(
            fontSize: 11.sp, color: _dark, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis)),
      ]));

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    final label = status[0].toUpperCase() + status.substring(1);
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: color.withOpacity(0.3))),
        child: Text(label, style: TextStyle(
            color: color, fontSize: 11.sp, fontWeight: FontWeight.w700)));
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed':  return _green;
      case 'completed':  return _blue;
      case 'rejected':   return _red;
      case 'cancelled':  return _gray;
      default:           return _amber;
    }
  }

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