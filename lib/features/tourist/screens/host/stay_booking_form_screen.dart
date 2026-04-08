// lib/features/tourist/screens/host/stay_booking_form_screen.dart


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/services/payment_service.dart';         // ← NEW
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/custom_primary_button.dart';
import 'package:yaloo/core/widgets/step_progress_indicator.dart';
import '../../providers/stay_booking_provider.dart';
import '../../models/stay_booking_model.dart';

const _blue   = Color(0xFF2563EB);
const _dark   = Color(0xFF1F2937);
const _gray   = Color(0xFF6B7280);
const _green  = Color(0xFF10B981);
const _red    = Color(0xFFEF4444);
const _bgPage = Color(0xFFF8FAFC);

class StayBookingFormScreen extends StatefulWidget {
  const StayBookingFormScreen({super.key});
  @override State<StayBookingFormScreen> createState() =>
      _StayBookingFormScreenState();
}

class _StayBookingFormScreenState extends State<StayBookingFormScreen> {

  // ── Args ──────────────────────────────────────────────────────────────────
  Map<String, dynamic> _stay       = {};
  String               _checkin    = '';
  String               _checkout   = '';
  bool                 _argsLoaded = false;

  int    _step           = 0;
  int    _guestCount     = 1;
  int    _roomCount      = 1;
  String _bookingType    = 'per_night';
  String _mealPreference = 'none';

  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _noteCtrl  = TextEditingController();
  String _country  = '';
  String _gender   = '';
  String _passport = '';

  // ── NEW: payment state ─────────────────────────────────────────────────────
  bool   _processingPayment = false;
  String _paymentError      = '';
  final  _paymentService    = PaymentService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;
    _argsLoaded = true;
    final args = ModalRoute.of(context)!.settings.arguments
    as Map<String, dynamic>;

    // ── BUGFIX: was reading locals without assigning to state ─────────────
    final stay     = args['stay']    as StaySearchResult;
    final profile  = args['profile'] as Map<String, dynamic>?;
    final checkin  = args['checkin']  as String? ?? '';
    final checkout = args['checkout'] as String? ?? '';

