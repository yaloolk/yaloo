// lib/features/tourist/screens/host/stay_booking_form_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/custom_primary_button.dart';
import 'package:yaloo/core/widgets/step_progress_indicator.dart';
import '../../providers/stay_booking_provider.dart';
import '../../models/stay_booking_model.dart';

const _blue   = Color(0xFF2563EB);
const _dark   = Color(0xFF1F2937);
const _gray   = Color(0xFF6B7280);
const _green  = Color(0xFF10B981);
const _bgPage = Color(0xFFF8FAFC);

class StayBookingFormScreen extends StatefulWidget {
  const StayBookingFormScreen({super.key});
  @override State<StayBookingFormScreen> createState() => _StayBookingFormScreenState();
}

class _StayBookingFormScreenState extends State<StayBookingFormScreen> {
  // Args passed from Host Detail Screen
  Map<String, dynamic> _stay       = {};
  String               _checkin    = '';
  String               _checkout   = '';
  bool                 _argsLoaded = false;

  int    _step       = 0; // 0 = personal details, 1 = stay info / confirm
  int    _guestCount = 1;
  int    _roomCount  = 1;
  String _bookingType    = 'per_night';
  String _mealPreference = 'none';

  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _noteCtrl  = TextEditingController();
  String _country  = '';
  String _gender   = '';
  String _passport = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;
    _argsLoaded = true;
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final stay    = args['stay']     as StaySearchResult;   // ← typed correctly
    final profile = args['profile']  as Map<String, dynamic>?;
    final checkin  = args['checkin']  as String? ?? '';
    final checkout = args['checkout'] as String? ?? '';
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

  double get _total => _pricePerNight * (_bookingType == 'halfday' ? 1 : _nights);

  // ── Validation ────────────────────────────────────────────────────────────

