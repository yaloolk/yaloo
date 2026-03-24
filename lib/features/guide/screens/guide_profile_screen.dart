import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/network/api_client.dart';
import 'package:yaloo/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// ─── Data models ────────────────────────────────────────────────────────────

class AvailabilitySlot {
  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool isBooked;

  const AvailabilitySlot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> j) => AvailabilitySlot(
    id:        j['id'] ?? '',
    date:      DateTime.parse(j['date']),
    startTime: j['start_time'] ?? '',
    endTime:   j['end_time']   ?? '',
    isBooked:  j['is_booked']  ?? false,
  );

  String get formattedDate => DateFormat('d MMM').format(date);
  String get timeLabel     => '${startTime.substring(0, 5)} - ${endTime.substring(0, 5)}';
}

class GuideReview {
  final String id;
  final double rating;
  final String? review;
  final String touristName;
  final String? touristPhoto;
  final DateTime createdAt;

  const GuideReview({
    required this.id,
    required this.rating,
    this.review,
    required this.touristName,
    this.touristPhoto,
    required this.createdAt,
  });

  factory GuideReview.fromJson(Map<String, dynamic> j) => GuideReview(
    id:          j['id'] ?? '',
    rating:      (j['rating'] ?? 0).toDouble(),
    review:      j['review'],
    touristName: j['tourist_name'] ?? 'Anonymous',
    touristPhoto:j['tourist_photo'],
    createdAt:   DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
  );
}

// NEW: City & Language models for dropdowns
class City {
  final String id;
  final String name;
  final String country;

  const City({required this.id, required this.name, required this.country});

  factory City.fromJson(Map<String, dynamic> j) => City(
    id: j['id'] ?? '',
    name: j['name'] ?? '',
    country: j['country'] ?? '',
  );
}

class Language {
  final String id;
  final String name;
  final String code;

  const Language({required this.id, required this.name, required this.code});

  factory Language.fromJson(Map<String, dynamic> j) => Language(
    id: j['id'] ?? '',
    name: j['name'] ?? '',
    code: j['code'] ?? '',
  );
}

class UserLanguage {
  final String languageId;
  final String name;
  String proficiency; // native, fluent, intermediate, basic

  UserLanguage({
    required this.languageId,
    required this.name,
    required this.proficiency,
  });

  factory UserLanguage.fromJson(Map<String, dynamic> j) => UserLanguage(
    languageId: j['id'] ?? '',
    name: j['name'] ?? '',
    proficiency: j['proficiency'] ?? 'native',
  );

  Map<String, dynamic> toJson() => {
    'language_id': languageId,
    'proficiency': proficiency,
  };
}

// ─── Screen ─────────────────────────────────────────────────────────────────

class GuideProfileScreen extends StatefulWidget {
  const GuideProfileScreen({super.key});

  @override
  State<GuideProfileScreen> createState() => _GuideProfileScreenState();
}

class _GuideProfileScreenState extends State<GuideProfileScreen> {
  late final ApiClient _apiClient;
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedFile;

  // ─── Loading flags ───────────────────────────────────────
  bool _isLoadingProfile      = true;
  bool _isLoadingAvailability = true;
  bool _isLoadingGallery      = true;
  bool _isUploadingPhoto      = false;

  // ─── Profile state ───────────────────────────────────────
  String  _guideId         = '';
  String  _fullName        = '';
  String? _profilePicUrl;
  String  _bio             = '';
  String  _phone           = '';
  String  _dateOfBirth     = '';
  String  _gender          = '';
  String  _country         = '';
  String  _cityId          = '';
  String  _city            = '';
  int     _experienceYears = 0;
  String  _education       = '';
  double  _ratePerHour     = 0;
  double  _avgRating       = 0;
  int     _reviewCount     = 0;
  bool    _isAvailable     = true;
  bool    _isVerified      = false;
  bool    _isSLTDAVerified = false;
  String  _memberSince     = '';

  // NEW: User languages with proficiency
  List<UserLanguage> _userLanguages = [];
  List<Map<String, dynamic>> _interests = [];

  // ─── Sub-data ────────────────────────────────────────────
  List<AvailabilitySlot>        _slots    = [];
  List<GuideReview>             _reviews  = [];
  List<Map<String, String>>     _gallery  = [];

  // NEW: Master data for dropdowns
  List<City> _allCities = [];
  List<Language> _allLanguages = [];

  // ─── Edit flags ──────────────────────────────────────────
  bool _isEditingBio = false;
  bool _isEditingPersonalInfo = false; // NEW
  late TextEditingController _bioCtrl;
  final FocusNode _bioFocus = FocusNode();

  // NEW: Controllers for personal info editing
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _educationCtrl;
  DateTime? _selectedDob;
  String? _selectedGender;
  String? _selectedCityId;

  @override
  void initState() {
    super.initState();
    _bioCtrl   = TextEditingController();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _educationCtrl = TextEditingController();
    _apiClient = ApiClient();
    _loadAll();
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _bioFocus.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _educationCtrl.dispose();
    super.dispose();
  }

  // ─── Load ────────────────────────────────────────────────

  Future<void> _loadAll() async {
    setState(() {
      _isLoadingProfile = _isLoadingAvailability = _isLoadingGallery = true;
    });
    await _loadProfile();
    _loadAvailability();
    _loadGallery();
    _loadMasterData(); // NEW
  }

