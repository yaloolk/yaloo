// lib/features/guide/screens/guide_home_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:yaloo/features/guide/providers/guide_provider.dart';
import 'package:yaloo/features/tourist/models/guide_booking_model.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _blue       = Color(0xFF2563EB);
const _blueDark   = Color(0xFF1D4ED8);
const _blueDarker = Color(0xFF1E40AF);
const _bg         = Color(0xFFF8FAFC);
const _dark       = Color(0xFF1F2937);
const _gray       = Color(0xFF6B7280);
const _amber      = Color(0xFFF59E0B);
const _green      = Color(0xFF22C55E);
const _purple     = Color(0xFF8B5CF6);
const _red        = Color(0xFFEF4444);

class GuideHomeScreen extends StatelessWidget {
  const GuideHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch provider — rebuilds automatically when data changes
    final provider = context.watch<GuideProvider>();
    return _GuideHomeView(provider: provider);
  }
}

class _GuideHomeView extends StatefulWidget {
  final GuideProvider provider;
  const _GuideHomeView({required this.provider});

  @override
  State<_GuideHomeView> createState() => _GuideHomeViewState();
}

class _GuideHomeViewState extends State<_GuideHomeView> {
  GuideProvider get _p => widget.provider;

  // ── Convenience getters from provider ────────────────────────────────────
  String get _name    => _p.profile?.fullName ?? '';
  String? get _picUrl => _p.profile?.profilePic.isNotEmpty == true
      ? _p.profile!.profilePic : null;
  bool get _isAvailable => _p.profile?.isAvailable ?? true;
  double get _avgRating  => _p.profile?.avgRating ?? 0;

  // ── Accept / reject ───────────────────────────────────────────────────────

  Future<void> _accept(GuideBookingModel b) async {
    try {
      await _p.respondToBooking(bookingId: b.id, action: 'accept');
      _snack('Booking accepted ✓', _green);
    } catch (e) {
      _snack(e.toString(), _red);
    }
  }

  Future<void> _reject(GuideBookingModel b) async {
    try {
      await _p.respondToBooking(bookingId: b.id, action: 'reject');
      _snack('Booking declined', _gray);
    } catch (e) {
      _snack(e.toString(), _red);
    }
  }

