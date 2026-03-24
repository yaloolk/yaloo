// lib/features/guide/screens/guide_tour_requests_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/features/tourist/models/guide_booking_model.dart';
import 'package:yaloo/features/tourist/services/guide_booking_service.dart';

// ── Design tokens (matches home screen) ──────────────────────────────────────
const _blue   = Color(0xFF2563EB);
const _dark   = Color(0xFF1F2937);
const _gray   = Color(0xFF6B7280);
const _amber  = Color(0xFFF59E0B);
const _green  = Color(0xFF22C55E);
const _red    = Color(0xFFEF4444);
const _bg     = Color(0xFFF8FAFC);

class GuideTourRequestsScreen extends StatefulWidget {
  const GuideTourRequestsScreen({super.key});
  @override
  State<GuideTourRequestsScreen> createState() => _State();
}

class _State extends State<GuideTourRequestsScreen> {
  final _service = GuideBookingService();

  List<GuideBookingModel> _requests = [];
  bool   _loading = true;
  String _error   = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = ''; });
    try {
      final list = await _service.getGuideRequests();
      if (mounted) setState(() { _requests = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _accept(GuideBookingModel b) async {
    try {
      await _service.respondToBooking(bookingId: b.id, action: 'accept');
      _snack('Booking accepted ✓', _green);
      _load();
    } catch (e) {
      _snack(e.toString(), _red);
    }
  }

  Future<void> _reject(GuideBookingModel b) async {
    // Show reason dialog before rejecting
    final note = await _showRejectDialog();
    if (note == null) return;           // user cancelled
    try {
      await _service.respondToBooking(
          bookingId: b.id, action: 'reject', guideResponseNote: note);
      _snack('Booking declined', _gray);
      _load();
    } catch (e) {
      _snack(e.toString(), _red);
    }
  }

  Future<String?> _showRejectDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('Decline Booking',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800,
                color: _dark)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Add a note for the tourist (optional):',
              style: TextStyle(fontSize: 13.sp, color: _gray)),
          SizedBox(height: 12.h),
          TextField(
            controller: ctrl,
            maxLines: 3,
            decoration: InputDecoration(
                hintText: 'Reason for declining…',
                hintStyle: TextStyle(color: _gray, fontSize: 13.sp),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                contentPadding: EdgeInsets.all(12.w)),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: Text('Cancel', style: TextStyle(color: _gray))),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r))),
              child: const Text('Decline',
                  style: TextStyle(color: Colors.white))),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: CustomAppBar(title: 'Tour Requests'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error.isNotEmpty) return Center(child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(CupertinoIcons.exclamationmark_circle, color: _red, size: 40.w),
          SizedBox(height: 12.h),
          Text(_error, textAlign: TextAlign.center,
              style: TextStyle(color: _dark, fontSize: 14.sp)),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)))),
        ])));

    if (_requests.isEmpty) return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.tray, size: 56.w,
              color: _gray.withOpacity(0.4)),
          SizedBox(height: 16.h),
          Text('No pending requests', style: TextStyle(
              color: _gray, fontSize: 16.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.h),
          Text('New booking requests will appear here',
              style: TextStyle(color: _gray.withOpacity(0.7), fontSize: 13.sp)),
        ]));

    return RefreshIndicator(
      onRefresh: _load,
      color: _blue,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
        itemCount: _requests.length,
        itemBuilder: (_, i) => _card(_requests[i]),
      ),
    );
  }

  Widget _card(GuideBookingModel b) {
    final name = b.touristName.isNotEmpty ? b.touristName : 'Tourist';
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.06), blurRadius: 16,
              offset: const Offset(0, 4))]),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () => Navigator.pushNamed(
              context, '/guideTourRequestDetails',
              arguments: {'booking': b}),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ────────────────────────────────────────────
                Row(children: [
                  // Photo
                  Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _amber.withOpacity(0.4), width: 2)),
                      child: CircleAvatar(
                          radius: 24.r,
                          backgroundColor: _amber.withOpacity(0.1),
                          backgroundImage: b.touristPhoto.isNotEmpty
                              ? CachedNetworkImageProvider(b.touristPhoto) : null,
                          child: b.touristPhoto.isEmpty
                              ? Icon(CupertinoIcons.person,
                              color: _amber, size: 18.w) : null)),
                  SizedBox(width: 12.w),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(
                            fontSize: 15.sp, fontWeight: FontWeight.w700,
                            color: _dark)),
                        SizedBox(height: 2.h),
                        Text('${b.guestCount} guest${b.guestCount > 1 ? 's' : ''}',
                            style: TextStyle(fontSize: 12.sp, color: _gray)),
                      ])),
                  // Pending badge
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                          color: _amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                              color: _amber.withOpacity(0.3), width: 1)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 6.w, height: 6.h,
                            decoration: const BoxDecoration(
                                color: _amber, shape: BoxShape.circle)),
                        SizedBox(width: 5.w),
                        Text('Pending', style: TextStyle(
                            color: _amber, fontSize: 11.sp,
                            fontWeight: FontWeight.w700)),
                      ])),
                ]),

                Divider(height: 20.h,
                    color: Colors.black.withOpacity(0.06)),

                // ── Details grid ──────────────────────────────────────────
                Row(children: [
                  Expanded(child: Column(children: [
                    _infoTile(FontAwesomeIcons.calendar,
                        'Date', _fmtDate(b.bookingDate)),
                    SizedBox(height: 10.h),
                    _infoTile(FontAwesomeIcons.userGroup,
                        'Guests', '${b.guestCount} person${b.guestCount > 1 ? 's' : ''}'),
                  ])),
                  SizedBox(width: 12.w),
                  Expanded(child: Column(children: [
                    _infoTile(FontAwesomeIcons.clock, 'Time',
                        '${_fmtTime(b.startTime)} – ${_fmtTime(b.endTime)}'),
                    SizedBox(height: 10.h),
                    _infoTile(FontAwesomeIcons.dollarSign,
                        'Payout', 'LKR ${b.totalAmount.toStringAsFixed(0)}'),
                  ])),
                ]),

                // Special note (if any)
                if (b.specialNote != null && b.specialNote!.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                          color: _blue.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: _blue.withOpacity(0.1))),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(FontAwesomeIcons.noteSticky,
                                size: 12.w, color: _blue),
                            SizedBox(width: 8.w),
                            Expanded(child: Text(b.specialNote!,
                                style: TextStyle(
                                    fontSize: 12.sp, color: _dark,
                                    fontStyle: FontStyle.italic),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis)),
                          ])),
                ],

                SizedBox(height: 16.h),

                // ── Action buttons ────────────────────────────────────────
                Row(children: [
                  Expanded(child: ElevatedButton.icon(
                      onPressed: () => _accept(b),
                      icon: Icon(Icons.check, size: 16.w),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                          elevation: 0))),
                  SizedBox(width: 12.w),
                  Expanded(child: OutlinedButton.icon(
                      onPressed: () => _reject(b),
                      icon: Icon(Icons.close, size: 16.w, color: _red),
                      label: Text('Decline',
                          style: TextStyle(color: _red)),
                      style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(color: _red.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r))))),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
                color: _blue.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, size: 12.w, color: _blue)),
        SizedBox(width: 10.w),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(
                  fontSize: 10.sp, color: _gray, fontWeight: FontWeight.w500)),
              Text(value, style: TextStyle(
                  fontSize: 13.sp, color: _dark, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ])),
      ]);

  String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      const months = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
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