  Future<void> _loadProfile() async {
    try {
      final r = await _apiClient.get('/accounts/me/');
      final d = r.data as Map<String, dynamic>;
      if (!mounted) return;

      final names = (d['full_name'] ?? '').toString().split(' ');

      setState(() {
        _guideId         = d['id'] ?? '';
        _fullName        = d['full_name'] ?? '';
        _profilePicUrl   = d['profile_pic'];
        _bio             = d['profile_bio'] ?? '';
        _phone           = d['phone_number'] ?? '';
        _dateOfBirth     = d['date_of_birth'] ?? '';
        _gender          = d['gender'] ?? '';
        _country         = d['country'] ?? '';
        _cityId          = d['city_id'] ?? '';
        _city            = (d['city'] as Map?)?.entries.map((e) {
          if (e.key == 'name') return e.value.toString();
          return null;
        }).firstWhere((v) => v != null, orElse: () => '') ?? '';
        _experienceYears = d['experience_years'] ?? 0;
        _education       = d['education'] ?? '';
        _ratePerHour     = (d['rate_per_hour'] ?? 0).toDouble();
        _avgRating       = (d['avg_rating'] ?? 0).toDouble();
        _reviewCount     = (d['stats']?['review_count'] ?? 0);
        _isAvailable     = d['is_available'] ?? true;
        _isVerified      = d['verification_status'] == 'verified';
        _isSLTDAVerified = d['is_SLTDA_verified'] ?? false;
        _memberSince     = d['member_since'] ?? '';

        // NEW: Load languages with proficiency
        _userLanguages = (d['languages'] as List<dynamic>? ?? [])
            .map((l) => UserLanguage.fromJson(l))
            .toList();

        _interests       = (d['interests'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        _reviews         = (d['reviews'] as List<dynamic>? ?? [])
            .map((r) => GuideReview.fromJson(r)).toList();

        _bioCtrl.text    = _bio;

        // NEW: Populate edit controllers
        _firstNameCtrl.text = names.isNotEmpty ? names[0] : '';
        _lastNameCtrl.text = names.length > 1 ? names.sublist(1).join(' ') : '';
        _phoneCtrl.text = _phone;
        _educationCtrl.text = _education;
        if (_dateOfBirth.isNotEmpty) {
          _selectedDob = DateTime.tryParse(_dateOfBirth);
        }
        _selectedGender = _gender.isNotEmpty ? _gender : null;
        _selectedCityId = _cityId.isNotEmpty ? _cityId : null;

        _isLoadingProfile = false;
      });
    } catch (e) {
      debugPrint('Profile load error: $e');
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _loadAvailability() async {
    try {
      final r = await _apiClient.get('/accounts/guide/availability/');
      if (!mounted) return;
      setState(() {
        _slots = (r.data as List<dynamic>)
            .map((s) => AvailabilitySlot.fromJson(s)).toList();
        _isLoadingAvailability = false;
      });
    } catch (e) {
      debugPrint('Availability load error: $e');
      if (mounted) setState(() => _isLoadingAvailability = false);
    }
  }

  Future<void> _loadGallery() async {
    try {
      final r = await _apiClient.get('/accounts/gallery/');
      if (!mounted) return;
      setState(() {
        _gallery = (r.data as List<dynamic>)
            .map((i) => {'id': i['id'].toString(), 'url': i['url'].toString()})
            .toList().cast<Map<String, String>>();
        _isLoadingGallery = false;
      });
    } catch (e) {
      debugPrint('Gallery load error: $e');
      if (mounted) setState(() => _isLoadingGallery = false);
    }
  }

  // NEW: Load cities and languages from database
  Future<void> _loadMasterData() async {
    try {
      final cities = await _apiClient.get('/accounts/cities/');
      final langs = await _apiClient.get('/accounts/languages/');
      if (!mounted) return;
      setState(() {
        _allCities = (cities.data as List<dynamic>)
            .map((c) => City.fromJson(c))
            .toList();
        _allLanguages = (langs.data as List<dynamic>)
            .map((l) => Language.fromJson(l))
            .toList();
      });
    } catch (e) {
      debugPrint('Load master data error: $e');
    }
  }

  // ─── NEW: Save Personal Info ─────────────────────────────

  Future<void> _savePersonalInfo() async {
    try {
      // FIX: Explicitly specify <String, dynamic> so 'languages' (List) can be added later
      final body = <String, dynamic>{
        'first_name': _firstNameCtrl.text.trim(),
        'last_name': _lastNameCtrl.text.trim(),
        'phone_number': _phoneCtrl.text.trim(),
        'education': _educationCtrl.text.trim(),
      };

      if (_selectedDob != null) {
        body['date_of_birth'] = DateFormat('yyyy-MM-dd').format(_selectedDob!);
      }
      if (_selectedGender != null) {
        body['gender'] = _selectedGender!;
      }
      if (_selectedCityId != null) {
        body['city_id'] = _selectedCityId!;
      }

      // Send languages
      if (_userLanguages.isNotEmpty) {
        body['languages'] = _userLanguages.map((l) => l.toJson()).toList();
      }

      await _apiClient.patch('/accounts/guide/profile/update/', data: body);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated ✓'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
        await _loadProfile();
      }
    } catch (e) {
      debugPrint('Save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _togglePersonalInfoEdit() async {
    if (_isEditingPersonalInfo) {
      await _savePersonalInfo();
    }
    setState(() => _isEditingPersonalInfo = !_isEditingPersonalInfo);
  }

  // ─── Availability management ─────────────────────────────

  Future<void> _addAvailability({
    String? singleDate,
    String? startDate,
    String? endDate,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final body = <String, dynamic>{
        'start_time': startTime,
        'end_time':   endTime,
      };
      if (singleDate != null) {
        body['date'] = singleDate;
      } else {
        body['start_date'] = startDate;
        body['end_date']   = endDate;
      }
      await _apiClient.post('/accounts/guide/availability/add/', data: body);
      await _loadAvailability();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Availability saved ✓'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      debugPrint('Add availability error: $e');
    }
  }

  Future<void> _deleteSlot(String slotId) async {
    try {
      await _apiClient.delete('/accounts/guide/availability/$slotId/delete/');
      setState(() => _slots.removeWhere((s) => s.id == slotId));
    } catch (e) {
      debugPrint('Delete slot error: $e');
    }
  }

  Future<void> _toggleAvailable() async {
    try {
      final r = await _apiClient.post('/accounts/guide/availability/toggle/');
      setState(() => _isAvailable = r.data['is_available'] ?? _isAvailable);
    } catch (e) {
      debugPrint('Toggle error: $e');
    }
  }


  void _showTimeSlotsDialog(DateTime date) {
    final daySlots = _slots
        .where((s) =>
    s.date.year == date.year &&
        s.date.month == date.month &&
        s.date.day == date.day)
        .toList();

    if (daySlots.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7, // Max 70% of screen height
            maxWidth: 400.w,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fixed header
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE').format(date),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            DateFormat('d MMMM yyyy').format(date),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${daySlots.length} time slot${daySlots.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(Icons.close, size: 22.w),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        shape: const CircleBorder(),
                        padding: EdgeInsets.all(8.w),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(20.w),
                  itemCount: daySlots.length,
                  itemBuilder: (_, index) {
                    final slot = daySlots[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: slot.isBooked
                              ? const Color(0xFFFFFBEB)
                              : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: slot.isBooked
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFFBBF7D0),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Time icon
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: slot.isBooked
                                    ? Colors.amber.shade100
                                    : const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.access_time,
                                size: 18.w,
                                color: slot.isBooked
                                    ? Colors.amber.shade800
                                    : const Color(0xFF166534),
                              ),
                            ),
                            SizedBox(width: 12.w),

                            // Time label
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    slot.timeLabel,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  if (slot.isBooked) ...[
                                    SizedBox(height: 2.h),
                                    Text(
                                      'This slot is booked',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.amber.shade800,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Action button
                            if (slot.isBooked)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(
                                    color: Colors.amber.shade300,
                                  ),
                                ),
                                child: Text(
                                  'Booked',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              )
                            else
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _deleteSlot(slot.id);
                                },
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 20.w,
                                  color: Colors.red.shade400,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red.shade50,
                                  shape: const CircleBorder(),
                                  padding: EdgeInsets.all(8.w),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NEW: Language dialogs
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Language',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close, size: 20.w),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                constraints: BoxConstraints(maxHeight: 400.h),
                child: _allLanguages.isEmpty
                    ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.h),
                    child: Text('Loading languages...',
                        style: TextStyle(color: Colors.grey.shade500)),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _allLanguages.length,
                  itemBuilder: (_, i) {
                    final lang = _allLanguages[i];
                    final exists = _userLanguages.any((ul) => ul.languageId == lang.id);
                    return ListTile(
                      title: Text(lang.name, style: TextStyle(fontSize: 14.sp)),
                      trailing: exists
                          ? Icon(Icons.check, color: AppColors.primaryBlue, size: 20.w)
                          : null,
                      onTap: exists
                          ? null
                          : () {
                        Navigator.pop(ctx);
                        _showProficiencyDialog(lang);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showProficiencyDialog(Language lang) async {
    // Match the backend enum: basic, conversational, native
    final validProficiencies = ['native', 'conversational', 'basic'];

    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Proficiency for ${lang.name}',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 16.h),
              ...validProficiencies.map((prof) => ListTile(
                title: Text(prof[0].toUpperCase() + prof.substring(1),
                    style: TextStyle(fontSize: 14.sp)),
                onTap: () => Navigator.pop(ctx, prof),
              )),
            ],
          ),
        ),
      ),
    );

    if (selected != null) {
      await _addLanguageToProfile(lang, selected);
    }
  }

  Future<void> _addLanguageToProfile(Language lang, String proficiency) async {
    try {
      final response = await _apiClient.post(
        '/accounts/guide/languages/add/',
        data: {
          'language_id': lang.id,
          'proficiency': proficiency,
        },
      );

      if (mounted) {
        // Reload profile to get updated languages with proper IDs
        await _loadProfile();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${lang.name} added ✓'),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      debugPrint('Add language error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding language: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _changeProficiency(UserLanguage ul) async {
    final validProficiencies = ['native', 'conversational', 'basic'];

    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change Proficiency',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 16.h),
              ...validProficiencies.map((prof) => ListTile(
                title: Text(prof[0].toUpperCase() + prof.substring(1),
                    style: TextStyle(fontSize: 14.sp)),
                trailing: ul.proficiency == prof
                    ? Icon(Icons.check, color: AppColors.primaryBlue, size: 20.w)
                    : null,
                onTap: () => Navigator.pop(ctx, prof),
              )),
            ],
          ),
        ),
      ),
    );

    if (selected != null && selected != ul.proficiency) {
      await _updateLanguageProficiency(ul, selected);
    }
  }

  Future<void> _updateLanguageProficiency(UserLanguage ul, String newProficiency) async {
    try {
      await _apiClient.patch(
        '/accounts/guide/languages/${ul.languageId}/update/',
        data: {'proficiency': newProficiency},
      );

      if (mounted) {
        await _loadProfile();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Proficiency updated ✓'),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      debugPrint('Update proficiency error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating proficiency: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeLanguage(UserLanguage ul) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Remove Language'),
        content: Text('Remove ${ul.name} from your profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Remove', style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiClient.delete('/accounts/guide/languages/${ul.languageId}/delete/');

        if (mounted) {
          await _loadProfile();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${ul.name} removed ✓'),
              backgroundColor: const Color(0xFF22C55E),
            ),
          );
        }
      } catch (e) {
        debugPrint('Remove language error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing language: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ─── Bio ─────────────────────────────────────────────────

  Future<void> _saveBio() async {
    try {
      await _apiClient.post(
        '/accounts/profile/bio/',
        data: {'profile_bio': _bioCtrl.text},
      );
      setState(() => _bio = _bioCtrl.text);
    } catch (e) {
      debugPrint('Bio save error: $e');
    }
  }

  void _toggleBioEdit() async {
    if (_isEditingBio) await _saveBio();
    setState(() => _isEditingBio = !_isEditingBio);
    if (_isEditingBio) {
      Future.delayed(
        const Duration(milliseconds: 100),
            () => _bioFocus.requestFocus(),
      );
    }
  }

  // ─── Photo helpers ───────────────────────────────────────

  Future<MultipartFile> _toMultipart(XFile f) async {
    if (kIsWeb) {
      return MultipartFile.fromBytes(await f.readAsBytes(), filename: f.name);
    }
    return MultipartFile.fromFile(f.path, filename: f.name);
  }

  Future<void> _uploadProfilePic(XFile f) async {
    setState(() => _isUploadingPhoto = true);
    try {
      final fd = FormData.fromMap({'profile_pic': await _toMultipart(f)});
      final r  = await _apiClient.post('/accounts/profile/picture/', data: fd);
      if (mounted) {
        setState(() {
          _profilePicUrl = r.data['profile_pic'];
          _pickedFile    = null;
        });
      }
    } catch (e) {
      debugPrint('Profile pic upload error: $e');
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _uploadGalleryPhoto(XFile f) async {
    setState(() => _isUploadingPhoto = true);
    try {
      final fd = FormData.fromMap({'photo': await _toMultipart(f)});
      final r  = await _apiClient.post('/accounts/gallery/upload/', data: fd);
      if (mounted) {
        setState(() {
          _gallery.insert(0, {
            'id':  r.data['photo_id'].toString(),
            'url': r.data['photo_url'].toString(),
          });
        });
      }
    } catch (e) {
      debugPrint('Gallery upload error: $e');
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _deleteGalleryPhoto(String id) async {
    try {
      await _apiClient.delete('/accounts/gallery/$id/');
      setState(() => _gallery.removeWhere((p) => p['id'] == id));
    } catch (e) {
      debugPrint('Delete gallery error: $e');
    }
  }

  void _showPickerOptions({required bool isProfile}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () async {
              Navigator.pop(context);
              final f = await _picker.pickImage(source: ImageSource.gallery);
              if (f != null) {
                isProfile
                    ? _uploadProfilePic(f)
                    : _uploadGalleryPhoto(f);
              }
            },
          ),
          if (!kIsWeb)
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                final f = await _picker.pickImage(source: ImageSource.camera);
                if (f != null) {
                  isProfile
                      ? _uploadProfilePic(f)
                      : _uploadGalleryPhoto(f);
                }
              },
            ),
        ]),
      ),
    );
  }

  // ─── Availability bottom sheet ───────────────────────────

  void _showAvailabilityModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AvailabilityModal(
        onSave: ({
          String? singleDate,
          String? rangeStart,
          String? rangeEnd,
          required String startTime,
          required String endTime,
        }) {
          _addAvailability(
            singleDate: singleDate,
            startDate:  rangeStart,
            endDate:    rangeEnd,
            startTime:  startTime,
            endTime:    endTime,
          );
        },
      ),
    );
  }

  // ─── Logout ──────────────────────────────────────────────

  Future<void> _handleLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Logout',
                  style: TextStyle(color: Colors.red.shade700))),
        ],
      ),
    );
    if (ok == true) {
      try {
        await SecureStorage().clearSession();
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
      if (mounted) {
        Navigator.of(context, rootNavigator: true)
            .pushNamedAndRemoveUntil('/login', (_) => false);
      }
    }
  }

  // ─────────────────────────────────────────────────────────
  // BUILD (SAME UI - just modified sections)
  // ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(color: AppColors.primaryBlue),
            SizedBox(height: 16.h),
            Text('Loading profile…',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp)),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        color: AppColors.primaryBlue,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(children: [
              SizedBox(height: 8.h),
              _buildHeroHeader(),
              SizedBox(height: 20.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(children: [
                  _buildStatsRow(),
                  SizedBox(height: 20.h),
                  _buildAboutCard(),
                  SizedBox(height: 16.h),
                  _buildLanguagesCard(), // NEW: Shows languages with proficiency
                  SizedBox(height: 16.h),
                  _buildAvailabilitySection(), // MODIFIED: Grouped by date
                  SizedBox(height: 16.h),
                  _buildGallerySection(),
                  SizedBox(height: 16.h),
                  if (_reviews.isNotEmpty) ...[
                    _buildReviewsSection(),
                    SizedBox(height: 16.h),
                  ],
                  _buildPersonalInfo(), // MODIFIED: Now editable inline
                  SizedBox(height: 16.h),
                  _buildVerificationBadge(),
                  SizedBox(height: 26.h),
                  _buildMenuTile(CupertinoIcons.question_circle,
                      'Help & Support', () {
                        Navigator.pushNamed(context, '/helpSupport');
                      }),
                  SizedBox(height: 12.h),
                  _buildMenuTile(CupertinoIcons.gear,
                      'Settings', () {
                        Navigator.pushNamed(context, '/settings');
                      }),
                  SizedBox(height: 12.h),
                  _buildLogoutTile(),
                  SizedBox(height: 48.h),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // WIDGET BUILDERS (SAME UI - some modified)
  // ─────────────────────────────────────────────────────────

  Widget _buildHeroHeader() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.38),
            blurRadius: 32,
            offset: const Offset(0, 14),
            spreadRadius: -6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.r),
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 28.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.03)],
            ),
          ),
          child: Column(children: [
            Stack(alignment: Alignment.bottomRight, children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.45), width: 4),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: CircleAvatar(
                  radius: 56.r,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: _pickedFile != null
                      ? (kIsWeb
                      ? NetworkImage(_pickedFile!.path)
                      : FileImage(File(_pickedFile!.path)))
                  as ImageProvider
                      : (_profilePicUrl?.isNotEmpty == true
                      ? NetworkImage(_profilePicUrl!)
                      : null),
                  child: (_pickedFile == null && (_profilePicUrl?.isEmpty ?? true))
                      ? Icon(CupertinoIcons.person, size: 44.w, color: Colors.white70)
                      : null,
                ),
              ),
              // Camera button
              if (!_isUploadingPhoto)
                GestureDetector(
                  onTap: () => _showPickerOptions(isProfile: true),
                  child: Container(
                    padding: EdgeInsets.all(9.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2563EB), width: 2.5),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 3))],
                    ),
                    child: Icon(Icons.camera_alt_rounded, color: const Color(0xFF2563EB), size: 16.w),
                  ),
                ),
              // Availability dot
              Positioned(
                top: 4, left: 4,
                child: GestureDetector(
                  onTap: _toggleAvailable,
                  child: Container(
                    width: 18.w, height: 18.w,
                    decoration: BoxDecoration(
                      color: _isAvailable ? const Color(0xFF22C55E) : Colors.grey.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                  ),
                ),
              ),
            ]),

            SizedBox(height: 16.h),

            // Name + verified
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                _fullName.isEmpty ? 'Guide' : _fullName,
                style: TextStyle(color: Colors.white, fontSize: 26.sp, fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
              if (_isVerified) ...[
                SizedBox(width: 8.w),
                Icon(Icons.verified_rounded, color: Colors.white, size: 22.w),
              ],
            ]),

            SizedBox(height: 8.h),

            // Rating
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.star_rounded, color: Colors.amber, size: 18.w),
              SizedBox(width: 4.w),
              Text(
                _avgRating > 0
                    ? '${_avgRating.toStringAsFixed(1)} · $_reviewCount reviews'
                    : 'No reviews yet',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13.sp),
              ),
            ]),

            SizedBox(height: 6.h),

            // Location + member since
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.location_on_outlined, color: Colors.white70, size: 14.w),
              SizedBox(width: 4.w),
              Text(
                _city.isNotEmpty ? '$_city  ·  Joined $_memberSince' : 'Joined $_memberSince',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13.sp),
              ),
            ]),

            SizedBox(height: 16.h),

            // Availability toggle pill
            GestureDetector(
              onTap: _toggleAvailable,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: _isAvailable ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 8.w, height: 8.w,
                    decoration: BoxDecoration(
                      color: _isAvailable ? const Color(0xFF22C55E) : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 7.w),
                  Text(
                    _isAvailable ? 'Available for tours' : 'Not available',
                    style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(children: [
      _statChip(Icons.attach_money_rounded,
          '\$${_ratePerHour.toStringAsFixed(0)}/hr', 'Rate'),
      SizedBox(width: 10.w),
      _statChip(Icons.work_history_rounded,
          '$_experienceYears yr${_experienceYears == 1 ? '' : 's'}', 'Experience'),
      SizedBox(width: 10.w),
      _statChip(Icons.check_circle_rounded,
          _isVerified ? 'Verified' : 'Pending', 'Status',
          accent: _isVerified ? const Color(0xFF22C55E) : Colors.orange.shade400),
    ]);
  }

  Widget _statChip(IconData icon, String value, String label,
      {Color? accent}) {
    final col = accent ?? AppColors.primaryBlue;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
                color: col.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: -4)
          ],
        ),
        child: Column(children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: col.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 20.w, color: col),
          ),
          SizedBox(height: 8.h),
          Text(value,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.sp,
                  color: const Color(0xFF111827))),
          Text(label,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  Widget _buildAboutCard() {
    // SAME AS BEFORE
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.notes_rounded, color: AppColors.primaryBlue, size: 20.w),
                ),
                SizedBox(width: 12.w),
                Text('About Me',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17.sp, color: const Color(0xFF1F2937))),
              ]),
              GestureDetector(
                onTap: _toggleBioEdit,
                child: Container(
                  padding: EdgeInsets.all(9.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    _isEditingBio ? Icons.check_rounded : Icons.edit_rounded,
                    size: 17.w,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _isEditingBio
              ? TextField(
            controller: _bioCtrl,
            focusNode: _bioFocus,
            maxLines: null,
            style: TextStyle(fontSize: 14.sp, height: 1.6),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
            ),
          )
              : Text(
            _bio.isEmpty ? 'No bio yet. Tap to add one.' : _bio,
            style: TextStyle(
                fontSize: 14.sp,
                height: 1.6,
                color: _bio.isEmpty ? Colors.grey.shade400 : const Color(0xFF374151)),
          ),
        ],
      ),
    );
  }

  // NEW: Languages card with proficiency
  Widget _buildLanguagesCard() {
    return _buildCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
                child: Icon(Icons.language_rounded, color: const Color(0xFF10B981), size: 20.w),
              ),
              SizedBox(width: 12.w),
              Text('Languages', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17.sp, color: const Color(0xFF1F2937))),
            ]),
            GestureDetector(
              onTap: _showLanguageDialog,
              child: Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(10.r)),
                child: Icon(Icons.add_rounded, size: 17.w, color: AppColors.primaryBlue),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _userLanguages.isEmpty
            ? Text('No languages added', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400))
            : Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _userLanguages.map((ul) {
            return GestureDetector(
              onTap: () => _changeProficiency(ul),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.primaryBlue.withOpacity(0.25)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.language_rounded, size: 13.w, color: AppColors.primaryBlue),
                  SizedBox(width: 5.w),
                  Text(
                    '${ul.name} · ${ul.proficiency}',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                  ),
                  SizedBox(width: 6.w),
                  GestureDetector(
                    onTap: () => _removeLanguage(ul),
                    child: Icon(Icons.close_rounded, size: 14.w, color: AppColors.primaryBlue),
                  ),
                ]),
              ),
            );
          }).toList(),
        ),
        if (_interests.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Row(children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
              child: Icon(Icons.interests_rounded, size: 15.w, color: const Color(0xFF8B5CF6)),
            ),
            SizedBox(width: 8.w),
            Text('Interests', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
          ]),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _interests
                .map((i) => _chip(i['name'] ?? '', const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)))
                .toList(),
          ),
        ],
      ]),
    );
  }

  Widget _tagSectionLabel(IconData icon, String label) {
    return Row(children: [
      Icon(icon, size: 14.w, color: Colors.grey.shade600),
      SizedBox(width: 6.w),
      Text(label,
          style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600)),
    ]);
  }

  Widget _chip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(20.r)),
      child: Text(label,
          style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor)),
    );
  }

  // MODIFIED: Availability - Grouped by date
  Widget _buildAvailabilitySection() {
    // Group slots by date
    final Map<String, List<AvailabilitySlot>> groupedSlots = {};
    for (final slot in _slots) {
      final dateKey = DateFormat('yyyy-MM-dd').format(slot.date);
      groupedSlots.putIfAbsent(dateKey, () => []).add(slot);
    }

    // Create a map for calendar markers
    final Map<DateTime, int> dateSlotCounts = {};
    for (final entry in groupedSlots.entries) {
      final date = DateTime.parse(entry.key);
      dateSlotCounts[DateTime(date.year, date.month, date.day)] = entry.value.length;
    }

    return _buildCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(Icons.calendar_month_rounded, color: const Color(0xFFF59E0B), size: 20.w),
            ),
            SizedBox(width: 12.w),
            Text('Availability', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17.sp, color: const Color(0xFF1F2937))),
          ]),
          GestureDetector(
            onTap: _showAvailabilityModal,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_rounded, size: 16.w, color: Colors.white),
                SizedBox(width: 4.w),
                Text('Add', style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ]),
        SizedBox(height: 14.h),
        _isLoadingAvailability
            ? Center(
          child: Padding(
            padding: EdgeInsets.all(20.h),
            child: CircularProgressIndicator(
                color: AppColors.primaryBlue, strokeWidth: 2),
          ),
        )
            : groupedSlots.isEmpty
            ? Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
                color: Colors.grey.shade200,
                style: BorderStyle.solid),
          ),
          child: Column(children: [
            Icon(Icons.calendar_today_outlined,
                size: 32.w, color: Colors.grey.shade400),
            SizedBox(height: 8.h),
            Text('No availability set',
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500)),
            SizedBox(height: 4.h),
            Text('Tap "Add" to set your available dates',
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 12.sp)),
          ]),
        )
            : _buildCalendarView(dateSlotCounts, groupedSlots),
      ]),
    );
  }

  Widget _buildCalendarView(
      Map<DateTime, int> dateSlotCounts,
      Map<String, List<AvailabilitySlot>> groupedSlots,
      ) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: AppColors.primaryBlue,
                size: 24.w,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: AppColors.primaryBlue,
                size: 24.w,
              ),
            ),
            calendarStyle: CalendarStyle(
              // Today's date
              todayDecoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
              // Default day style
              defaultTextStyle: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF111827),
              ),
              // Weekend style
              weekendTextStyle: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              // Outside month style
              outsideTextStyle: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade300,
              ),
              // Disable past dates
              disabledTextStyle: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade300,
              ),
            ),
            // Mark dates with availability
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                final slotCount = dateSlotCounts[normalizedDay];

                if (slotCount != null && slotCount > 0) {
                  return _buildMarkedDay(day, slotCount, false);
                }
                return null;
              },
              todayBuilder: (context, day, focusedDay) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                final slotCount = dateSlotCounts[normalizedDay];

                if (slotCount != null && slotCount > 0) {
                  return _buildMarkedDay(day, slotCount, true);
                }
                return null;
              },
            ),
            // Handle date selection
            onDaySelected: (selectedDay, focusedDay) {
              final normalizedDay = DateTime(
                selectedDay.year,
                selectedDay.month,
                selectedDay.day,
              );
              final slotCount = dateSlotCounts[normalizedDay];

              if (slotCount != null && slotCount > 0) {
                _showTimeSlotsDialog(selectedDay);
              }
            },
            // Enable/disable dates
            enabledDayPredicate: (day) {
              return !day.isBefore(
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(
              color: const Color(0xFF22C55E),
              label: 'Available slots',
            ),
            SizedBox(width: 16.w),
            _buildLegendItem(
              color: Colors.grey.shade300,
              label: 'No availability',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarkedDay(DateTime day, int slotCount, bool isToday) {
    final Color borderCol =
    isToday ? AppColors.primaryBlue : const Color(0xFF22C55E);
    final Color bgCol = isToday
        ? AppColors.primaryBlue.withOpacity(0.08)
        : const Color(0xFFDCFCE7);
    final Color numCol =
    isToday ? AppColors.primaryBlue : const Color(0xFF166534);

    return GestureDetector(
      onTap: () => _showTimeSlotsDialog(day),
      child: Container(
        margin: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: bgCol,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: borderCol, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Day number ──────────────────────────────
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: numCol,
                height: 1.1,
              ),
            ),

            SizedBox(height: 2.h),

            // ── Slot-count pill ─────────────────────────
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: borderCol,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '$slotCount',
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: color == const Color(0xFF22C55E)
                  ? const Color(0xFF22C55E)
                  : Colors.grey.shade400,
              width: 1,
            ),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }



  Widget _buildGallerySection() {
    // SAME AS BEFORE
    return _buildCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(color: const Color(0xFFEC4899).withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(Icons.photo_library_rounded, color: const Color(0xFFEC4899), size: 20.w),
            ),
            SizedBox(width: 12.w),
            Text('Gallery', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17.sp, color: const Color(0xFF1F2937))),
          ]),
          GestureDetector(
            onTap: () => _showPickerOptions(isProfile: false),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_photo_alternate_rounded, size: 16.w, color: AppColors.primaryBlue),
                SizedBox(width: 5.w),
                Text('Upload', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13.sp, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ]),
        SizedBox(height: 14.h),
        _isLoadingGallery
            ? Center(
          child: Padding(
            padding: EdgeInsets.all(20.h),
            child: CircularProgressIndicator(
                color: AppColors.primaryBlue, strokeWidth: 2),
          ),
        )
            : _gallery.isEmpty
            ? Container(
          width: double.infinity,
          height: 100.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text('No photos yet',
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 13.sp)),
          ),
        )
            : GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:  3,
            crossAxisSpacing: 8.w,
            mainAxisSpacing:  8.h,
          ),
          itemCount: _gallery.length,
          itemBuilder: (_, i) {
            final p = _gallery[i];
            return GestureDetector(
              onLongPress: () => _confirmDeleteGallery(p['id']!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.network(
                  p['url']!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: Icon(Icons.broken_image_outlined,
                        color: Colors.grey.shade400),
                  ),
                ),
              ),
            );
          },
        ),
      ]),
    );
  }

  Future<void> _confirmDeleteGallery(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Delete Photo'),
        content: const Text('Remove this photo from your gallery?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Delete',
                  style: TextStyle(color: Colors.red.shade600))),
        ],
      ),
    );
    if (ok == true) _deleteGalleryPhoto(id);
  }

  Widget _buildReviewsSection() {
    // SAME AS BEFORE
    return _buildCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.12), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.star_rounded, color: Colors.amber, size: 20.w),
          ),
          SizedBox(width: 12.w),
          Text('Reviews', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17.sp, color: const Color(0xFF1F2937))),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text('$_reviewCount',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
          ),
          const Spacer(),
          Row(children: [
            Icon(Icons.star_rounded, color: Colors.amber, size: 16.w),
            SizedBox(width: 2.w),
            Text(_avgRating.toStringAsFixed(1),
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.sp, color: const Color(0xFF1F2937))),
          ]),
        ]),
        SizedBox(height: 16.h),
        ..._reviews
            .take(3)
            .map((r) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _reviewTile(r),
        ))
            .toList(),
      ]),
    );
  }

  Widget _reviewTile(GuideReview r) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: r.touristPhoto?.isNotEmpty == true
                ? NetworkImage(r.touristPhoto!)
                : null,
            child: r.touristPhoto?.isEmpty ?? true
                ? Text(r.touristName.isNotEmpty
                ? r.touristName[0].toUpperCase()
                : '?',
                style: TextStyle(
                    fontSize: 14.sp, fontWeight: FontWeight.w600))
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.touristName,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13.sp)),
              Text(DateFormat('d MMM yyyy').format(r.createdAt),
                  style: TextStyle(
                      fontSize: 11.sp, color: Colors.grey.shade500)),
            ]),
          ),
          Row(
            children: List.generate(
              5,
                  (i) => Icon(
                i < r.rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 14.w,
                color: Colors.amber,
              ),
            ),
          ),
        ]),
        if (r.review?.isNotEmpty == true) ...[
          SizedBox(height: 8.h),
          Text(r.review!,
              style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.5,
                  color: const Color(0xFF374151))),
        ],
      ]),
    );
  }

  // MODIFIED: Personal Info - Now editable inline
  Widget _buildPersonalInfo() {
    return _buildCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(color: const Color(0xFF6B7280).withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
                child: Icon(Icons.person_outline_rounded, color: const Color(0xFF6B7280), size: 20.w),
              ),
              SizedBox(width: 12.w),
              Text('Personal Information',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17.sp, color: const Color(0xFF1F2937))),
            ]),
            GestureDetector(
              onTap: _togglePersonalInfoEdit,
              child: Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  _isEditingPersonalInfo ? Icons.check_rounded : Icons.edit_rounded,
                  size: 17.w,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // First Name
        _isEditingPersonalInfo
            ? _buildEditField('First Name', _firstNameCtrl)
            : _infoRow(Icons.person_outline, 'First Name', _firstNameCtrl.text),
        _divider(),

        // Last Name
        _isEditingPersonalInfo
            ? _buildEditField('Last Name', _lastNameCtrl)
            : _infoRow(Icons.person_outline, 'Last Name', _lastNameCtrl.text),
        _divider(),

        // Phone
        _isEditingPersonalInfo
            ? _buildEditField('Phone', _phoneCtrl)
            : _infoRow(Icons.phone_outlined, 'Phone', _phone),
        _divider(),

        // DOB
        _isEditingPersonalInfo
            ? _buildDatePicker()
            : _infoRow(Icons.cake_outlined, 'Date of Birth', _dateOfBirth),
        _divider(),

        // Gender
        _isEditingPersonalInfo
            ? _buildGenderPicker()
            : _infoRow(Icons.people_outline, 'Gender',
            _gender.isNotEmpty ? _gender[0].toUpperCase() + _gender.substring(1) : '—'),
        _divider(),

        // Country (locked)
        _infoRow(Icons.public_outlined, 'Country', _country),
        _divider(),

        // City
        _isEditingPersonalInfo
            ? _buildCityPicker()
            : _infoRow(Icons.location_city_outlined, 'City', _city),

        // City change warning
        if (_isEditingPersonalInfo && _selectedCityId != null && _selectedCityId != _cityId) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'You can only guide in this city\'s region',
                    style: TextStyle(fontSize: 12.sp, color: Colors.orange.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (_education.isNotEmpty || _isEditingPersonalInfo) ...[
          _divider(),
          _isEditingPersonalInfo
              ? _buildEditField('Education', _educationCtrl)
              : _infoRow(Icons.school_outlined, 'Education', _education),
        ],
      ]),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          style: TextStyle(fontSize: 14.sp),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date of Birth',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDob ?? DateTime(1995),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() => _selectedDob = picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDob != null
                      ? DateFormat('d MMM yyyy').format(_selectedDob!)
                      : 'Not set',
                  style: TextStyle(fontSize: 14.sp),
                ),
                Icon(Icons.calendar_today_outlined,
                    size: 16.w, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              isExpanded: true,
              hint: Text('Select gender', style: TextStyle(fontSize: 14.sp)),
              items: ['male', 'female', 'other']
                  .map((g) => DropdownMenuItem(
                value: g,
                child: Text(g[0].toUpperCase() + g.substring(1),
                    style: TextStyle(fontSize: 14.sp)),
              ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedGender = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('City',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCityId,
              isExpanded: true,
              hint: Text('Select city', style: TextStyle(fontSize: 14.sp)),
              items: _allCities
                  .map((c) => DropdownMenuItem(
                value: c.id,
                child: Text(c.name, style: TextStyle(fontSize: 14.sp)),
              ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCityId = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 16.w),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11.sp, color: Colors.grey.shade500)),
            Text(value.isEmpty ? '—' : value,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937))),
          ]),
        ),
      ]),
    );
  }

  Widget _divider() => Divider(
      color: Colors.grey.shade100, height: 20.h, thickness: 1);

  Widget _buildVerificationBadge() {
    // SAME AS BEFORE
    return _buildCard(
      child: Row(children: [
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: _isVerified ? const Color(0xFFDCFCE7) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: _isVerified
                ? [BoxShadow(color: const Color(0xFF22C55E).withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))]
                : [],
          ),
          child: Icon(
            _isVerified ? Icons.verified_user_rounded : Icons.pending_rounded,
            color: _isVerified ? const Color(0xFF166534) : Colors.grey.shade500,
            size: 26.w,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(
                _isVerified ? 'Verified by Yaloo' : 'Verification Pending',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.sp, color: const Color(0xFF1F2937)),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _isVerified ? const Color(0xFFDCFCE7) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _isVerified ? 'Verified' : 'Pending',
                  style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: _isVerified ? const Color(0xFF166534) : Colors.grey.shade600),
                ),
              ),
            ]),
            SizedBox(height: 4.h),
            Text(
              _isSLTDAVerified ? 'SLTDA Certified · Government ID on file' : 'Government ID on file',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500, height: 1.4),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap) {
    return _buildCard(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: GestureDetector(
        onTap: onTap,
        child: Row(children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: const Color(0xFF6B7280).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: const Color(0xFF4B5563), size: 20.w),
          ),
          SizedBox(width: 14.w),
          Expanded(child: Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)))),
          Icon(Icons.arrow_forward_ios_rounded, size: 14.w, color: Colors.grey.shade400),
        ]),
      ),
    );
  }

  Widget _buildLogoutTile() {
    return GestureDetector(
      onTap: _handleLogout,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(0.08),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.25)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.logout_rounded, color: const Color(0xFFEF4444), size: 20.w),
          SizedBox(width: 10.w),
          Text('Logout', style: TextStyle(color: const Color(0xFFEF4444), fontSize: 16.sp, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

// ─── AVAILABILITY MODAL (SAME AS BEFORE) ─────────────────────────────────────

typedef AvailabilitySaveCallback = void Function({
String? singleDate,
String? rangeStart,
String? rangeEnd,
required String startTime,
required String endTime,
});

class _AvailabilityModal extends StatefulWidget {
  final AvailabilitySaveCallback onSave;
  const _AvailabilityModal({required this.onSave});

  @override
  State<_AvailabilityModal> createState() => _AvailabilityModalState();
}

class _AvailabilityModalState extends State<_AvailabilityModal> {
  int _mode = 0;
  DateTime? _singleDate;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool        _entireDay = false;
  TimeOfDay   _startTime = const TimeOfDay(hour: 9,  minute: 0);
  TimeOfDay   _endTime   = const TimeOfDay(hour: 17, minute: 0);

  bool get _isValid {
    final hasDate = _mode == 0
        ? _singleDate != null
        : (_rangeStart != null && _rangeEnd != null);
    return hasDate && (_entireDay || _startTime != _endTime);
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (_mode == 0) {
        _singleDate = picked;
      } else if (isStart) {
        _rangeStart = picked;
        if (_rangeEnd != null && _rangeEnd!.isBefore(picked)) _rangeEnd = null;
      } else {
        _rangeEnd = picked;
      }
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => isStart ? _startTime = picked : _endTime = picked);
  }

  void _save() {
    if (!_isValid) return;

    final st = _entireDay ? '00:00' : _fmt(_startTime);
    final et = _entireDay ? '23:59' : _fmt(_endTime);

    if (_mode == 0) {
      widget.onSave(
        singleDate: DateFormat('yyyy-MM-dd').format(_singleDate!),
        startTime:  st,
        endTime:    et,
      );
    } else {
      widget.onSave(
        rangeStart: DateFormat('yyyy-MM-dd').format(_rangeStart!),
        rangeEnd:   DateFormat('yyyy-MM-dd').format(_rangeEnd!),
        startTime:  st,
        endTime:    et,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text('Set Availability',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp)),
          SizedBox(height: 4.h),
          Text('Choose one day or a date range',
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 13.sp)),
          SizedBox(height: 20.h),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(children: [
              _modeTab(0, 'Single Day'),
              _modeTab(1, 'Date Range'),
            ]),
          ),
          SizedBox(height: 20.h),
          if (_mode == 0)
            _datePickerRow(
              label:       'Date',
              value:       _singleDate != null
                  ? DateFormat('EEE, d MMM yyyy').format(_singleDate!)
                  : 'Select a date',
              hasValue:    _singleDate != null,
              onTap:       () => _pickDate(isStart: true),
            )
          else ...[
            _datePickerRow(
              label:    'From',
              value:    _rangeStart != null
                  ? DateFormat('EEE, d MMM yyyy').format(_rangeStart!)
                  : 'Start date',
              hasValue: _rangeStart != null,
              onTap:    () => _pickDate(isStart: true),
            ),
            SizedBox(height: 10.h),
            _datePickerRow(
              label:    'To',
              value:    _rangeEnd != null
                  ? DateFormat('EEE, d MMM yyyy').format(_rangeEnd!)
                  : 'End date',
              hasValue: _rangeEnd != null,
              onTap:    () => _pickDate(isStart: false),
            ),
          ],
          SizedBox(height: 20.h),
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Entire Day',
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w600)),
                Text('Set 00:00 – 23:59',
                    style: TextStyle(
                        fontSize: 12.sp, color: Colors.grey.shade500)),
              ]),
            ),
            Switch(
              value:    _entireDay,
              onChanged: (v) => setState(() => _entireDay = v),
              activeColor: AppColors.primaryBlue,
            ),
          ]),
          SizedBox(height: 16.h),
          if (!_entireDay) ...[
            Row(children: [
              Expanded(
                child: _timePickerBox(
                  label: 'Start Time',
                  time:  _startTime,
                  onTap: () => _pickTime(isStart: true),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _timePickerBox(
                  label: 'End Time',
                  time:  _endTime,
                  onTap: () => _pickTime(isStart: false),
                ),
              ),
            ]),
            SizedBox(height: 20.h),
          ],
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _isValid ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                disabledBackgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r)),
                elevation: 0,
              ),
              child: Text(
                'Save Availability',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _modeTab(int idx, String label) {
    final active = _mode == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = idx),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : Colors.grey.shade600)),
          ),
        ),
      ),
    );
  }

  Widget _datePickerRow({
    required String label,
    required String value,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(children: [
          Icon(Icons.calendar_today_outlined,
              size: 18.w,
              color: hasValue ? AppColors.primaryBlue : Colors.grey.shade400),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11.sp, color: Colors.grey.shade500)),
              Text(value,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: hasValue
                          ? const Color(0xFF1F2937)
                          : Colors.grey.shade400)),
            ]),
          ),
          Icon(Icons.chevron_right,
              color: Colors.grey.shade400, size: 18.w),
        ]),
      ),
    );
  }

  Widget _timePickerBox({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(children: [
          Icon(Icons.access_time,
              size: 16.w, color: AppColors.primaryBlue),
          SizedBox(width: 8.w),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11.sp, color: Colors.grey.shade500)),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:'
                  '${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937)),
            ),
          ]),
        ]),
      ),
    );
  }
}