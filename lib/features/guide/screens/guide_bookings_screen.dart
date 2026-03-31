// lib/features/guide/screens/guide_bookings_screen.dart

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/features/tourist/models/guide_booking_model.dart';
import 'package:yaloo/features/tourist/services/guide_booking_service.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _blue       = Color(0xFF2563EB);
const _blueDark   = Color(0xFF1D4ED8);
const _blueDarker = Color(0xFF1E40AF);
const _bgPage     = Color(0xFFF8FAFC);
const _dark       = Color(0xFF1F2937);
const _gray       = Color(0xFF6B7280);
const _green      = Color(0xFF10B981);
const _amber      = Color(0xFFF59E0B);
const _red        = Color(0xFFEF4444);

class GuideBookingsScreen extends  StatefulWidget {
  const GuideBookingsScreen({super.key});
  @override State<GuideBookingsScreen> createState() => _GuideBookingsScreenState();
}

class _GuideBookingsScreenState extends State<GuideBookingsScreen>
    with SingleTickerProviderStateMixin {

  final _service = GuideBookingService();
  late final TabController _tabCtrl;

  List<GuideBookingModel> _requests  = [];
  List<GuideBookingModel> _upcoming  = [];
  List<GuideBookingModel> _history   = [];
  bool _loading = true;

  Timer? _refreshTimer;
  Timer? _clockTimer;

  // Per-booking live clocks
  final Map<String, Duration> _countdowns = {};
  final Map<String, Duration> _remainders = {};
  final Map<String, double>   _progress   = {};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _load();

    // Refresh data every 30 s
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _load());

    // Live clock every second
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recomputeClocks());
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _refreshTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────
  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _service.getGuideRequests(),
        _service.getGuideUpcoming(),
        _service.getGuideHistory(),
      ]);
      if (!mounted) return;
      setState(() {
        _requests = results[0];
        _upcoming = results[1];
        _history  = results[2];
        _loading  = false;
        _recomputeClocks();
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _recomputeClocks() {
    final now = DateTime.now();
    for (final b in [..._upcoming, ..._requests]) {
      final start = _parse(b.bookingDate, b.startTime);
      final end   = _parse(b.bookingDate, b.endTime);
      if (start == null || end == null) continue;
      if (start.isAfter(now)) {
        _countdowns[b.id] = start.difference(now);
      }
      if (now.isAfter(start) && now.isBefore(end)) {
        _remainders[b.id] = end.difference(now);
        final total   = end.difference(start).inSeconds;
        final elapsed = now.difference(start).inSeconds;
        _progress[b.id] = (elapsed / total).clamp(0.0, 1.0);
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
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
                      child: Icon(FontAwesomeIcons.calendarDays, color: Colors.white, size: 18.w),
                    ),
                    SizedBox(width: 12.w),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('My Bookings',
                          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                      Text('Manage your tours & requests',
                          style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12.sp)),
                    ]),
                    const Spacer(),
                    // Badge for pending requests
                    if (_requests.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: _amber,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text('${_requests.length} new',
                            style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w800)),
                      ),
                  ]),
                ),
                SizedBox(height: 8.h),
                _tabBar(),
              ],
            ),
          ),
        ),
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabCtrl,
        children: [
          _requestsList(),
          _upcomingList(),
          _activeList(),
          _historyList(),
        ],
      ),
    );
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
      insets: EdgeInsets.symmetric(horizontal: 14.w),
    ),
    tabs: [
      Tab(text: 'Requests${_requests.isNotEmpty ? ' (${_requests.length})' : ''}'),
      const Tab(text: 'Upcoming'),
      Tab(text: 'Active${_activeTours.isNotEmpty ? ' (${_activeTours.length})' : ''}'),
      const Tab(text: 'History'),
    ],
  );

  // ── Derived list: tours happening right now ───────────────────────────────
  List<GuideBookingModel> get _activeTours {
    final now = DateTime.now();
    return _upcoming.where((b) {
      final start = _parse(b.bookingDate, b.startTime);
      final end   = _parse(b.bookingDate, b.endTime);
      return start != null && end != null && now.isAfter(start) && now.isBefore(end);
    }).toList();
  }

  // ── Tabs ──────────────────────────────────────────────────────────────────
  Widget _requestsList() {
    if (_requests.isEmpty) return _empty(FontAwesomeIcons.inbox, 'No Pending Requests', 'New booking requests will appear here');
    return RefreshIndicator(
      color: _blue,
      onRefresh: _load,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        physics: const BouncingScrollPhysics(),
        itemCount: _requests.length,
        itemBuilder: (_, i) => _RequestCard(
          booking: _requests[i],
          onRespond: _respond,
        ),
      ),
    );
  }

  Widget _upcomingList() {
    if (_upcoming.isEmpty) return _empty(FontAwesomeIcons.calendarCheck, 'No Upcoming Tours', 'Accepted tours will show here');
    return RefreshIndicator(
      color: _blue,
      onRefresh: _load,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        physics: const BouncingScrollPhysics(),
        itemCount: _upcoming.length,
        itemBuilder: (_, i) {
          final b = _upcoming[i];
          return _UpcomingCard(
            booking: b,
            countdown: _countdowns[b.id],
            tourRemaining: _remainders[b.id],
            progress: _progress[b.id] ?? 0.0,
            onComplete: _complete,
          );
        },
      ),
    );
  }

  Widget _activeList() {
    final active = _activeTours;
    if (active.isEmpty) return _empty(FontAwesomeIcons.personWalking, 'No Active Tours', 'Tours happening right now will appear here');
    return RefreshIndicator(
      color: _blue,
      onRefresh: _load,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        physics: const BouncingScrollPhysics(),
        itemCount: active.length,
        itemBuilder: (_, i) {
          final b = active[i];
          return _ActiveTourCard(
            booking: b,
            tourRemaining: _remainders[b.id] ?? Duration.zero,
            progress: _progress[b.id] ?? 0.0,
            onComplete: _complete,
          );
        },
      ),
    );
  }

  Widget _historyList() {
    if (_history.isEmpty) return _empty(FontAwesomeIcons.clockRotateLeft, 'No History Yet', 'Completed and past bookings will appear here');
    return RefreshIndicator(
      color: _blue,
      onRefresh: _load,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        physics: const BouncingScrollPhysics(),
        itemCount: _history.length,
        itemBuilder: (_, i) => _HistoryCard(booking: _history[i]),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  Future<void> _respond(String bookingId, String action) async {
    String? note;
    if (action == 'reject') {
      note = await _noteDialog('Reason for rejection (optional)');
    }
    try {
      await _service.respondToBooking(bookingId: bookingId, action: action, guideResponseNote: note);
      if (mounted) {
        _snack(action == 'accept' ? 'Booking accepted!' : 'Booking rejected', action == 'accept' ? _green : _gray);
        await _load();
      }
    } catch (e) {
      if (mounted) _snack(e.toString(), _red);
    }
  }

  Future<void> _complete(String bookingId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('Mark Tour as Complete?'),
        content: const Text('This will notify the tourist and allow them to leave feedback.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: _gray))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: const Text('Yes, Complete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.completeBooking(bookingId);
      if (mounted) {
        _snack('Tour marked as complete! 🏆', _green);
        await _load();
      }
    } catch (e) {
      if (mounted) _snack(e.toString(), _red);
    }
  }

  Future<String?> _noteDialog(String hint) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('Add Note'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Skip', style: TextStyle(color: _gray))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: _blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _snack(String m, Color c) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(m, style: const TextStyle(color: Colors.white)),
    backgroundColor: c,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
  ));

  Widget _empty(IconData icon, String title, String sub) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_blue.withOpacity(0.1), _blue.withOpacity(0.05)]),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _blue, size: 48.w),
      ),
      SizedBox(height: 18.h),
      Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: _dark)),
      SizedBox(height: 6.h),
      Text(sub, style: TextStyle(color: _gray, fontSize: 13.sp)),
    ]),
  );

  DateTime? _parse(String date, String time) {
    try {
      final p = time.split(':');
      final d = DateTime.parse(date);
      return DateTime(d.year, d.month, d.day, int.parse(p[0]), int.parse(p[1]));
    } catch (_) { return null; }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REQUEST CARD — Accept / Reject
// ─────────────────────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final GuideBookingModel booking;
  final Future<void> Function(String, String) onRespond;
  const _RequestCard({required this.booking, required this.onRespond});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Column(children: [
          // Amber header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_amber, Color(0xFFD97706)]),
            ),
            child: Row(children: [
              Icon(FontAwesomeIcons.hourglassHalf, color: Colors.white, size: 13.w),
              SizedBox(width: 7.w),
              Text('New Booking Request', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(_fmtDate(b.createdAt), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11.sp)),
            ]),
          ),

          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Tourist info
              Row(children: [
                _avatar(b.touristPhoto, b.touristName),
                SizedBox(width: 12.w),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b.touristName.isNotEmpty ? b.touristName : 'Tourist',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: _dark)),
                  SizedBox(height: 2.h),
                  Row(children: [
                    Icon(FontAwesomeIcons.userGroup, size: 10.w, color: _gray),
                    SizedBox(width: 4.w),
                    Text('${b.guestCount} guest${b.guestCount > 1 ? 's' : ''}',
                        style: TextStyle(fontSize: 11.sp, color: _gray)),
                  ]),
                ])),
                // Earnings badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: _green.withOpacity(0.3)),
                  ),
                  child: Text('LKR ${b.totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: _green)),
                ),
              ]),
              SizedBox(height: 12.h),

              // Details
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14.r)),
                child: Column(children: [
                  _row(CupertinoIcons.calendar, _fmtDate(b.bookingDate)),
                  SizedBox(height: 6.h),
                  _row(CupertinoIcons.time, '${_fmtTime(b.startTime)} – ${_fmtTime(b.endTime)} (${b.totalHours.toStringAsFixed(1)} hrs)'),
                  if (b.pickupAddress != null && b.pickupAddress!.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    _row(CupertinoIcons.map_pin, b.pickupAddress!),
                  ],
                  if (b.specialNote != null && b.specialNote!.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    _row(CupertinoIcons.bubble_left, b.specialNote!),
                  ],
                ]),
              ),
              SizedBox(height: 14.h),

              // Accept / Reject buttons
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onRespond(b.id, 'reject'),
                    icon: Icon(FontAwesomeIcons.xmark, size: 12.w),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _red,
                      side: BorderSide(color: _red.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => onRespond(b.id, 'accept'),
                    icon: Icon(FontAwesomeIcons.check, size: 12.w),
                    label: const Text('Accept Booking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      elevation: 0,
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _avatar(String photo, String name) => ClipRRect(
    borderRadius: BorderRadius.circular(12.r),
    child: photo.isNotEmpty
        ? CachedNetworkImage(imageUrl: photo, width: 50.w, height: 55.h, fit: BoxFit.cover,
        placeholder: (_, __) => _avatarFb(name),
        errorWidget: (_, __, ___) => _avatarFb(name))
        : _avatarFb(name),
  );

  Widget _avatarFb(String name) => Container(
    width: 50.w, height: 55.h,
    decoration: BoxDecoration(color: _blue.withOpacity(0.08)),
    child: Center(child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: _blue),
    )),
  );

  Widget _row(IconData icon, String value) => Row(children: [
    Icon(icon, color: _blue, size: 12.w),
    SizedBox(width: 8.w),
    Expanded(child: Text(value, style: TextStyle(color: _dark, fontSize: 12.sp, fontWeight: FontWeight.w600))),
  ]);

  String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    } catch (_) { return d; }
  }

  String _fmtTime(String t) {
    try {
      final p = t.split(':'); int h = int.parse(p[0]);
      final m = p[1].padLeft(2,'0'); final ap = h >= 12 ? 'PM' : 'AM';
      if (h == 0) h = 12; else if (h > 12) h -= 12;
      return '$h:$m $ap';
    } catch (_) { return t; }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UPCOMING CARD — Countdown + progress if already started
// ─────────────────────────────────────────────────────────────────────────────
class _UpcomingCard extends StatelessWidget {
  final GuideBookingModel booking;
  final Duration? countdown;
  final Duration? tourRemaining;
  final double progress;
  final Future<void> Function(String) onComplete;
  const _UpcomingCard({
    required this.booking,
    required this.countdown,
    required this.tourRemaining,
    required this.progress,
    required this.onComplete,
  });

  bool get _isActive => tourRemaining != null && tourRemaining! > Duration.zero;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Column(children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isActive ? [_blue, _blueDark] : [_green, const Color(0xFF059669)],
              ),
            ),
            child: Row(children: [
              Icon(_isActive ? FontAwesomeIcons.personWalking : FontAwesomeIcons.circleCheck,
                  color: Colors.white, size: 13.w),
              SizedBox(width: 7.w),
              Text(_isActive ? 'In Progress' : 'Confirmed',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('LKR ${b.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700)),
            ]),
          ),

          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(children: [
              // Tourist
              Row(children: [
                Icon(CupertinoIcons.person_circle_fill, color: _blue.withOpacity(0.4), size: 36.w),
                SizedBox(width: 10.w),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b.touristName.isNotEmpty ? b.touristName : 'Tourist',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: _dark)),
                  Row(children: [
                    Icon(FontAwesomeIcons.userGroup, size: 10.w, color: _gray),
                    SizedBox(width: 4.w),
                    Text('${b.guestCount} guest${b.guestCount > 1 ? 's' : ''}',
                        style: TextStyle(fontSize: 11.sp, color: _gray)),
                    SizedBox(width: 8.w),
                    Icon(FontAwesomeIcons.phone, size: 10.w, color: _green),
                    SizedBox(width: 4.w),
                    Text(b.touristPhone, style: TextStyle(fontSize: 11.sp, color: _green, fontWeight: FontWeight.w600)),
                  ]),
                ])),
              ]),
              SizedBox(height: 10.h),

              // Date / time row
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12.r)),
                child: Row(children: [
                  Icon(CupertinoIcons.calendar, color: _blue, size: 13.w),
                  SizedBox(width: 6.w),
                  Text(_fmtDate(b.bookingDate),
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: _dark)),
                  const Spacer(),
                  Icon(CupertinoIcons.time, color: _blue, size: 13.w),
                  SizedBox(width: 6.w),
                  Text('${_fmtTime(b.startTime)} – ${_fmtTime(b.endTime)}',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: _dark)),
                ]),
              ),
              SizedBox(height: 10.h),

              // Timer widget
              if (_isActive) ...[
                _progressWidget(b.id),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => onComplete(b.id),
                    icon: Icon(FontAwesomeIcons.flagCheckered, size: 14.w),
                    label: const Text('Mark Tour as Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      elevation: 0,
                    ),
                  ),
                ),
              ] else if (countdown != null && countdown! > Duration.zero) ...[
                _countdownWidget(),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _progressWidget(String id) {
    final rem = tourRemaining ?? Duration.zero;
    final h = rem.inHours;
    final m = rem.inMinutes.remainder(60);
    final s = rem.inSeconds.remainder(60);
    final pct = (progress * 100).toInt();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Tour in progress', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: _blue)),
        Text('$pct%', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: _blue)),
      ]),
      SizedBox(height: 6.h),
      ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 8.h,
          backgroundColor: _blue.withOpacity(0.1),
          valueColor: const AlwaysStoppedAnimation<Color>(_blue),
        ),
      ),
      SizedBox(height: 6.h),
      Center(
        child: Text(
          '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')} remaining',
          style: TextStyle(fontSize: 12.sp, color: _gray, fontWeight: FontWeight.w600),
        ),
      ),
    ]);
  }

  Widget _countdownWidget() {
    final cd = countdown ?? Duration.zero;
    final h = cd.inHours;
    final m = cd.inMinutes.remainder(60);
    final s = cd.inSeconds.remainder(60);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: _green.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(children: [
        Text('Starts in', style: TextStyle(fontSize: 11.sp, color: _gray)),
        SizedBox(height: 4.h),
        Text(
          '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: _green),
        ),
      ]),
    );
  }

  String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      const ms = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${ms[dt.month - 1]} ${dt.year}';
    } catch (_) { return d; }
  }

  String _fmtTime(String t) {
    try {
      final p = t.split(':'); int h = int.parse(p[0]);
      final m = p[1].padLeft(2,'0'); final ap = h >= 12 ? 'PM' : 'AM';
      if (h == 0) h = 12; else if (h > 12) h -= 12;
      return '$h:$m $ap';
    } catch (_) { return t; }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE TOUR CARD — prominent complete CTA
// ─────────────────────────────────────────────────────────────────────────────
class _ActiveTourCard extends StatelessWidget {
  final GuideBookingModel booking;
  final Duration tourRemaining;
  final double progress;
  final Future<void> Function(String) onComplete;
  const _ActiveTourCard({
    required this.booking,
    required this.tourRemaining,
    required this.progress,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final h = tourRemaining.inHours;
    final m = tourRemaining.inMinutes.remainder(60);
    final s = tourRemaining.inSeconds.remainder(60);
    final pct = (progress * 100).toInt();

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_blue, _blueDark, _blueDarker], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: _blue.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10.r)),
            child: Icon(FontAwesomeIcons.personWalking, color: Colors.white, size: 16.w),
          ),
          SizedBox(width: 10.w),
          Text('Tour In Progress!', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800)),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10.r)),
            child: Text('$pct%', style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w800)),
          ),
        ]),
        SizedBox(height: 16.h),

        // Tourist name
        Text(b.touristName.isNotEmpty ? b.touristName : 'Tourist',
            style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w800)),
        SizedBox(height: 2.h),
        Text('${b.guestCount} guest${b.guestCount > 1 ? 's' : ''} · LKR ${b.totalAmount.toStringAsFixed(0)}',
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12.sp)),
        SizedBox(height: 16.h),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10.h,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: Text(
            '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')} remaining',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 18.h),

        // Complete CTA
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => onComplete(b.id),
            icon: Icon(FontAwesomeIcons.flagCheckered, size: 16.w),
            label: const Text('Mark Tour as Complete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _blue,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              elevation: 0,
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HISTORY CARD
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final GuideBookingModel booking;
  const _HistoryCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    Color headerColor;
    IconData headerIcon;
    String headerLabel;

    switch (b.bookingStatus) {
      case 'completed':
        headerColor = _green; headerIcon = FontAwesomeIcons.flagCheckered; headerLabel = 'Completed';
        break;
      case 'rejected':
        headerColor = _red; headerIcon = FontAwesomeIcons.circleXmark; headerLabel = 'Declined';
        break;
      case 'cancelled':
        headerColor = _gray; headerIcon = FontAwesomeIcons.ban; headerLabel = 'Cancelled';
        break;
      default:
        headerColor = _gray; headerIcon = FontAwesomeIcons.circleXmark; headerLabel = b.bookingStatus;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            color: headerColor.withOpacity(0.1),
            child: Row(children: [
              Icon(headerIcon, color: headerColor, size: 12.w),
              SizedBox(width: 6.w),
              Text(headerLabel, style: TextStyle(color: headerColor, fontSize: 12.sp, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(_fmtDate(b.bookingDate), style: TextStyle(color: _gray, fontSize: 11.sp)),
            ]),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.touristName.isNotEmpty ? b.touristName : 'Tourist',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: _dark)),
                SizedBox(height: 3.h),
                Text('${_fmtTime(b.startTime)} – ${_fmtTime(b.endTime)} · ${b.totalHours.toStringAsFixed(1)} hrs',
                    style: TextStyle(fontSize: 12.sp, color: _gray)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('LKR ${b.totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: headerColor)),
                if (b.tipAmount > 0) ...[
                  SizedBox(height: 2.h),
                  Text('+LKR ${b.tipAmount.toStringAsFixed(0)} tip',
                      style: TextStyle(fontSize: 11.sp, color: _green, fontWeight: FontWeight.w600)),
                ],
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      const ms = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${ms[dt.month - 1]} ${dt.year}';
    } catch (_) { return d; }
  }

  String _fmtTime(String t) {
    try {
      final p = t.split(':'); int h = int.parse(p[0]);
      final m = p[1].padLeft(2,'0'); final ap = h >= 12 ? 'PM' : 'AM';
      if (h == 0) h = 12; else if (h > 12) h -= 12;
      return '$h:$m $ap';
    } catch (_) { return t; }
  }
}