    setState(() {
      _stay     = stay.toJson();   // convert StaySearchResult → Map
      _checkin  = checkin;
      _checkout = checkout;

      // Pre-fill tourist's own details from their profile
      if (profile != null) {
        _nameCtrl.text  = (profile['full_name']    as String?) ?? '';
        _phoneCtrl.text = (profile['phone_number'] as String?) ?? '';
        _country        = (profile['country']      as String?) ?? '';
        _gender         = (profile['gender']       as String?) ?? '';
        _passport       = (profile['passport_number'] as String?) ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _emailCtrl.dispose(); _noteCtrl.dispose();
    super.dispose();
  }

  // ── Computed values ───────────────────────────────────────────────────────

  int get _nights {
    if (_checkin.isEmpty || _checkout.isEmpty) return 1;
    try {
      final ci = DateTime.parse(_checkin);
      final co = DateTime.parse(_checkout);
      return co.difference(ci).inDays.clamp(1, 365);
    } catch (_) { return 1; }
  }

  double get _pricePerNight {
    if (_bookingType == 'entire_place')
      return (_stay['price_entire_place'] as num?)?.toDouble() ?? 0;
    if (_bookingType == 'halfday')
      return (_stay['price_per_halfday'] as num?)?.toDouble() ?? 0;
    return (_stay['price_per_night'] as num?)?.toDouble() ?? 0;
  }

  double get _total =>
      _pricePerNight * (_bookingType == 'halfday' ? 1 : _nights);

  // ── Validation ────────────────────────────────────────────────────────────

  bool get _step0Valid =>
      _nameCtrl.text.trim().isNotEmpty &&
          _phoneCtrl.text.trim().isNotEmpty &&
          _emailCtrl.text.trim().isNotEmpty;

  // ── Submit: 3-step flow ───────────────────────────────────────────────────

  Future<void> _confirm() async {
    if (_stay['stay_id'] == null) {
      _snack('Stay information missing'); return;
    }
    if (_processingPayment) return;

    setState(() { _processingPayment = true; _paymentError = ''; });

    final prov = context.read<StayBookingProvider>();

    try {
      // ── Step 1: Create booking record (pending) ────────────────────────
      final bookingOk = await prov.createBooking(
        stayId:          _stay['stay_id'] as String,
        checkinDate:     _checkin,
        checkoutDate:    _checkout,
        bookingType:     _bookingType,
        roomCount:       _roomCount,
        guestCount:      _guestCount,
        mealPreference:  _mealPreference,
        specialNote:     _noteCtrl.text.trim().isNotEmpty
            ? _noteCtrl.text.trim() : null,
        touristFullName: _nameCtrl.text.trim(),
        touristPassport: _passport.isNotEmpty ? _passport : null,
        touristPhone:    _phoneCtrl.text.trim(),
        touristEmail:    _emailCtrl.text.trim(),
        touristCountry:  _country.isNotEmpty ? _country : null,
        touristGender:   _gender.isNotEmpty  ? _gender  : null,
      );

      if (!bookingOk || prov.lastCreatedBooking == null) {
        setState(() {
          _processingPayment = false;
          _paymentError = prov.createError.isNotEmpty
              ? prov.createError : 'Booking failed. Please try again.';
        });
        return;
      }

      final bookingId = prov.lastCreatedBooking!.id;

      // ── Step 2: Create PaymentIntent on backend ────────────────────────
      final intentResult = await _paymentService.createPaymentIntent(
        bookingType: 'stay',
        bookingId:   bookingId,
      );

      // ── Step 3: Present Stripe payment sheet ───────────────────────────
      final paid = await _paymentService.presentPaymentSheet(
        clientSecret: intentResult.clientSecret,
        totalLkr:     intentResult.totalLkr,
      );

      if (!mounted) return;

      if (paid) {
        Navigator.pushReplacementNamed(
          context,
          '/stayBookingConfirmation',
          arguments: prov.lastCreatedBooking,
        );
      } else {
        setState(() { _processingPayment = false; });
        _snack('Payment cancelled. Your request is saved but unpaid.');
      }

    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _processingPayment = false;
        _paymentError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: CustomAppBar(title: _step == 0 ? 'Your Details' : 'Stay Info'),
      body: Column(children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: StepProgressIndicator(
            currentStep: _step,
            steps: const [
              {'Your Details': CupertinoIcons.person_fill},
              {'Stay Info': CupertinoIcons.house_fill},
            ],
          ),
        ),
        if (_paymentError.isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: _red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _red.withOpacity(0.3)),
              ),
              child: Text(_paymentError,
                  style: TextStyle(color: _red, fontSize: 12.sp)),
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
            child: _step == 0 ? _step0() : _step1(),
          ),
        ),
        _bottomBar(),
      ]),
    );
  }

  // ── Step 0: Personal details ──────────────────────────────────────────────

  Widget _step0() => Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Full Name'),
        _field(_nameCtrl, 'John Doe'),
        SizedBox(height: 14.h),
        _label('Phone Number'),
        _field(_phoneCtrl, '+94 7X XXX XXXX', inputType: TextInputType.phone),
        SizedBox(height: 14.h),
        _label('Email'),
        _field(_emailCtrl, 'you@email.com', inputType: TextInputType.emailAddress),
        SizedBox(height: 14.h),
        _label('Country (optional)'),
        _field(TextEditingController(text: _country), 'Your country',
            onChanged: (v) => _country = v),
        SizedBox(height: 14.h),
        _label('Gender (optional)'),
        _genderRow(),
        SizedBox(height: 14.h),
        _label('Passport Number (optional)'),
        TextField(
          onChanged: (v) => _passport = v,
          decoration: _inputDecoration('Passport number'),
          style: TextStyle(fontSize: 14.sp),
        ),
      ]);

  // ── Step 1: Stay summary + booking options ────────────────────────────────

  Widget _step1() => Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _staySummaryCard(),
        SizedBox(height: 16.h),
        _label('Booking Type'),
        _bookingTypeRow(),
        SizedBox(height: 14.h),
        _label('Guests'),
        _counterRow('Guests', _guestCount, (v) => setState(() => _guestCount = v),
            min: 1, max: (_stay['max_guests'] as int?) ?? 10),
        SizedBox(height: 8.h),
        _label('Rooms'),
        _counterRow('Rooms', _roomCount, (v) => setState(() => _roomCount = v),
            min: 1, max: (_stay['room_count'] as int?) ?? 10),
        SizedBox(height: 14.h),
        _label('Meal Preference'),
        _mealRow(),
        SizedBox(height: 14.h),
        _label('Special Note (optional)'),
        TextField(
          controller: _noteCtrl,
          maxLines: 3,
          decoration: _inputDecoration('Any special requests…'),
          style: TextStyle(fontSize: 13.sp),
        ),
        SizedBox(height: 20.h),
        _paymentHoldCard(),
      ]);

  Widget _paymentHoldCard() => Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: _blue.withOpacity(0.04),
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: _blue.withOpacity(0.15)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(CupertinoIcons.lock_shield_fill, color: _blue, size: 14.w),
        SizedBox(width: 6.w),
        Text('Secure Payment Hold', style: TextStyle(
            color: _blue, fontSize: 12.sp, fontWeight: FontWeight.w700)),
      ]),
      SizedBox(height: 6.h),
      Text(
        'Your card will be authorised for LKR ${_total.toStringAsFixed(0)} '
            'but NOT charged until the host confirms your request.',
        style: TextStyle(color: _gray, fontSize: 11.sp, height: 1.5),
      ),
    ]),
  );

  Widget _staySummaryCard() => Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: Column(children: [
      _row(CupertinoIcons.house_fill,       'Stay',     (_stay['name'] as String?) ?? ''),
      _row(CupertinoIcons.calendar,          'Check-in', _checkin),
      _row(CupertinoIcons.calendar,          'Check-out',_checkout),
      _row(CupertinoIcons.moon_stars_fill,   'Nights',   '$_nights'),
      _row(CupertinoIcons.money_dollar_circle,'Total',   'LKR ${_total.toStringAsFixed(0)}'),
    ]),
  );

  Widget _row(IconData icon, String label, String value) => Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Row(children: [
      Icon(icon, color: _blue, size: 14.w),
      SizedBox(width: 8.w),
      Text(label, style: TextStyle(color: _gray, fontSize: 12.sp)),
      const Spacer(),
      Text(value, style: TextStyle(
          color: _dark, fontSize: 13.sp, fontWeight: FontWeight.w700)),
    ]),
  );

  Widget _bookingTypeRow() {
    final types = [
      ('per_night',    'Per Night'),
      ('entire_place', 'Entire Place'),
      if ((_stay['halfday_available'] as bool?) == true) ('halfday', 'Half Day'),
    ];
    return Wrap(spacing: 8.w, children: types.map((t) => ChoiceChip(
      label: Text(t.$2),
      selected: _bookingType == t.$1,
      onSelected: (_) => setState(() => _bookingType = t.$1),
      selectedColor: _blue,
      labelStyle: TextStyle(
        color: _bookingType == t.$1 ? Colors.white : _dark,
        fontSize: 12.sp,
      ),
    )).toList());
  }

  Widget _mealRow() {
    const meals = [
      ('none',    'No Pref'),
      ('veg',     'Veg'),
      ('non_veg', 'Non-Veg'),
      ('halal',   'Halal'),
    ];
    return Wrap(spacing: 8.w, children: meals.map((m) => ChoiceChip(
      label: Text(m.$2),
      selected: _mealPreference == m.$1,
      onSelected: (_) => setState(() => _mealPreference = m.$1),
      selectedColor: _blue,
      labelStyle: TextStyle(
        color: _mealPreference == m.$1 ? Colors.white : _dark,
        fontSize: 12.sp,
      ),
    )).toList());
  }

  Widget _genderRow() {
    const genders = [('male', 'Male'), ('female', 'Female'), ('other', 'Other')];
    return Wrap(spacing: 8.w, children: genders.map((g) => ChoiceChip(
      label: Text(g.$2),
      selected: _gender == g.$1,
      onSelected: (_) => setState(() => _gender = g.$1),
      selectedColor: _blue,
      labelStyle: TextStyle(
        color: _gender == g.$1 ? Colors.white : _dark,
        fontSize: 12.sp,
      ),
    )).toList());
  }

  Widget _counterRow(String label, int value, ValueChanged<int> onChanged,
      {required int min, required int max}) =>
      Row(children: [
        Text(label, style: TextStyle(color: _gray, fontSize: 12.sp)),
        const Spacer(),
        IconButton(
          icon: const Icon(CupertinoIcons.minus_circle),
          color: value <= min ? _gray : _blue,
          onPressed: value <= min ? null : () => onChanged(value - 1),
        ),
        Text('$value', style: TextStyle(
            fontSize: 15.sp, fontWeight: FontWeight.w700, color: _dark)),
        IconButton(
          icon: const Icon(CupertinoIcons.add_circled),
          color: value >= max ? _gray : _blue,
          onPressed: value >= max ? null : () => onChanged(value + 1),
        ),
      ]);

  Widget _label(String t) => Padding(
    padding: EdgeInsets.only(bottom: 6.h),
    child: Text(t, style: TextStyle(
        fontSize: 13.sp, fontWeight: FontWeight.w700, color: _dark)),
  );

  Widget _field(TextEditingController ctrl, String hint, {
    TextInputType inputType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) => TextField(
    controller: ctrl,
    keyboardType: inputType,
    onChanged: onChanged,
    decoration: _inputDecoration(hint),
    style: TextStyle(fontSize: 14.sp),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: _gray, fontSize: 13.sp),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade200)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade200)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: _blue, width: 1.8)),
  );

  // ── Bottom bar ────────────────────────────────────────────────────────────

  Widget _bottomBar() {
    final loading = _processingPayment;

    if (_step == 0) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        child: SizedBox(
          width: double.infinity, height: 52.h,
          child: ElevatedButton(
            onPressed: _step0Valid
                ? () => setState(() => _step = 1) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r)),
              elevation: 0,
            ),
            child: Text('Continue', style: TextStyle(
                color: Colors.white, fontSize: 15.sp,
                fontWeight: FontWeight.w700)),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Row(children: [
        OutlinedButton(
          onPressed: loading ? null : () => setState(() => _step = 0),
          style: OutlinedButton.styleFrom(
            foregroundColor: _blue,
            side: const BorderSide(color: _blue),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          ),
          child: const Text('Back'),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SizedBox(
            height: 52.h,
            child: ElevatedButton(
              onPressed: loading ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                disabledBackgroundColor: _blue.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r)),
                elevation: 0,
              ),
              child: loading
                  ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(width: 18.w, height: 18.w,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)),
                SizedBox(width: 8.w),
                Text(
                  _processingPayment ? 'Processing…' : 'Submitting…',
                  style: TextStyle(color: Colors.white, fontSize: 13.sp,
                      fontWeight: FontWeight.w700),
                ),
              ])
                  : Text(
                'Pay & Request — LKR ${_total.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.white, fontSize: 13.sp,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}