  bool get _step0Valid =>
      _nameCtrl.text.trim().isNotEmpty &&
          _phoneCtrl.text.trim().isNotEmpty &&
          _emailCtrl.text.trim().isNotEmpty;

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _confirm() async {
    if (_stay['stay_id'] == null) {
      _snack('Stay information missing'); return;
    }
    final prov = context.read<StayBookingProvider>();
    final ok = await prov.createBooking(
      stayId:          _stay['stay_id'] as String,
      checkinDate:     _checkin,
      checkoutDate:    _checkout,
      bookingType:     _bookingType,
      roomCount:       _roomCount,
      guestCount:      _guestCount,
      mealPreference:  _mealPreference,
      specialNote:     _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
      touristFullName: _nameCtrl.text.trim(),
      touristPassport: _passport.isNotEmpty ? _passport : null,
      touristPhone:    _phoneCtrl.text.trim(),
      touristEmail:    _emailCtrl.text.trim(),
      touristCountry:  _country.isNotEmpty ? _country : null,
      touristGender:   _gender.isNotEmpty  ? _gender  : null,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/stayBookingConfirmation',
          arguments: prov.lastCreatedBooking);
    } else {
      _snack(prov.createError.isNotEmpty ? prov.createError : 'Booking failed');
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
        // Step indicator
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: StepProgressIndicator(
            currentStep: _step,
            steps: const [
              {'Details': FontAwesomeIcons.user},
              {'Stay Info': FontAwesomeIcons.house},
            ],
          ),
        ),
        Expanded(child: _step == 0 ? _step0() : _step1()),
      ]),
    );
  }

  // ── STEP 0: Personal details ──────────────────────────────────────────────

  Widget _step0() => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 120.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 8.h),
      _sectionTitle('Personal Information'),
      Text('Fill in your details for the host.',
          style: TextStyle(color: _gray, fontSize: 12.sp)),
      SizedBox(height: 20.h),

      _field('Full Name', _nameCtrl, CupertinoIcons.person, req: true),
      SizedBox(height: 14.h),
      _field('Phone Number', _phoneCtrl, CupertinoIcons.phone,
          req: true, keyboard: TextInputType.phone),
      SizedBox(height: 14.h),
      _field('Email Address', _emailCtrl, CupertinoIcons.mail,
          req: true, keyboard: TextInputType.emailAddress),
      SizedBox(height: 14.h),
      _field('Passport Number (optional)', TextEditingController(text: _passport),
          FontAwesomeIcons.passport,
          onChanged: (v) => _passport = v),
      SizedBox(height: 14.h),

      // Country picker
      _lbl('Country (optional)'),
      _dropField(_country.isEmpty ? 'Select country' : _country,
          CupertinoIcons.globe, () => _showCountryPicker()),
      SizedBox(height: 14.h),

      // Gender
      _lbl('Gender (optional)'),
      _dropField(_gender.isEmpty ? 'Select gender' : _gender,
          CupertinoIcons.person_2, () => _showGenderPicker()),

      SizedBox(height: 32.h),
      CustomPrimaryButton(
        text: 'Next →',
        onPressed: _step0Valid
            ? () => setState(() => _step = 1)
            : null,
      ),
    ]),
  );

  // ── STEP 1: Stay info + confirm ────────────────────────────────────────────

  Widget _step1() => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 120.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 8.h),
      _stayCard(),
      SizedBox(height: 16.h),
      _bookingTypeSelector(),
      SizedBox(height: 16.h),
      _countersRow(),
      SizedBox(height: 16.h),
      _mealSelector(),
      SizedBox(height: 16.h),
      _noteField(),
      SizedBox(height: 16.h),
      _priceSummaryCard(),
      SizedBox(height: 24.h),
      Consumer<StayBookingProvider>(
        builder: (_, prov, __) => CustomPrimaryButton(
          text: 'Confirm Booking',
          isLoading: prov.createLoading,
          onPressed: prov.createLoading ? null : _confirm,
        ),
      ),
    ]),
  );

  Widget _stayCard() => Container(
    padding: EdgeInsets.all(14.w),
    decoration: _cardDec(),
    child: Row(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
            width: 72.w, height: 72.h,
            color: Colors.grey.shade100,
            child: Icon(CupertinoIcons.house, color: Colors.grey.shade300, size: 32.w)),
      ),
      SizedBox(width: 12.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_stay['name'] ?? 'Stay', style: TextStyle(
            fontSize: 15.sp, fontWeight: FontWeight.w800, color: _dark)),
        SizedBox(height: 4.h),
        if ((_stay['city_name'] ?? '').isNotEmpty)
          Row(children: [
            Icon(CupertinoIcons.map_pin, color: _gray, size: 11.w),
            SizedBox(width: 3.w),
            Text(_stay['city_name'], style: TextStyle(color: _gray, fontSize: 11.sp)),
          ]),
        SizedBox(height: 6.h),
        Row(children: [
          Icon(CupertinoIcons.calendar, color: _blue, size: 12.w),
          SizedBox(width: 4.w),
          Text('$_checkin → $_checkout',
              style: TextStyle(color: _blue, fontSize: 11.sp, fontWeight: FontWeight.w700)),
        ]),
      ])),
    ]),
  );

  Widget _bookingTypeSelector() => Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
    _sectionTitle('Booking Type'),
    SizedBox(height: 10.h),
    Row(children: [
      Expanded(child: _typeChip('per_night', 'Per Night', CupertinoIcons.moon)),
      SizedBox(width: 8.w),
      if ((_stay['entire_place_is_available'] ?? false) == true)
        Expanded(child: _typeChip('entire_place', 'Entire Place', CupertinoIcons.home)),
      if ((_stay['halfday_available'] ?? false) == true) ...[
        SizedBox(width: 8.w),
        Expanded(child: _typeChip('halfday', 'Half Day', CupertinoIcons.sun_max)),
      ],
    ]),
  ]);

  Widget _typeChip(String val, String label, IconData icon) {
    final sel = _bookingType == val;
    return GestureDetector(
      onTap: () => setState(() => _bookingType = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
            gradient: sel ? const LinearGradient(colors: [_blue, Color(0xFF1D4ED8)]) : null,
            color: sel ? null : Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: sel ? _blue : Colors.grey.shade200),
            boxShadow: sel ? [BoxShadow(color: _blue.withOpacity(0.3), blurRadius: 10,
                offset: const Offset(0,4))] : null),
        child: Column(children: [
          Icon(icon, color: sel ? Colors.white : _blue, size: 20.w),
          SizedBox(height: 5.h),
          Text(label, style: TextStyle(color: sel ? Colors.white : _dark,
              fontSize: 11.sp, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _countersRow() => Row(children: [
    Expanded(child: _counterCard('Guests', _guestCount,
        onDec: _guestCount > 1 ? () => setState(() => _guestCount--) : null,
        onInc: () => setState(() => _guestCount++))),
    SizedBox(width: 12.w),
    Expanded(child: _counterCard('Rooms', _roomCount,
        onDec: _roomCount > 1 ? () => setState(() => _roomCount--) : null,
        onInc: () => setState(() => _roomCount++))),
  ]);

  Widget _counterCard(String label, int val, {VoidCallback? onDec, required VoidCallback onInc}) =>
      Container(
        padding: EdgeInsets.all(14.w),
        decoration: _cardDec(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: _gray, fontSize: 12.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 10.h),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(onTap: onDec, child: _counterBtn(Icons.remove, active: onDec != null)),
            Text('$val', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: _dark)),
            GestureDetector(onTap: onInc, child: _counterBtn(Icons.add, active: true)),
          ]),
        ]),
      );

  Widget _counterBtn(IconData icon, {required bool active}) => Container(
    padding: EdgeInsets.all(7.r),
    decoration: BoxDecoration(
        color: active ? _blue.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.r)),
    child: Icon(icon, size: 14.w, color: active ? _blue : Colors.grey.shade400),
  );

  Widget _mealSelector() => Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
    _sectionTitle('Meal Preference'),
    SizedBox(height: 10.h),
    Wrap(spacing: 8.w, runSpacing: 8.h,
        children: [
          ['none',    'No Preference'],
          ['veg',     'Vegetarian'],
          ['non_veg', 'Non-Veg'],
          ['halal',   'Halal'],
        ].map((opt) {
          final sel = _mealPreference == opt[0];
          return GestureDetector(
            onTap: () => setState(() => _mealPreference = opt[0]),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                  color: sel ? _blue : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: sel ? _blue : Colors.grey.shade200)),
              child: Text(opt[1], style: TextStyle(
                  color: sel ? Colors.white : _dark,
                  fontSize: 12.sp, fontWeight: FontWeight.w600)),
            ),
          );
        }).toList()),
  ]);

  Widget _noteField() => Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
    _sectionTitle('Special Note (optional)'),
    SizedBox(height: 8.h),
    TextField(
      controller: _noteCtrl, maxLines: 3,
      style: TextStyle(fontSize: 13.sp, color: _dark),
      decoration: InputDecoration(
        hintText: 'Any preferences, dietary needs, arrival info…',
        hintStyle: TextStyle(color: _gray, fontSize: 13.sp),
        filled: true, fillColor: Colors.white,
        contentPadding: EdgeInsets.all(14.w),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(color: _blue, width: 1.5)),
      ),
    ),
  ]);

  Widget _priceSummaryCard() => Container(
    padding: EdgeInsets.all(16.w),
    decoration: _cardDec(),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Price Summary'),
      SizedBox(height: 12.h),
      _prRow('Rate', _bookingType == 'halfday'
          ? 'LKR ${_pricePerNight.toStringAsFixed(0)} (half-day)'
          : 'LKR ${_pricePerNight.toStringAsFixed(0)}/night'),
      if (_bookingType != 'halfday')
        _prRow('Nights', '$_nights'),
      _prRow('Rooms', '$_roomCount'),
      Divider(color: Colors.grey.shade100, height: 16.h),
      _prRow('Total', 'LKR ${_total.toStringAsFixed(2)}', bold: true, color: _blue),
    ]),
  );

  Widget _prRow(String l, String v, {bool bold = false, Color? color}) =>
      Padding(padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(children: [
            Text(l, style: TextStyle(color: _gray, fontSize: 12.sp)),
            const Spacer(),
            Text(v, style: TextStyle(
                color: color ?? _dark,
                fontSize: bold ? 16.sp : 13.sp,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
          ]));

  // ── Small helpers ─────────────────────────────────────────────────────────

  Widget _sectionTitle(String t) => Text(t, style: TextStyle(
      fontSize: 14.sp, fontWeight: FontWeight.w800, color: _dark));

  Widget _lbl(String t) => Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(t, style: TextStyle(color: _dark, fontWeight: FontWeight.w700, fontSize: 13.sp)));

  Widget _field(String hint, TextEditingController ctrl, IconData icon,
      {bool req = false, TextInputType? keyboard, ValueChanged<String>? onChanged}) =>
      TextField(
        controller: ctrl,
        keyboardType: keyboard,
        onChanged: onChanged ?? (_) => setState(() {}),
        style: TextStyle(fontSize: 14.sp, color: _dark),
        decoration: InputDecoration(
          hintText: hint + (req ? ' *' : ''),
          hintStyle: TextStyle(color: _gray, fontSize: 13.sp),
          prefixIcon: Icon(icon, color: _gray, size: 18.w),
          filled: true, fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: _blue, width: 1.5)),
        ),
      );

  Widget _dropField(String text, IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.shade200)),
          child: Row(children: [
            Icon(icon, color: _gray, size: 18.w),
            SizedBox(width: 12.w),
            Expanded(child: Text(text,
                style: TextStyle(color: text.contains('Select') ? _gray : _dark, fontSize: 14.sp))),
            Icon(Icons.keyboard_arrow_down, color: _gray),
          ]),
        ),
      );

  BoxDecoration _cardDec() => BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(20.r),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.045),
          blurRadius: 16, offset: const Offset(0,4))]);

  void _showCountryPicker() {
    showModalBottomSheet(context: context, builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: ['Sri Lanka','India','Germany','United Kingdom','United States','Australia','France','Japan'].map((c) =>
          ListTile(title: Text(c),
              onTap: () { setState(() => _country = c); Navigator.pop(context); })).toList(),
    ));
  }

  void _showGenderPicker() {
    showModalBottomSheet(context: context, builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: ['Male','Female','Other','Prefer not to say'].map((g) =>
          ListTile(title: Text(g),
              onTap: () { setState(() => _gender = g); Navigator.pop(context); })).toList(),
    ));
  }
}