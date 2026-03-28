// lib/features/tourist/screens/tourist_tour_completion_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/network/api_client.dart';
import 'package:yaloo/features/tourist/models/guide_booking_model.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _blue       = Color(0xFF2563EB);
const _blueDark   = Color(0xFF1D4ED8);
const _blueDarker = Color(0xFF1E40AF);
const _bg         = Color(0xFFF8FAFC);
const _dark       = Color(0xFF1F2937);
const _gray       = Color(0xFF6B7280);
const _amber      = Color(0xFFF59E0B);
const _green      = Color(0xFF10B981);
const _red        = Color(0xFFEF4444);

class TouristTourCompletionScreen extends StatefulWidget {
  const TouristTourCompletionScreen({super.key});
  @override State<TouristTourCompletionScreen> createState() =>
      _TouristTourCompletionScreenState();
}

class _TouristTourCompletionScreenState
    extends State<TouristTourCompletionScreen> {

  final _api        = ApiClient();
  final _reviewCtrl = TextEditingController();

  GuideBookingModel? _booking;
  int    _stars      = 0;
  int?   _tipIndex;
  String _customTip  = '';
  bool   _submitting = false;
  bool   _submitted  = false;

  static const _tipOptions = [0, 500, 1000, 1500, 2000];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_booking != null) return;                         // already loaded
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is GuideBookingModel) {
      _booking = args;
    } else if (args is Map<String, dynamic>) {
      // booking status screen passes .toJson() — handle it
      _booking = GuideBookingModel.fromJson(args);
    }
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  // ── Submit feedback ────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_stars == 0) { _snack('Please select a star rating', _amber); return; }
    setState(() => _submitting = true);
    try {
      // tip_amount: prefer selected preset, else custom input, else 0
      final tip = (_tipIndex != null && _tipOptions[_tipIndex!] > 0)
          ? _tipOptions[_tipIndex!]
          : (int.tryParse(_customTip) ?? 0);

      await _api.post('/accounts/reviews/', data: {
        'guide_profile_id': _booking!.guideProfileId,
        'booking_id':       _booking!.id,
        'rating':           _stars,
        'review':           _reviewCtrl.text.trim(),
        if (tip > 0) 'tip_amount': tip,
      });
      if (!mounted) return;
      setState(() { _submitted = true; _submitting = false; });
    } catch (e) {
      if (mounted) {
        _snack('Could not submit review: $e', _red);
        setState(() => _submitting = false);
      }
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

  // ── Root build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final b = _booking;

    // Guard: tour must be completed before feedback is allowed
    if (b != null && b.bookingStatus != 'completed') {
      return _notCompletedWall(b);
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: _submitted ? _thankyouView() : _feedbackView(b)),
    );
  }

  // ── Guard wall — tour not finished yet ────────────────────────────────────
  Widget _notCompletedWall(GuideBookingModel b) => Scaffold(
    backgroundColor: _bg,
    appBar: AppBar(
      backgroundColor: _blue,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text('Feedback', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800)),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_blue, _blueDark, _blueDarker],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    ),
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: _amber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(FontAwesomeIcons.hourglassHalf, color: _amber, size: 48.w),
          ),
          SizedBox(height: 24.h),
          Text('Tour Not Finished Yet',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: _dark)),
          SizedBox(height: 10.h),
          Text(
            'You can leave feedback only after your tour is marked as completed by the guide.',
            style: TextStyle(fontSize: 13.sp, color: _gray, height: 1.5),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(FontAwesomeIcons.arrowLeft, size: 14.w),
              label: const Text('Back to Booking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
            ),
          ),
        ]),
      ),
    ),
  );

  // ── Thank-you view ────────────────────────────────────────────────────────
  Widget _thankyouView() => Center(
    child: Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: EdgeInsets.all(28.r),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_blue, _blueDark, _blueDarker],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: _blue.withOpacity(0.35), blurRadius: 30, offset: const Offset(0, 10))],
          ),
          child: Icon(FontAwesomeIcons.solidHeart, color: Colors.white, size: 48.w),
        ),
        SizedBox(height: 28.h),
        Text('Thank You!',
            style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: _dark, letterSpacing: -0.5)),
        SizedBox(height: 12.h),
        Text(
          'Your review has been submitted.\nYour feedback helps the community!',
          style: TextStyle(fontSize: 14.sp, color: _gray, height: 1.5),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 36.h),

        // Book same guide again
        if (_booking != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/guideDetail', (r) => false,
                arguments: {'guideProfileId': _booking!.guideProfileId},
              ),
              icon: Icon(FontAwesomeIcons.rotate, size: 16.w),
              label: const Text('Book Same Guide Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
            ),
          ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, '/touristDashboard', (r) => false,
            ),
            icon: Icon(FontAwesomeIcons.house, size: 14.w),
            label: const Text('Back to Home'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _dark,
              side: BorderSide(color: _gray.withOpacity(0.4)),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
            ),
          ),
        ),
      ]),
    ),
  );

  // ── Feedback view ─────────────────────────────────────────────────────────
  Widget _feedbackView(GuideBookingModel? b) => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    child: Column(children: [
      _heroHeader(b),
      Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
        child: Column(children: [
          _ratingCard(),
          SizedBox(height: 16.h),
          _reviewCard(),
          SizedBox(height: 16.h),
          _tipCard(),
          SizedBox(height: 16.h),
          _rebookCard(b),
          SizedBox(height: 24.h),
          _submitButton(),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, '/touristDashboard', (r) => false,
            ),
            child: Text('Skip for now', style: TextStyle(color: _gray, fontSize: 13.sp)),
          ),
        ]),
      ),
    ]),
  );

  // ── Hero header ───────────────────────────────────────────────────────────
  Widget _heroHeader(GuideBookingModel? b) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [_blue, _blueDark, _blueDarker],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    padding: EdgeInsets.fromLTRB(24.w, 48.h, 24.w, 32.h),
    child: Column(children: [
      // Trophy icon
      Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
        child: Icon(FontAwesomeIcons.trophy, color: _amber, size: 32.w),
      ),
      SizedBox(height: 16.h),
      Text('Tour Completed! 🏆',
          style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w800)),
      SizedBox(height: 8.h),
      // Guide avatar
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)],
        ),
        child: CircleAvatar(
          radius: 36.r,
          backgroundColor: _blueDarker,
          backgroundImage: b?.guidePhoto.isNotEmpty == true
              ? CachedNetworkImageProvider(b!.guidePhoto) : null,
          child: b?.guidePhoto.isNotEmpty != true
              ? Icon(CupertinoIcons.person, color: Colors.white, size: 36.w) : null,
        ),
      ),
      SizedBox(height: 12.h),
      Text(
        b?.guideName.isNotEmpty == true ? b!.guideName : 'Your Guide',
        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w800),
      ),
      SizedBox(height: 4.h),
      Text('How was your experience?',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13.sp)),
    ]),
  );

  // ── Star rating ───────────────────────────────────────────────────────────
  Widget _ratingCard() => _card(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Rate Your Guide'),
      SizedBox(height: 16.h),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) => GestureDetector(
          onTap: () => setState(() => _stars = i + 1),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Icon(
              i < _stars ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
              size: 36.w,
              color: i < _stars ? _amber : _gray.withOpacity(0.3),
            ),
          ),
        )),
      ),
      SizedBox(height: 12.h),
      Center(
        child: Text(
          _stars == 0
              ? 'Tap a star to rate'
              : ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent!'][_stars],
          style: TextStyle(
            color: _stars == 0 ? _gray : _dark,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ]),
  );

  // ── Review input ──────────────────────────────────────────────────────────
  Widget _reviewCard() => _card(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Share Your Experience'),
      SizedBox(height: 12.h),
      TextField(
        controller: _reviewCtrl,
        maxLines: 4,
        maxLength: 500,
        decoration: InputDecoration(
          hintText: 'Tell others about your tour… highlights, tips, what to expect.',
          hintStyle: TextStyle(color: _gray, fontSize: 13.sp),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: _gray.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: const BorderSide(color: _blue, width: 1.5),
          ),
          contentPadding: EdgeInsets.all(14.w),
        ),
      ),
    ]),
  );

  // ── Tip ───────────────────────────────────────────────────────────────────
  Widget _tipCard() => _card(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Add a Tip (Optional)'),
      SizedBox(height: 4.h),
      Text('100% goes to your guide', style: TextStyle(fontSize: 11.sp, color: _gray)),
      SizedBox(height: 14.h),
      Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: List.generate(_tipOptions.length, (i) {
          final selected = _tipIndex == i;
          final amt = _tipOptions[i];
          return GestureDetector(
            onTap: () => setState(() { _tipIndex = selected ? null : i; _customTip = ''; }),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: selected ? _blue : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: selected ? _blue : _gray.withOpacity(0.3),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                amt == 0 ? 'No Tip' : 'LKR $amt',
                style: TextStyle(
                  color: selected ? Colors.white : _dark,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
      SizedBox(height: 12.h),
      TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Custom amount (LKR)',
          hintStyle: TextStyle(color: _gray, fontSize: 13.sp),
          prefixIcon: Icon(FontAwesomeIcons.moneyBill, size: 14.w, color: _gray),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: _gray.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: _blue, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        ),
        onChanged: (v) => setState(() { _customTip = v; if (v.isNotEmpty) _tipIndex = null; }),
      ),
    ]),
  );

  // ── Rebook card ───────────────────────────────────────────────────────────
  Widget _rebookCard(GuideBookingModel? b) => _card(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Had a Great Time?'),
      SizedBox(height: 8.h),
      Text('Book this guide again for your next adventure!',
          style: TextStyle(fontSize: 13.sp, color: _gray, height: 1.4)),
      SizedBox(height: 14.h),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: b == null ? null : () => Navigator.pushNamed(
            context, '/guideDetail',
            arguments: {'guideProfileId': b.guideProfileId},
          ),
          icon: Icon(FontAwesomeIcons.calendarPlus, size: 14.w),
          label: const Text('Book Same Guide'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _blue,
            side: const BorderSide(color: _blue, width: 1.5),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
      ),
    ]),
  );

  // ── Submit button ─────────────────────────────────────────────────────────
  Widget _submitButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _submitting ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        elevation: 0,
      ),
      child: _submitting
          ? SizedBox(width: 22.w, height: 22.h,
          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
          : Text('Submit Feedback', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
    ),
  );

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 4))],
    ),
    padding: EdgeInsets.all(20.w),
    child: child,
  );

  Widget _sectionTitle(String t) => Text(t,
      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _dark));
}