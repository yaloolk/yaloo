// lib/features/tourist/screens/tourist_booking_status_screen.dart


import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/features/tourist/models/guide_booking_model.dart';
import 'package:yaloo/features/tourist/services/guide_booking_service.dart';

const _blue       = Color(0xFF2563EB);
const _blueDark   = Color(0xFF1D4ED8);
const _blueDarker = Color(0xFF1E40AF);
const _bg         = Color(0xFFF8FAFC);
const _dark       = Color(0xFF1F2937);
const _gray       = Color(0xFF6B7280);
const _green      = Color(0xFF10B981);
const _amber      = Color(0xFFF59E0B);
const _red        = Color(0xFFEF4444);

// Phases driven by BOTH timer AND bookingStatus from API
enum _Phase {
  pending,
  confirmed,
  active,         // timer says in-progress; guide hasn't completed yet
  awaitingComplete, // timer elapsed, waiting for guide to mark complete
  done,           // bookingStatus == 'completed' — feedback unlocked
  rejected,
  cancelled,
  completedHistory, // opened from history (already 'completed')
}

class TouristBookingStatusScreen extends StatefulWidget {
  const TouristBookingStatusScreen({super.key});
  @override State<TouristBookingStatusScreen> createState() =>
      _TouristBookingStatusScreenState();
}

