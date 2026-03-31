// lib/features/tourist/screens/personal_information_screen.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/custom_primary_button.dart';
import 'package:yaloo/core/network/api_client.dart';
import 'package:country_picker/country_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:yaloo/features/tourist/providers/tourist_provider.dart';

// Language model (local to this screen)
class _Lang {
  final String id;
  final String name;
  final String code;
  _Lang({required this.id, required this.name, required this.code});
  factory _Lang.fromJson(Map<String, dynamic> j) =>
      _Lang(id: j['id'].toString(), name: j['name'] ?? '', code: j['code'] ?? '');
}

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});
  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  // controllers
  final _emailCtrl = TextEditingController();
  final _passportCtrl = TextEditingController();
  final _ecNameCtrl = TextEditingController();
  final _ecRelCtrl = TextEditingController();
  final _ecPhoneCtrl = TextEditingController();

  // state
  String _country = '';
  DateTime? _dob;
  String? _gender;
  String? _finalPhone;

  // languages
  List<_Lang> _allLangs = [];
  List<_Lang> _selLangs = [];

  late final ApiClient _api;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _api = ApiClient();
    _loadData();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passportCtrl.dispose();
    _ecNameCtrl.dispose();
    _ecRelCtrl.dispose();
    _ecPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // run in parallel
      final results = await Future.wait([
        _api.get('/accounts/languages/'),
        _api.get('/accounts/me/'),
      ]);

      final langList = results[0].data as List<dynamic>;
      final profile = results[1].data as Map<String, dynamic>;

      if (!mounted) return;

      final user = Supabase.instance.client.auth.currentUser;
      final touristData = (profile['tourist_profile'] as Map<String, dynamic>?) ?? profile;

      setState(() {
        _allLangs = langList.map((e) => _Lang.fromJson(e as Map<String, dynamic>)).toList();

        _emailCtrl.text = user?.email ?? '';
        _country = profile['country'] as String? ?? '';
        _gender = profile['gender'] as String?;

        final dob = profile['date_of_birth'] as String?;
        if (dob != null && dob.isNotEmpty) _dob = DateTime.tryParse(dob);

        final phone = profile['phone_number'] as String?;
        if (phone != null && phone.isNotEmpty) {
          _finalPhone = phone;
        }

        _passportCtrl.text = touristData['passport_number'] as String? ?? '';
        _ecNameCtrl.text = touristData['emergency_contact_name'] as String? ?? '';
        _ecRelCtrl.text = touristData['emergency_contact_relation'] as String? ?? '';
        _ecPhoneCtrl.text = touristData['emergency_contact_number'] as String? ?? '';

        // map selected languages
        final userLangs = profile['languages'] as List<dynamic>? ?? [];
        final ids = userLangs.map((e) => e['id'].toString()).toSet();
        _selLangs = _allLangs.where((l) => ids.contains(l.id)).toList();

        _loading = false;
      });
    } catch (e) {
      debugPrint('PersonalInfo loadData error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final payload = <String, dynamic>{
        if (_country.isNotEmpty) 'country': _country,
        if (_dob != null) 'date_of_birth': _dob!.toIso8601String().split('T').first,
        if (_gender != null) 'gender': _gender,
        if (_finalPhone != null && _finalPhone!.isNotEmpty) 'phone_number': _finalPhone,
        if (_passportCtrl.text.isNotEmpty) 'passport_number': _passportCtrl.text.trim(),
        if (_ecNameCtrl.text.isNotEmpty) 'emergency_contact_name': _ecNameCtrl.text.trim(),
        if (_ecRelCtrl.text.isNotEmpty) 'emergency_contact_relation': _ecRelCtrl.text.trim(),
        if (_ecPhoneCtrl.text.isNotEmpty) 'emergency_contact_number': _normalizePhone(_ecPhoneCtrl.text.trim()),
        // Send language ids
        'language_ids': _selLangs.map((l) => l.id).toList(),
      };

      await _api.patch('/accounts/profile/update/', data: payload);

      // Also refresh provider so profile screen updates instantly
      if (mounted) {
        await context.read<TouristProvider>().loadProfile(forceRefresh: true);
        await context.read<TouristProvider>().loadStats();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile Updated Successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context, true);
      }
    } catch (e) {
      String msg = 'Failed to save';
      if (e is DioException && e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          msg = data['error'] as String? ??
              data.entries.map((e) => '${e.key}: ${e.value}').join('\n');
        }
      } else {
        msg = 'Error: $e';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(msg), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _normalizePhone(String phone) {
    if (phone.isEmpty) return phone;
    if (phone.startsWith('+')) return phone;
    if (phone.startsWith('0')) return '+94${phone.substring(1)}';
    return '+94$phone';
  }

  void _pickCountry() {
    showCountryPicker(
        context: context, showPhoneCode: false,
        onSelect: (c) => setState(() => _country = c.name));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000),
      firstDate: DateTime(1900), lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primaryBlue)),
          child: child!),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _showLanguageDialog() {
    List<_Lang> temp = List.from(_selLangs);
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
          builder: (ctx, setDlg) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Select Languages', style: TextStyle(fontWeight: FontWeight.w800)),
            content: SizedBox(
              width: double.maxFinite, height: 400.h,
              child: _allLangs.isEmpty
                  ? const Center(child: Text('No languages available'))
                  : ListView.builder(
                  itemCount: _allLangs.length,
                  itemBuilder: (_, i) {
                    final lang = _allLangs[i];
                    final isSel = temp.any((l) => l.id == lang.id);
                    return CheckboxListTile(
                        title: Text(lang.name),
                        subtitle: Text(lang.code, style: TextStyle(color: Colors.grey.shade600)),
                        value: isSel,
                        activeColor: AppColors.primaryBlue,
                        onChanged: (v) => setDlg(() {
                          if (v == true) { temp.add(lang); }
                          else { temp.removeWhere((l) => l.id == lang.id); }
                        }));
                  }),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                  onPressed: () { setState(() => _selLangs = temp); Navigator.pop(ctx); },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(color: AppColors.primaryBlue),
            SizedBox(height: 16.h),
            Text('Loading...', style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp)),
          ])));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'Personal Information'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── BASIC INFO ──────────────────────────────────────────────────
          _header('Basic Information', Icons.person_rounded, const Color(0xFF2563EB)),
          SizedBox(height: 16.h),
          _label('Email'),
          _field(controller: _emailCtrl, icon: FontAwesomeIcons.envelope, enabled: false),
          SizedBox(height: 14.h),

          _label('Phone Number'),
          _phoneField(),
          SizedBox(height: 14.h),

          _label('Country'),
          _pickerField(
              text: _country.isEmpty ? 'Select Country' : _country,
              icon: FontAwesomeIcons.earthAmericas, onTap: _pickCountry),
          SizedBox(height: 14.h),

          _label('Date of Birth'),
          _pickerField(
              text: _dob != null ? '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}' : 'Select Date',
              icon: FontAwesomeIcons.cakeCandles, onTap: _pickDate),
          SizedBox(height: 14.h),

          _label('Gender'),
          _dropdownField(
              value: _gender, items: ['male', 'female', 'other'],
              icon: FontAwesomeIcons.venusMars,
              onChanged: (v) => setState(() => _gender = v)),
          SizedBox(height: 14.h),

          _label('Languages'),
          _pickerField(
              text: _selLangs.isEmpty ? 'Select Languages' : _selLangs.map((l) => l.name).join(', '),
              icon: FontAwesomeIcons.language, onTap: _showLanguageDialog),
          SizedBox(height: 14.h),

          _label('Passport Number'),
          _field(controller: _passportCtrl, icon: FontAwesomeIcons.passport, hint: 'Passport number'),
          SizedBox(height: 28.h),

          // ── EMERGENCY CONTACT ────────────────────────────────────────────
          _header('Emergency Contact', Icons.emergency_rounded, const Color(0xFFEF4444)),
          SizedBox(height: 16.h),

          _label('Contact Name'),
          _field(controller: _ecNameCtrl, hint: 'Full name'),
          SizedBox(height: 14.h),

          _label('Relationship'),
          _field(controller: _ecRelCtrl, hint: 'e.g. Mother, Brother, Friend'),
          SizedBox(height: 14.h),

          _label('Emergency Phone'),
          _field(controller: _ecPhoneCtrl, hint: '+94 77 123 4567 (include country code)', keyboardType: TextInputType.phone),
          SizedBox(height: 36.h),

          // ── SAVE ─────────────────────────────────────────────────────────
          CustomPrimaryButton(
              text: _saving ? 'Saving...' : 'Save Changes',
              onPressed: _saving ? null : _save),
          SizedBox(height: 24.h),
        ]),
      ),
    );
  }

  // ── WIDGET HELPERS ────────────────────────────────────────────────────────

  Widget _header(String title, IconData icon, Color color) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18)),
      SizedBox(width: 10.w),
      Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
    ]);
  }

  Widget _label(String text) => Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Text(text, style: AppTextStyles.textSmall.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF374151))));

  Widget _field({TextEditingController? controller, String? hint, IconData? icon, bool enabled = true, TextInputType? keyboardType}) {
    return Container(
        decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.secondaryGray.withOpacity(0.45)),
            boxShadow: enabled ? [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))] : null),
        child: TextField(
            controller: controller, enabled: enabled, keyboardType: keyboardType,
            style: AppTextStyles.textSmall.copyWith(color: Colors.black),
            decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AppColors.primaryGray.withOpacity(0.45)),
                prefixIcon: icon != null ? Icon(icon, color: AppColors.primaryGray, size: 17.w) : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h))));
  }

  Widget _phoneField() {
    return IntlPhoneField(
      initialValue: _finalPhone,
      disableLengthCheck: true,
      flagsButtonPadding: const EdgeInsets.only(left: 10),
      dropdownIconPosition: IconPosition.trailing,
      dropdownIcon: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryGray),
      style: AppTextStyles.textSmall.copyWith(color: Colors.black),
      decoration: InputDecoration(
          hintText: 'Phone Number',
          hintStyle: TextStyle(color: AppColors.primaryGray.withOpacity(0.45)),
          filled: true, fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.secondaryGray.withOpacity(0.45))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.secondaryGray.withOpacity(0.45))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red))),
      initialCountryCode: 'LK',
      onChanged: (phone) => _finalPhone = phone.completeNumber,
    );
  }

  Widget _pickerField({required String text, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.secondaryGray.withOpacity(0.45)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Row(children: [
              Icon(icon, color: AppColors.primaryGray, size: 17.w),
              SizedBox(width: 12.w),
              Expanded(child: Text(text,
                  style: AppTextStyles.textSmall.copyWith(
                      color: text.contains('Select') ? AppColors.primaryGray.withOpacity(0.5) : Colors.black),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: 20),
            ])));
  }

  Widget _dropdownField({required String? value, required List<String> items, required IconData icon, required Function(String?) onChanged}) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.secondaryGray.withOpacity(0.45)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(children: [
          Icon(icon, color: AppColors.primaryGray, size: 17.w),
          SizedBox(width: 12.w),
          Expanded(child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: value,
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryGray),
              isExpanded: true,
              hint: Text('Select Gender', style: TextStyle(color: AppColors.primaryGray.withOpacity(0.5), fontSize: 14.sp)),
              style: AppTextStyles.textSmall.copyWith(color: Colors.black),
              onChanged: onChanged,
              items: items.map((v) => DropdownMenuItem(value: v, child: Text('${v[0].toUpperCase()}${v.substring(1)}'))).toList()))),
        ]));
  }
}