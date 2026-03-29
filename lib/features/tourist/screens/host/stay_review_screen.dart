// lib/features/tourist/screens/host/stay_review_screen.dart

import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/network/api_client.dart';
import 'package:yaloo/features/tourist/models/stay_booking_model.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _blue       = Color(0xFF2563EB);
const _blueDark   = Color(0xFF1D4ED8);
const _blueDarker = Color(0xFF1E40AF);
const _bg         = Color(0xFFF8FAFC);
const _dark       = Color(0xFF1F2937);
const _gray       = Color(0xFF6B7280);
const _green      = Color(0xFF10B981);
const _amber      = Color(0xFFF59E0B);
const _red        = Color(0xFFEF4444);

class StayReviewScreen extends StatefulWidget {
  const StayReviewScreen({super.key});
  @override State<StayReviewScreen> createState() => _StayReviewScreenState();
}

class _StayReviewScreenState extends State<StayReviewScreen> {
  final _api        = ApiClient();
  final _reviewCtrl = TextEditingController();

  StayBookingModel? _b;
  int    _stars      = 0;
  int?   _tipIndex;
  String _customTip  = '';
  bool   _submitting = false;
  bool   _submitted  = false;

  static const _tipOptions = [0, 500, 1000, 2000, 3000];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_b != null) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is StayBookingModel) {
      _b = args;
    } else if (args is Map) {
      // Safely cast the Map regardless of its internal generic type
      _b = StayBookingModel.fromJson(Map<String, dynamic>.from(args));
    }

  }

  @override
  void dispose() { _reviewCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_stars == 0) { _snack('Please select a star rating', _amber); return; }
    setState(() => _submitting = true);

    try {
      final tip = (_tipIndex != null && _tipOptions[_tipIndex!] > 0)
          ? _tipOptions[_tipIndex!]
          : (int.tryParse(_customTip) ?? 0);

      await _api.post('/accounts/stays/${_b!.id}/review/', data: {
        'rating': _stars,
        'review': _reviewCtrl.text.trim(),
        if (tip > 0) 'tip_amount': tip,
      });

      if (mounted) setState(() { _submitted = true; _submitting = false; });

    } catch (e) {
      if (mounted) {
        String errorMessage = 'Could not submit review';

        // 1. Check if the error is from Dio
        if (e is DioException && e.response?.data != null) {
          final data = e.response!.data;

          // 2. Extract the specific 'error' string sent by Django
          if (data is Map && data.containsKey('error')) {
            errorMessage = data['error'];
          } else {
            errorMessage = e.message ?? errorMessage;
          }
        } else {
          // Fallback for non-network errors
          errorMessage = e.toString();
        }

        // 3. Show the clean message
        _snack(errorMessage, _red);
        setState(() => _submitting = false);
      }
    }
  }

  void _snack(String m, Color c) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(m, style: const TextStyle(color: Colors.white)), backgroundColor: c,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
  ));

  @override
  Widget build(BuildContext context) {
    if (_b == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_b!.bookingStatus != 'completed') {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(title: const Text('Review')),
        body: Center(child: Text('Stay not completed yet',
            style: TextStyle(color: _gray, fontSize: 15.sp))),
      );
    }
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: _submitted ? _thankYou() : _form()),
    );
  }

  Widget _thankYou() => Center(child: Padding(padding: EdgeInsets.all(32.w), child: Column(
    mainAxisSize: MainAxisSize.min, children: [
    Container(padding: EdgeInsets.all(28.r),
        decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_blue, _blueDark, _blueDarker],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: _blue.withOpacity(0.35), blurRadius: 30, offset: const Offset(0, 10))]),
        child: Icon(FontAwesomeIcons.solidHeart, color: Colors.white, size: 48.w)),
    SizedBox(height: 24.h),
    Text('Thank You!', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: _dark)),
    SizedBox(height: 10.h),
    Text('Your review has been submitted.\nHosts appreciate your feedback!',
        textAlign: TextAlign.center, style: TextStyle(color: _gray, fontSize: 14.sp, height: 1.5)),
    SizedBox(height: 32.h),
    SizedBox(width: double.infinity, child: ElevatedButton(
      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/myStayBookings', (_) => false),
      style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14.h), elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
      child: Text('View My Bookings', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
    )),
    SizedBox(height: 12.h),
    SizedBox(width: double.infinity, child: OutlinedButton(
      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/touristDashboard', (_) => false),
      style: OutlinedButton.styleFrom(foregroundColor: _dark,
          side: BorderSide(color: _gray.withOpacity(0.4)),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
      child: Text('Back to Home', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
    )),
  ],
  )));

  Widget _form() => Column(children: [
    // Hero
    Container(
      width: double.infinity,
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [_blue, _blueDark, _blueDarker],
              begin: Alignment.topLeft, end: Alignment.bottomRight)),
      padding: EdgeInsets.fromLTRB(24.w, 48.h, 24.w, 32.h),
      child: Column(children: [
        Container(padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(FontAwesomeIcons.trophy, color: _amber, size: 32.w)),
        SizedBox(height: 14.h),
        Text('Stay Completed! 🏡', style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w800)),
        SizedBox(height: 8.h),
        if (_b != null) ...[
          CircleAvatar(radius: 34.r, backgroundColor: _blueDarker,
              backgroundImage: _b!.stayCoverPhoto.isNotEmpty ? CachedNetworkImageProvider(_b!.stayCoverPhoto) : null,
              child: _b!.stayCoverPhoto.isEmpty ? Icon(CupertinoIcons.house, color: Colors.white, size: 28.w) : null),
          SizedBox(height: 10.h),
          Text(_b!.stayName.isNotEmpty ? _b!.stayName : 'Your Stay',
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800)),
          Text('Hosted by ${_b!.hostName}',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13.sp)),
        ],
        SizedBox(height: 6.h),
        Text('How was your experience?', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13.sp)),
      ]),
    ),
    Expanded(child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        // Stars
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _secTitle('Rate Your Stay'),
          SizedBox(height: 14.h),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) =>
              GestureDetector(onTap: () => setState(() => _stars = i + 1),
                  child: Padding(padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Icon(i < _stars ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
                          size: 36.w, color: i < _stars ? _amber : _gray.withOpacity(0.3)))))),
          SizedBox(height: 10.h),
          Center(child: Text(
            _stars == 0 ? 'Tap a star to rate'
                : ['','Poor','Fair','Good','Very Good','Excellent!'][_stars],
            style: TextStyle(color: _stars == 0 ? _gray : _dark, fontSize: 14.sp, fontWeight: FontWeight.w600),
          )),
        ])),
        SizedBox(height: 14.h),
        // Review text
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _secTitle('Share Your Experience'),
          SizedBox(height: 10.h),
          TextField(controller: _reviewCtrl, maxLines: 4, maxLength: 500,
              style: TextStyle(fontSize: 13.sp, color: _dark),
              decoration: InputDecoration(
                hintText: 'Tell others about the stay — hospitality, food, cleanliness…',
                hintStyle: TextStyle(color: _gray, fontSize: 13.sp),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: _gray.withOpacity(0.3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: _blue, width: 1.5)),
                contentPadding: EdgeInsets.all(14.w),
              )),
        ])),
        SizedBox(height: 14.h),
        // Tip
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _secTitle('Tip Your Host (Optional)'),
          SizedBox(height: 4.h),
          Text('100% goes to your host', style: TextStyle(fontSize: 11.sp, color: _gray)),
          SizedBox(height: 12.h),
          Wrap(spacing: 8.w, runSpacing: 8.h, children: List.generate(_tipOptions.length, (i) {
            final sel = _tipIndex == i;
            return GestureDetector(onTap: () => setState(() { _tipIndex = sel ? null : i; _customTip = ''; }),
                child: Container(padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(color: sel ? _blue : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: sel ? _blue : _gray.withOpacity(0.3), width: sel ? 1.5 : 1)),
                    child: Text(_tipOptions[i] == 0 ? 'No Tip' : 'LKR ${_tipOptions[i]}',
                        style: TextStyle(color: sel ? Colors.white : _dark, fontSize: 12.sp, fontWeight: FontWeight.w600))));
          })),
          SizedBox(height: 10.h),
          TextField(keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 13.sp),
              decoration: InputDecoration(hintText: 'Custom amount (LKR)',
                  hintStyle: TextStyle(color: _gray, fontSize: 13.sp),
                  prefixIcon: Icon(FontAwesomeIcons.moneyBill, size: 14.w, color: _gray),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: _gray.withOpacity(0.3))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: _blue, width: 1.5)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h)),
              onChanged: (v) => setState(() { _customTip = v; if (v.isNotEmpty) _tipIndex = null; })),
        ])),
        SizedBox(height: 24.h),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: _submitting ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h), elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))),
          child: _submitting
              ? SizedBox(width: 22.w, height: 22.h,
              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text('Submit Review', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
        )),
        SizedBox(height: 10.h),
        TextButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/myStayBookings', (_) => false),
            child: Text('Skip for now', style: TextStyle(color: _gray, fontSize: 13.sp))),
      ]),
    )),
  ]);

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 4))]),
    padding: EdgeInsets.all(18.w), child: child,
  );
  Widget _secTitle(String t) => Text(t, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _dark));
}