class _TouristBookingStatusScreenState extends State<TouristBookingStatusScreen>
    with TickerProviderStateMixin {

  final _service   = GuideBookingService();
  GuideBookingModel? _booking;
  bool _cancelling = false;

  Timer?   _ticker;          // 1-second UI timer
  Timer?   _pollTimer;       // 15-second API poll when awaiting completion
  Duration _timeToStart   = Duration.zero;
  Duration _tourRemaining = Duration.zero;
  double   _tourProgress  = 0.0; // 0.0 → 1.0

  late final AnimationController _pulse;
  late final Animation<double>   _pulseAnim;
  late final AnimationController _progressAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.95, end: 1.0)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

    _progressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (_booking == null && args != null) {
      if (args is GuideBookingModel) {
        _booking = args;
      } else if (args is Map<String, dynamic>) {
        _booking = GuideBookingModel.fromJson(args);
      }
      _startTicker();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pollTimer?.cancel();
    _pulse.dispose();
    _progressAnim.dispose();
    super.dispose();
  }

  // ── Phase computation ─────────────────────────────────────────────────────
  _Phase get _phase {
    final b = _booking;
    if (b == null) return _Phase.pending;
    switch (b.bookingStatus) {
      case 'rejected':  return _Phase.rejected;
      case 'cancelled': return _Phase.cancelled;
      case 'completed': return _Phase.completedHistory;
      case 'pending':   return _Phase.pending;
    }
    final now   = DateTime.now();
    final start = _parseDateTime(b.bookingDate, b.startTime);
    final end   = _parseDateTime(b.bookingDate, b.endTime);
    if (start == null || end == null) return _Phase.confirmed;
    if (now.isBefore(start)) return _Phase.confirmed;
    if (now.isAfter(end))    return _Phase.awaitingComplete; // timer done, but guide hasn't marked complete
    return _Phase.active;
  }

  // ── Tickers ───────────────────────────────────────────────────────────────
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final b = _booking;
      if (b == null) return;
      final now   = DateTime.now();
      final start = _parseDateTime(b.bookingDate, b.startTime);
      final end   = _parseDateTime(b.bookingDate, b.endTime);

      setState(() {
        // countdown to start
        if (start != null && start.isAfter(now)) {
          _timeToStart = start.difference(now);
        }
        // active tour: remaining time + progress
        if (start != null && end != null && now.isAfter(start) && now.isBefore(end)) {
          _tourRemaining = end.difference(now);
          final total   = end.difference(start).inSeconds;
          final elapsed = now.difference(start).inSeconds;
          _tourProgress = (elapsed / total).clamp(0.0, 1.0);
        }
      });

      // Start polling when timer runs out (guide needs to mark complete)
      final p = _phase;
      if (p == _Phase.awaitingComplete && _pollTimer == null) {
        _startPolling();
      }
    });
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (!mounted) return;
      try {
        final updated = await _service.getBookingDetail(_booking!.id);
        if (!mounted) return;
        setState(() => _booking = updated);
        if (updated.bookingStatus == 'completed') {
          _pollTimer?.cancel();
          _ticker?.cancel();
        }
      } catch (_) { /* silent — keep polling */ }
    });
  }

  // ── Cancel ────────────────────────────────────────────────────────────────
  Future<void> _cancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('Cancel Booking?'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _cancelling = true);
    try {
      await _service.cancelBooking(_booking!.id);
      if (!mounted) return;
      setState(() => _booking = GuideBookingModel.fromJson({
        ..._booking!.toJson(), 'booking_status': 'cancelled',
      }));
    } catch (e) {
      if (mounted) _snack(e.toString(), _red);
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  void _snack(String m, Color c) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(m, style: const TextStyle(color: Colors.white)),
      backgroundColor: c,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    ),
  );

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final b = _booking;
    if (b == null) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: _appBar('Booking Status'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final phase = _phase;
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar(_appBarTitle(phase)),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 48.h),
        physics: const BouncingScrollPhysics(),
        child: Column(children: [
          _phaseCard(b),
          SizedBox(height: 16.h),

          // Live progress bar during active tour
          if (phase == _Phase.active || phase == _Phase.awaitingComplete) ...[
            _TourProgressBar(progress: _tourProgress, phase: phase),
            SizedBox(height: 16.h),
          ],

          _guideCard(b),
          SizedBox(height: 16.h),
          _tripDetailsCard(b),
          SizedBox(height: 16.h),
          _paymentCard(b),

          // Action buttons
          if (phase == _Phase.pending || phase == _Phase.confirmed) ...[
            SizedBox(height: 16.h),
            _cancelButton(),
          ],

          // Feedback only after guide marks complete
          if (phase == _Phase.done || phase == _Phase.completedHistory) ...[
            SizedBox(height: 16.h),
            _feedbackButton(b),
            SizedBox(height: 12.h),
            _rebookButton(b),
          ],

          // Waiting for guide to complete
          if (phase == _Phase.awaitingComplete) ...[
            SizedBox(height: 16.h),
            _awaitingCompleteNotice(),
          ],
        ]),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _appBar(String title) => AppBar(
    backgroundColor: _blue,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    title: Text(title, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: Colors.white)),
    leading: IconButton(
      icon: const Icon(CupertinoIcons.chevron_left, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    ),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_blue, _blueDark, _blueDarker],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
  );

  String _appBarTitle(_Phase p) {
    switch (p) {
      case _Phase.pending:          return 'Awaiting Confirmation';
      case _Phase.confirmed:        return 'Tour Confirmed';
      case _Phase.active:           return 'Tour In Progress';
      case _Phase.awaitingComplete: return 'Tour Ended';
      case _Phase.done:             return 'Tour Completed';
      case _Phase.rejected:         return 'Booking Declined';
      case _Phase.cancelled:        return 'Booking Cancelled';
      case _Phase.completedHistory: return 'Tour Completed';
    }
  }

  // ── Phase status card ─────────────────────────────────────────────────────
  Widget _phaseCard(GuideBookingModel b) {
    switch (_phase) {
      case _Phase.pending:
        return _statusCard(
          gradient: [_amber, const Color(0xFFD97706)],
          icon: FontAwesomeIcons.hourglassHalf,
          title: 'Waiting for Confirmation',
          subtitle: 'The guide is reviewing your request.\nYou\'ll be notified once confirmed.',
          extra: _spinner(),
        );
      case _Phase.confirmed:
        return _statusCard(
          gradient: [_green, const Color(0xFF059669)],
          icon: FontAwesomeIcons.circleCheck,
          title: 'Tour Confirmed! 🎉',
          subtitle: 'Your guide accepted the booking.',
          extra: _countdownWidget(),
        );
      case _Phase.active:
        return ScaleTransition(
          scale: _pulseAnim,
          child: _statusCard(
            gradient: [_blue, _blueDark, _blueDarker],
            icon: FontAwesomeIcons.personWalking,
            title: '🎉 Tour In Progress!',
            subtitle: 'Enjoy your experience with your guide.',
            extra: _tourActiveWidget(),
          ),
        );
      case _Phase.awaitingComplete:
        return _statusCard(
          gradient: [_blue, _blueDarker],
          icon: FontAwesomeIcons.flagCheckered,
          title: 'Tour Time Ended',
          subtitle: 'Waiting for your guide to mark the tour as complete.',
          extra: _spinner(),
        );
      case _Phase.done:
      case _Phase.completedHistory:
        return _statusCard(
          gradient: [_green, const Color(0xFF059669)],
          icon: FontAwesomeIcons.flagCheckered,
          title: 'Tour Completed! 🏆',
          subtitle: 'Thank you for exploring with Yaloo.\nLeave your feedback below!',
          extra: null,
        );
      case _Phase.rejected:
        return _statusCard(
          gradient: [_red, const Color(0xFFB91C1C)],
          icon: FontAwesomeIcons.circleXmark,
          title: 'Booking Declined',
          subtitle: b.guideResponseNote?.isNotEmpty == true
              ? 'Reason: ${b.guideResponseNote}'
              : 'The guide couldn\'t accept your request.',
          extra: _findAnotherButton(),
        );
      case _Phase.cancelled:
        return _statusCard(
          gradient: [_gray, const Color(0xFF4B5563)],
          icon: FontAwesomeIcons.ban,
          title: 'Booking Cancelled',
          subtitle: 'This booking was cancelled.',
          extra: _findAnotherButton(),
        );
    }
  }

  Widget _statusCard({
    required List<Color> gradient,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget? extra,
  }) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(24.r),
      boxShadow: [BoxShadow(color: gradient.first.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8))],
    ),
    padding: EdgeInsets.all(24.w),
    child: Column(children: [
      Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 32.w),
      ),
      SizedBox(height: 16.h),
      Text(title,
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w800),
          textAlign: TextAlign.center),
      SizedBox(height: 8.h),
      Text(subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13.sp, height: 1.5),
          textAlign: TextAlign.center),
      if (extra != null) ...[SizedBox(height: 20.h), extra],
    ]),
  );

  // ── Time widgets ──────────────────────────────────────────────────────────
  Widget _spinner() => SizedBox(
    width: 36.w, height: 36.h,
    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
  );

  Widget _countdownWidget() {
    if (_timeToStart <= Duration.zero) return _pill('Tour starting now!');
    final h = _timeToStart.inHours;
    final m = _timeToStart.inMinutes.remainder(60);
    final s = _timeToStart.inSeconds.remainder(60);
    return Column(children: [
      Text('Starts in', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12.sp)),
      SizedBox(height: 8.h),
      Row(mainAxisSize: MainAxisSize.min, children: [
        _timeBox(h.toString().padLeft(2, '0'), 'HRS'),
        _colon(),
        _timeBox(m.toString().padLeft(2, '0'), 'MIN'),
        _colon(),
        _timeBox(s.toString().padLeft(2, '0'), 'SEC'),
      ]),
    ]);
  }

  Widget _tourActiveWidget() {
    final h = _tourRemaining.inHours;
    final m = _tourRemaining.inMinutes.remainder(60);
    final s = _tourRemaining.inSeconds.remainder(60);
    return Column(children: [
      Text('Time Remaining', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12.sp)),
      SizedBox(height: 8.h),
      Row(mainAxisSize: MainAxisSize.min, children: [
        _timeBox(h.toString().padLeft(2, '0'), 'HRS'),
        _colon(),
        _timeBox(m.toString().padLeft(2, '0'), 'MIN'),
        _colon(),
        _timeBox(s.toString().padLeft(2, '0'), 'SEC'),
      ]),
    ]);
  }

  Widget _timeBox(String val, String unit) => Container(
    margin: EdgeInsets.symmetric(horizontal: 4.w),
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Column(children: [
      Text(val, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w800)),
      Text(unit, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9.sp, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _colon() => Text(':', style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w800));

  Widget _pill(String text) => Container(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: Text(text, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w700)),
  );

  // ── Awaiting complete notice ───────────────────────────────────────────────
  Widget _awaitingCompleteNotice() => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: _amber.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: _amber.withOpacity(0.3)),
    ),
    child: Row(children: [
      Icon(FontAwesomeIcons.triangleExclamation, color: _amber, size: 18.w),
      SizedBox(width: 12.w),
      Expanded(
        child: Text(
          'Waiting for your guide to mark the tour as complete. You\'ll be able to leave feedback once they do.',
          style: TextStyle(fontSize: 12.sp, color: _dark, height: 1.4),
        ),
      ),
    ]),
  );

  // ── Guide card ────────────────────────────────────────────────────────────
  Widget _guideCard(GuideBookingModel b) => _surfaceCard(
    child: Row(children: [
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _blue.withOpacity(0.3), width: 2.5),
        ),
        child: CircleAvatar(
          radius: 28.r,
          backgroundColor: _blue.withOpacity(0.08),
          backgroundImage: b.guidePhoto.isNotEmpty ? CachedNetworkImageProvider(b.guidePhoto) : null,
          child: b.guidePhoto.isEmpty ? Icon(CupertinoIcons.person, color: _blue, size: 22.w) : null,
        ),
      ),
      SizedBox(width: 14.w),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(b.guideName.isNotEmpty ? b.guideName : 'Your Guide',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _dark)),
          SizedBox(height: 3.h),
          if (b.cityName.isNotEmpty)
            Row(children: [
              Icon(FontAwesomeIcons.locationDot, size: 11.w, color: _gray),
              SizedBox(width: 5.w),
              Text(b.cityName, style: TextStyle(fontSize: 12.sp, color: _gray)),
            ]),
          if (b.guidePhone.isNotEmpty &&
              (_phase == _Phase.confirmed || _phase == _Phase.active)) ...[
            SizedBox(height: 4.h),
            Row(children: [
              Icon(FontAwesomeIcons.phone, size: 11.w, color: _green),
              SizedBox(width: 5.w),
              Text(b.guidePhone, style: TextStyle(color: _green, fontSize: 12.sp, fontWeight: FontWeight.w600)),
            ]),
          ],
        ]),
      ),
    ]),
  );

  // ── Trip details card ─────────────────────────────────────────────────────
  Widget _tripDetailsCard(GuideBookingModel b) => _infoCard(
    title: 'Trip Details',
    rows: [
      _infoRow(FontAwesomeIcons.calendar, 'Date', _fmtDateFull(b.bookingDate.toString())),
      _infoRow(FontAwesomeIcons.clock, 'Time',
          '${_fmtTime(b.startTime.toString())} – ${_fmtTime(b.endTime.toString())} (${b.totalHours.toStringAsFixed(1)} hrs)'),
      _infoRow(FontAwesomeIcons.userGroup, 'Guests', '${b.guestCount} person${b.guestCount > 1 ? 's' : ''}'),
      if (b.pickupAddress != null && b.pickupAddress!.isNotEmpty)
        _infoRow(FontAwesomeIcons.locationArrow, 'Pickup', b.pickupAddress!),
      if (b.specialNote != null && b.specialNote!.isNotEmpty)
        _infoRow(FontAwesomeIcons.noteSticky, 'Note', b.specialNote!),
    ],
  );

  // ── Payment card ──────────────────────────────────────────────────────────
  Widget _paymentCard(GuideBookingModel b) => _infoCard(
    title: 'Payment',
    rows: [
      _infoRow(FontAwesomeIcons.dollarSign, 'Rate', 'LKR ${b.ratePerHour.toStringAsFixed(0)}/hr'),
      _infoRow(FontAwesomeIcons.receipt, 'Total', 'LKR ${b.totalAmount.toStringAsFixed(0)}', highlight: true),
      _infoRow(FontAwesomeIcons.creditCard, 'Status', b.paymentStatus.toUpperCase()),
      if (b.tipAmount > 0)
        _infoRow(FontAwesomeIcons.handHoldingHeart, 'Tip', 'LKR ${b.tipAmount.toStringAsFixed(0)}'),
    ],
  );

  // ── Action buttons ────────────────────────────────────────────────────────
  Widget _cancelButton() => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: _cancelling ? null : _cancel,
      icon: _cancelling
          ? SizedBox(width: 16.w, height: 16.h, child: const CircularProgressIndicator(strokeWidth: 2))
          : Icon(FontAwesomeIcons.ban, size: 14.w),
      label: Text(_cancelling ? 'Cancelling…' : 'Cancel Booking'),
      style: OutlinedButton.styleFrom(
        foregroundColor: _red,
        side: BorderSide(color: _red.withOpacity(0.5)),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      ),
    ),
  );

  /// Only enabled when bookingStatus == 'completed' from backend
  Widget _feedbackButton(GuideBookingModel b) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () => Navigator.pushReplacementNamed(
        context, '/tourCompletion',
        arguments: b.toJson(), // always pass map
      ),
      icon: Icon(FontAwesomeIcons.solidStar, size: 16.w),
      label: const Text('Leave Feedback'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _amber,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      ),
    ),
  );

  Widget _rebookButton(GuideBookingModel b) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () => Navigator.pushNamed(
        context, '/guideDetail',
        arguments: {'guideProfileId': b.guideProfileId},
      ),
      icon: Icon(FontAwesomeIcons.rotate, size: 16.w),
      label: const Text('Book This Guide Again'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      ),
    ),
  );

  Widget _findAnotherButton() => GestureDetector(
    onTap: () => Navigator.pushNamedAndRemoveUntil(
      context, '/findGuide', (r) => r.settings.name == '/touristDashboard',
    ),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Text('Find Another Guide',
          style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w700)),
    ),
  );

  // ── Card helpers ──────────────────────────────────────────────────────────
  Widget _surfaceCard({required Widget child}) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 4))],
    ),
    padding: EdgeInsets.all(16.w),
    child: child,
  );

  Widget _infoCard({required String title, required List<Widget> rows}) =>
      _surfaceCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _dark)),
          Divider(height: 16.h, color: Colors.black.withOpacity(0.07)),
          ...rows,
        ]),
      );

  Widget _infoRow(IconData icon, String label, String value, {bool highlight = false}) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.07),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 12.w, color: _blue),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 10.sp, color: _gray)),
              Text(value, style: TextStyle(
                fontSize: 13.sp,
                color: highlight ? _blue : _dark,
                fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
              )),
            ]),
          ),
        ]),
      );

  // ── Parsers / formatters ──────────────────────────────────────────────────
  DateTime? _parseDateTime(String date, String time) {
    try {
      final p = time.split(':');
      final d = DateTime.parse(date);
      return DateTime(d.year, d.month, d.day, int.parse(p[0]), int.parse(p[1]));
    } catch (_) { return null; }
  }

  String _fmtDateFull(String d) {
    try {
      final dt = DateTime.parse(d);
      const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) { return d; }
  }

  String _fmtTime(String t) {
    try {
      final p = t.split(':');
      int h = int.parse(p[0]);
      final m = p[1].padLeft(2, '0');
      final ap = h >= 12 ? 'PM' : 'AM';
      if (h == 0) h = 12; else if (h > 12) h -= 12;
      return '$h:$m $ap';
    } catch (_) { return t; }
  }
}