  void _snack(String msg, Color bg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    ));
  }

  // ── Pull-to-refresh: resets guards so a full re-fetch happens ─────────────
  Future<void> _onRefresh() => _p.refreshAll();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: _blue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 8.h),
              _heroHeader(),
              SizedBox(height: 20.h),
              _searchBar(),
              SizedBox(height: 24.h),
              _quickStats(),
              SizedBox(height: 24.h),
              _sectionHeader('Tour Requests',
                  onSeeAll: () => Navigator.pushNamed(context, '/guideTourRequests')),
              SizedBox(height: 16.h),
              _requestsList(),
              SizedBox(height: 24.h),
              _sectionHeader('Upcoming Bookings',
                  onSeeAll: () => Navigator.pushNamed(context, '/guideBookings')),
              SizedBox(height: 16.h),
              _upcomingList(),
              SizedBox(height: 24.h),
              _inviteBanner(),
              SizedBox(height: 60.h),
            ]),
          ),
        ),
      ),
    );
  }

  // ── HERO HEADER ───────────────────────────────────────────────────────────
  Widget _heroHeader() {
    final first = _name.trim().split(' ').first;
    final loading = _p.profileLoading;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [_blue, _blueDark, _blueDarker],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [BoxShadow(
            color: _blue.withOpacity(0.38), blurRadius: 32,
            offset: const Offset(0, 14), spreadRadius: -6)],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 16.w, 24.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Top row ──
          Row(children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/guideProfile'),
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2.5),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.18), blurRadius: 10,
                        offset: const Offset(0, 4))]),
                child: CircleAvatar(
                    radius: 22.r,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: _picUrl != null
                        ? CachedNetworkImageProvider(_picUrl!) : null,
                    child: _picUrl == null
                        ? Icon(CupertinoIcons.person_fill,
                        color: Colors.white, size: 20.w) : null),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(child: loading
                ? Container(height: 14.h, width: 90.w,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(6.r)))
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Welcome back 👋', style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 12.sp, fontWeight: FontWeight.w500)),
              SizedBox(height: 2.h),
              Text(first.isEmpty ? 'Guide' : first, style: TextStyle(
                  color: Colors.white, fontSize: 18.sp,
                  fontWeight: FontWeight.w800, letterSpacing: -0.4),
                  overflow: TextOverflow.ellipsis),
            ])),
            _glassBtn(CupertinoIcons.gear,
                    () => Navigator.pushNamed(context, '/settings')),
            SizedBox(width: 8.w),
            Stack(children: [
              _glassBtn(CupertinoIcons.bell, () {}),
              Positioned(top: 6.h, right: 6.w,
                  child: Container(width: 8.w, height: 8.h,
                      decoration: const BoxDecoration(
                          color: _amber, shape: BoxShape.circle))),
            ]),
          ]),

          SizedBox(height: 20.h),
          Text('Your Guide', style: TextStyle(
              color: Colors.white, fontSize: 24.sp,
              fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          Text('Dashboard', style: TextStyle(
              color: Colors.white.withOpacity(0.65), fontSize: 24.sp,
              fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          SizedBox(height: 16.h),

          // Available badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: Colors.white.withOpacity(0.3))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8.w, height: 8.h,
                  decoration: BoxDecoration(
                      color: _isAvailable ? _green : _red,
                      shape: BoxShape.circle)),
              SizedBox(width: 7.w),
              Text(_isAvailable ? 'Available for tours' : 'Not available',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 12.sp, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _glassBtn(IconData icon, VoidCallback fn) => GestureDetector(
      onTap: fn,
      child: Container(
          padding: EdgeInsets.all(9.w),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.white.withOpacity(0.28))),
          child: Icon(icon, color: Colors.white, size: 20.w)));

  // ── SEARCH BAR ────────────────────────────────────────────────────────────
  Widget _searchBar() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.045), blurRadius: 16,
              offset: const Offset(0, 4))]),
      child: Row(children: [
        Expanded(child: TextField(
            decoration: InputDecoration(
                hintText: 'Search requests, bookings…',
                hintStyle: TextStyle(color: _gray, fontSize: 14.sp),
                prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass,
                    color: _gray, size: 17.w),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 16.h)))),
        Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                    color: _blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14.r)),
                child: Icon(FontAwesomeIcons.sliders, color: _blue, size: 17.w))),
      ]),
    ),
  );

  // ── QUICK STATS ───────────────────────────────────────────────────────────
  Widget _quickStats() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Row(children: [
      Expanded(child: _statCard(Icons.assignment_outlined,
          _p.requestsLoading ? '…' : '${_p.requests.length}', 'Requests', _blue)),
      SizedBox(width: 12.w),
      Expanded(child: _statCard(Icons.event_available_outlined,
          _p.upcomingLoading ? '…' : '${_p.upcoming.length}', 'Upcoming', _purple)),
      SizedBox(width: 12.w),
      Expanded(child: _statCard(Icons.star_rounded,
          _p.profileLoading ? '…' : _avgRating.toStringAsFixed(1),
          'Rating', _amber)),
    ]),
  );

  Widget _statCard(IconData icon, String val, String label, Color color) =>
      Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20.r),
            boxShadow: [BoxShadow(
                color: color.withOpacity(0.15), blurRadius: 16,
                offset: const Offset(0, 6), spreadRadius: -4)]),
        child: Column(children: [
          Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r)),
              child: Icon(icon, color: color, size: 22)),
          SizedBox(height: 8.h),
          Text(val, style: TextStyle(
              fontSize: 20.sp, fontWeight: FontWeight.w800, color: _dark)),
          Text(label, style: TextStyle(
              fontSize: 12.sp, color: _gray, fontWeight: FontWeight.w500)),
        ]),
      );

  // ── SECTION HEADER ────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, {required VoidCallback onSeeAll}) =>
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(
                    fontSize: 18.sp, fontWeight: FontWeight.w800,
                    color: _dark, letterSpacing: -0.3)),
                GestureDetector(
                    onTap: onSeeAll,
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                            color: _blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20.r)),
                        child: Text('See All', style: TextStyle(
                            color: _blue, fontSize: 12.sp,
                            fontWeight: FontWeight.w700)))),
              ]));

  // ── TOUR REQUESTS LIST ────────────────────────────────────────────────────
  Widget _requestsList() {
    if (_p.requestsLoading) {
      return SizedBox(height: 170.h,
          child: const Center(child: CircularProgressIndicator()));
    }
    if (_p.requestsError.isNotEmpty) {
      return _errBanner(_p.requestsError, () {
        _p.loadRequests();
      });
    }
    if (_p.requests.isEmpty) {
      return _emptyBanner('No pending requests', CupertinoIcons.tray);
    }
    return SizedBox(
      height: 200.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _p.requests.length,
        itemBuilder: (_, i) => _reqCard(_p.requests[i]),
      ),
    );
  }

  Widget _reqCard(GuideBookingModel b) {
    final name = b.touristName.isNotEmpty ? b.touristName : 'Tourist';
    return Container(
      width: 230.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(
              color: _blue.withOpacity(0.08), blurRadius: 16,
              offset: const Offset(0, 6))]),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () => Navigator.pushNamed(context, '/guideTourRequestDetails',
              arguments: {'booking': b}),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _avatar(b.touristPhoto, 16.r, _blue),
                  SizedBox(width: 8.w),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.w700,
                            color: _dark),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${b.guestCount} guest${b.guestCount > 1 ? 's' : ''}',
                            style: TextStyle(fontSize: 11.sp, color: _gray)),
                      ])),
                  _badge('Pending', _amber),
                ]),
                SizedBox(height: 10.h),
                _row(CupertinoIcons.calendar, _fmtDate(b.bookingDate)),
                SizedBox(height: 3.h),
                _row(CupertinoIcons.time,
                    '${_fmtTime(b.startTime)} – ${_fmtTime(b.endTime)}'),
                SizedBox(height: 3.h),
                _row(CupertinoIcons.money_dollar_circle,
                    'LKR ${b.totalAmount.toStringAsFixed(0)}'),
                const Spacer(),
                Row(children: [
                  Expanded(child: _btn('Accept', _blue, () => _accept(b))),
                  SizedBox(width: 8.w),
                  Expanded(child: _btn('Decline', Colors.white, () => _reject(b),
                      textColor: _red, border: _red)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── UPCOMING BOOKINGS LIST ────────────────────────────────────────────────
  Widget _upcomingList() {
    if (_p.upcomingLoading) {
      return SizedBox(height: 170.h,
          child: const Center(child: CircularProgressIndicator()));
    }
    if (_p.upcomingError.isNotEmpty) {
      return _errBanner(_p.upcomingError, () {
        _p.loadUpcoming();
      });
    }
    if (_p.upcoming.isEmpty) {
      return _emptyBanner('No upcoming bookings', CupertinoIcons.calendar);
    }
    return SizedBox(
      height: 200.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _p.upcoming.length,
        itemBuilder: (_, i) => _upCard(_p.upcoming[i]),
      ),
    );
  }

  Widget _upCard(GuideBookingModel b) {
    final name = b.touristName.isNotEmpty ? b.touristName : 'Tourist';
    return Container(
      width: 230.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(
              color: _green.withOpacity(0.08), blurRadius: 16,
              offset: const Offset(0, 6))]),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () => Navigator.pushNamed(context, '/guideTourRequestDetails',
              arguments: {'booking': b}),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _avatar(b.touristPhoto, 16.r, _green),
                  SizedBox(width: 8.w),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.w700,
                            color: _dark),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${b.guestCount} guest${b.guestCount > 1 ? 's' : ''}',
                            style: TextStyle(fontSize: 11.sp, color: _gray)),
                      ])),
                  _badge('Confirmed', _green),
                ]),
                SizedBox(height: 10.h),
                _row(CupertinoIcons.calendar, _fmtDate(b.bookingDate)),
                SizedBox(height: 3.h),
                _row(CupertinoIcons.time,
                    '${_fmtTime(b.startTime)} – ${_fmtTime(b.endTime)}'),
                SizedBox(height: 3.h),
                _row(CupertinoIcons.person_2,
                    '${b.guestCount} guest${b.guestCount > 1 ? 's' : ''}'),
                SizedBox(height: 3.h),
                _row(CupertinoIcons.money_dollar_circle,
                    'LKR ${b.totalAmount.toStringAsFixed(0)}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── INVITE BANNER ─────────────────────────────────────────────────────────
  Widget _inviteBanner() => Container(
    margin: EdgeInsets.symmetric(horizontal: 16.w),
    decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [_blue, _blueDarker],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(
            color: _blue.withOpacity(0.3), blurRadius: 20,
            offset: const Offset(0, 8), spreadRadius: -4)]),
    child: Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(children: [
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r)),
                  child: Text('Earn Rewards', style: TextStyle(
                      color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w600))),
              SizedBox(height: 10.h),
              Text('Invite your\nfriends!', style: TextStyle(
                  color: Colors.white, fontSize: 20.sp,
                  fontWeight: FontWeight.w800, height: 1.2)),
              SizedBox(height: 6.h),
              Text('Earn 100 Yaloo Points per referral',
                  style: TextStyle(color: Colors.white.withOpacity(0.75),
                      fontSize: 12.sp)),
              SizedBox(height: 16.h),
              GestureDetector(
                  onTap: () {},
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.12), blurRadius: 8,
                              offset: const Offset(0, 3))]),
                      child: Text('INVITE NOW', style: TextStyle(
                          color: _blue, fontSize: 13.sp,
                          fontWeight: FontWeight.w800, letterSpacing: 0.5)))),
            ])),
        SizedBox(width: 12.w),
        Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20.r)),
            child: Icon(LucideIcons.gift, size: 64.w, color: Colors.white)),
      ]),
    ),
  );

  // ── SHARED WIDGETS ────────────────────────────────────────────────────────

  Widget _avatar(String url, double radius, Color fallbackColor) =>
      CircleAvatar(
          radius: radius,
          backgroundColor: fallbackColor.withOpacity(0.1),
          backgroundImage: url.isNotEmpty
              ? CachedNetworkImageProvider(url) : null,
          child: url.isEmpty
              ? Icon(CupertinoIcons.person, color: fallbackColor,
              size: radius * 0.8) : null);

  Widget _badge(String label, Color color) => Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8.r)),
      child: Text(label, style: TextStyle(
          color: color, fontSize: 10.sp, fontWeight: FontWeight.w700)));

  Widget _row(IconData icon, String text) => Row(children: [
    Icon(icon, size: 11.w, color: _gray),
    SizedBox(width: 6.w),
    Expanded(child: Text(text,
        style: TextStyle(fontSize: 11.sp, color: _gray),
        overflow: TextOverflow.ellipsis)),
  ]);

  Widget _btn(String label, Color bg, VoidCallback fn,
      {Color? textColor, Color? border}) =>
      GestureDetector(
          onTap: fn,
          child: Container(
              height: 30.h,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(10.r),
                  border: border != null
                      ? Border.all(color: border, width: 1.5) : null,
                  boxShadow: bg == _blue ? [BoxShadow(
                      color: _blue.withOpacity(0.3), blurRadius: 8,
                      offset: const Offset(0, 3))] : null),
              child: Center(child: Text(label, style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 12.sp, fontWeight: FontWeight.w700)))));

  Widget _emptyBanner(String msg, IconData icon) => Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 12,
              offset: const Offset(0, 4))]),
      child: Row(children: [
        Icon(icon, color: _gray.withOpacity(0.5), size: 28.w),
        SizedBox(width: 14.w),
        Text(msg, style: TextStyle(color: _gray, fontSize: 14.sp)),
      ]));

  Widget _errBanner(String msg, VoidCallback retry) => Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
          color: _red.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _red.withOpacity(0.25))),
      child: Row(children: [
        Icon(CupertinoIcons.exclamationmark_circle, color: _red, size: 18.w),
        SizedBox(width: 10.w),
        Expanded(child: Text(msg,
            style: TextStyle(color: _dark, fontSize: 12.sp))),
        TextButton(onPressed: retry,
            child: Text('Retry', style: TextStyle(
                color: _blue, fontSize: 12.sp, fontWeight: FontWeight.w700))),
      ]));

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