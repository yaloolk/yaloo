// lib/features/tourist/screens/host/stay_booking_status_screen.dart


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yaloo/core/network/api_client.dart';
import 'package:yaloo/features/tourist/models/stay_booking_model.dart';
import 'package:yaloo/features/tourist/providers/stay_booking_provider.dart';

const _blue       = Color(0xFF2563EB);
const _blueDark   = Color(0xFF1D4ED8);
const _blueDarker = Color(0xFF1E40AF);
const _bg         = Color(0xFFF8FAFC);
const _dark       = Color(0xFF1F2937);
const _gray       = Color(0xFF6B7280);
const _green      = Color(0xFF10B981);
const _amber      = Color(0xFFF59E0B);
const _red        = Color(0xFFEF4444);


typedef _Provider = StayBookingProvider;

class StayBookingStatusScreen extends StatelessWidget {
  const StayBookingStatusScreen({super.key});

  String _fd(String d) {
    try {
      final dt = DateTime.parse(d);
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month-1]} ${dt.year}';
    } catch (_) { return d; }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    StayBookingModel? b;

    if (args is StayBookingModel) {
      b = args;
    } else if (args is Map) {
      b = StayBookingModel.fromJson(Map<String, dynamic>.from(args));
    }

    if (b == null) {
      return Scaffold(appBar: AppBar(title: const Text('Booking Status')),
          body: const Center(child: Text('Booking not found')));
    }

    final status = b.bookingStatus;
    final cfg = _statusCfg(status);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _blue, foregroundColor: Colors.white, elevation: 0,
        title: Text(cfg['title'] as String, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        flexibleSpace: Container(decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [_blue, _blueDark, _blueDarker],
                begin: Alignment.topLeft, end: Alignment.bottomRight))),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 48.h),
        physics: const BouncingScrollPhysics(),
        child: Column(children: [
          // ── Status card ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [(cfg['color'] as Color), (cfg['colorDark'] as Color)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [BoxShadow(color: (cfg['color'] as Color).withOpacity(0.35),
                    blurRadius: 24, offset: const Offset(0, 8))]),
            padding: EdgeInsets.all(24.w),
            child: Column(children: [
              Container(padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(cfg['icon'] as IconData, color: Colors.white, size: 32.w)),
              SizedBox(height: 14.h),
              Text(cfg['title'] as String, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center),
              SizedBox(height: 8.h),
              Text(cfg['subtitle'] as String, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13.sp, height: 1.5),
                  textAlign: TextAlign.center),
              if (b.hostResponseNote?.isNotEmpty == true) ...[
                SizedBox(height: 10.h),
                Container(padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12.r)),
                    child: Text('Note: ${b.hostResponseNote}',
                        style: TextStyle(color: Colors.white, fontSize: 12.sp))),
              ],
            ]),
          ),
          SizedBox(height: 16.h),

          // ── Stay info ────────────────────────────────────────────────
          _surfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Stay Details', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _dark)),
            Divider(height: 16.h, color: Colors.black.withOpacity(0.07)),
            _infoRow(CupertinoIcons.house_fill, 'Stay', b.stayName.isNotEmpty ? b.stayName : 'Your Stay'),
            _infoRow(Icons.location_on_outlined, 'Location', b.cityName),
            _infoRow(Icons.person_outlined, 'Host', b.hostName),
            if (b.hostPhone.isNotEmpty && status == 'confirmed')
              _infoRow(CupertinoIcons.phone, 'Host Phone', b.hostPhone, highlight: true),
            _infoRow(CupertinoIcons.calendar, 'Check-in', _fd(b.checkinDate)),
            _infoRow(CupertinoIcons.calendar, 'Check-out', _fd(b.checkoutDate)),
            _infoRow(CupertinoIcons.moon_stars_fill, 'Nights', '${b.totalNights}'),
            _infoRow(CupertinoIcons.person_2, 'Guests',
                '${b.guestCount} guest${b.guestCount > 1 ? 's' : ''} · ${b.roomCount} room${b.roomCount > 1 ? 's' : ''}'),
            if (b.mealPreference != 'none')
              _infoRow(Icons.restaurant_menu_outlined, 'Meal', _capitalize(b.mealPreference)),
            if (b.specialNote?.isNotEmpty == true)
              _infoRow(Icons.notes_outlined, 'Note', b.specialNote!),
          ])),
          SizedBox(height: 16.h),

          // ── Payment ──────────────────────────────────────────────────
          _surfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Payment', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _dark)),
            Divider(height: 16.h, color: Colors.black.withOpacity(0.07)),
            _infoRow(FontAwesomeIcons.moneyBillWave, 'Per Night', 'LKR ${b.pricePerNight.toStringAsFixed(0)}'),
            _infoRow(FontAwesomeIcons.receipt, 'Total', 'LKR ${b.totalAmount.toStringAsFixed(0)}', highlight: true),
            _infoRow(FontAwesomeIcons.creditCard, 'Payment', _capitalize(b.paymentStatus)),
          ])),
          SizedBox(height: 16.h),

          // ── Actions ──────────────────────────────────────────────────
          if (status == 'pending' || status == 'confirmed') ...[
            _cancelButton(context, b),
            SizedBox(height: 12.h),
          ],
          if (status == 'completed') ...[
            _reviewButton(context, b),
            SizedBox(height: 12.h),
          ],
        ]),
      ),
    );
  }

  Map<String, dynamic> _statusCfg(String s) {
    switch (s) {
      case 'confirmed': return {
        'title': 'Stay Confirmed! 🎉', 'subtitle': 'Your host accepted your request. Get ready for your stay!',
        'color': _green, 'colorDark': const Color(0xFF059669), 'icon': FontAwesomeIcons.circleCheck};
      case 'completed': return {
        'title': 'Stay Completed 🏡', 'subtitle': 'Thank you for staying with us! Leave a review.',
        'color': _blue, 'colorDark': _blueDark, 'icon': FontAwesomeIcons.flagCheckered};
      case 'rejected': return {
        'title': 'Booking Declined', 'subtitle': 'Unfortunately your request was not accepted.',
        'color': _red, 'colorDark': const Color(0xFFB91C1C), 'icon': FontAwesomeIcons.circleXmark};
      case 'cancelled': return {
        'title': 'Booking Cancelled', 'subtitle': 'This booking was cancelled.',
        'color': _gray, 'colorDark': const Color(0xFF4B5563), 'icon': FontAwesomeIcons.ban};
      default: return {
        'title': 'Awaiting Confirmation', 'subtitle': 'Your request is pending. The host will review it shortly.',
        'color': _amber, 'colorDark': const Color(0xFFD97706), 'icon': FontAwesomeIcons.hourglassHalf};
    }
  }

  Widget _surfaceCard({required Widget child}) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 4))]),
    padding: EdgeInsets.all(16.w), child: child,
  );

  Widget _infoRow(IconData icon, String label, String value, {bool highlight = false}) =>
      Padding(padding: EdgeInsets.symmetric(vertical: 7.h), child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(color: _blue.withOpacity(0.07), borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, size: 12.w, color: _blue)),
        SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 10.sp, color: _gray)),
          Text(value, style: TextStyle(fontSize: 13.sp, color: highlight ? _blue : _dark,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600)),
        ])),
      ],
      ));

  Widget _cancelButton(BuildContext context, StayBookingModel b) => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () => _showCancelDialog(context, b),
      icon: Icon(FontAwesomeIcons.ban, size: 14.w),
      label: Text('Cancel Booking', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
      style: OutlinedButton.styleFrom(foregroundColor: _red,
          side: BorderSide(color: _red.withOpacity(0.5)),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
    ),
  );

  Widget _reviewButton(BuildContext context, StayBookingModel b) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      // Pass 'b' directly instead of b.toJson()
      onPressed: () => Navigator.pushNamed(context, '/stayReview', arguments: b),
      icon: Icon(FontAwesomeIcons.solidStar, size: 14.w),
      label: Text('Leave a Review', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
      style: ElevatedButton.styleFrom(backgroundColor: _amber, foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14.h), elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
    ),
  );

  void _showCancelDialog(BuildContext context, StayBookingModel b) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: const Text('Cancel Booking?'),
      content: const Text('Are you sure? This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Keep', style: TextStyle(color: _gray))),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            final prov = Provider.of<StayBookingProvider>(context, listen: false);
            final ok = await prov.cancelBooking(b.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok ? 'Booking cancelled' : 'Failed to cancel'),
                backgroundColor: ok ? _green : _red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ));
              if (ok) Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: _red, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1).replaceAll('_', ' ')}';
}