// ── Tour progress bar widget ──────────────────────────────────────────────────
class _TourProgressBar extends StatelessWidget {
  final double progress;
  final _Phase phase;
  const _TourProgressBar({required this.progress, required this.phase});

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).toInt().clamp(0, 100);
    final isAwaiting = phase == _Phase.awaitingComplete;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(FontAwesomeIcons.mapLocationDot, size: 13.w, color: _blue),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              isAwaiting ? 'Tour complete — awaiting confirmation' : 'Tour Progress',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: _dark),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isAwaiting ? _green.withOpacity(0.1) : _blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              isAwaiting ? '100%' : '$pct%',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: isAwaiting ? _green : _blue,
              ),
            ),
          ),
        ]),
        SizedBox(height: 12.h),

        // Progress bar track
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: LinearProgressIndicator(
            value: isAwaiting ? 1.0 : progress,
            minHeight: 10.h,
            backgroundColor: _blue.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation<Color>(isAwaiting ? _green : _blue),
          ),
        ),
        SizedBox(height: 10.h),

        // Step labels
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _stepLabel('Started', true),
          _stepLabel('Halfway', progress >= 0.5),
          _stepLabel('Done', isAwaiting),
        ]),
      ]),
    );
  }

  Widget _stepLabel(String label, bool reached) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(
      width: 8.w, height: 8.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: reached ? _blue : _gray.withOpacity(0.3),
      ),
    ),
    SizedBox(width: 4.w),
    Text(label, style: TextStyle(fontSize: 10.sp, color: reached ? _blue : _gray, fontWeight: FontWeight.w600)),
  ]);
}