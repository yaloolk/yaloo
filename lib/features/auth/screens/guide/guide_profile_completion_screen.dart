import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yaloo/features/auth/data/api/profile_completion_api.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';

class GuideProfileCompletionScreen extends StatefulWidget {
  const GuideProfileCompletionScreen({super.key});

  @override
  State<GuideProfileCompletionScreen> createState() =>
      _GuideProfileCompletionScreenState();
}

class _GuideProfileCompletionScreenState
    extends State<GuideProfileCompletionScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;

  late final ProfileCompletionApi _profileApi;

  // ── ALL ORIGINAL STATE & LOGIC PRESERVED ──
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  final _rateController = TextEditingController();

  Country? _selectedCountry;
  String _countryCode = '94';
  DateTime? _selectedDateOfBirth;
  String? _selectedGender;

  String? _selectedCityId;
  String? _selectedCityName;
  final Set<String> _selectedLanguageIds = {};
  final Set<String> _selectedLanguageNames = {};

  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _languages = [];

  String? _govIdFileName;
  String? _profilePhotoFileName;
  String? _licenseFileName;
  XFile? _govIdFile;
  XFile? _profilePhotoFile;
  XFile? _licenseFile;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _debugToken();

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    final apiClient = ApiClient();
    final secureStorage = SecureStorage();

    _profileApi = ProfileCompletionApi(
      apiClient: apiClient,
      secureStorage: secureStorage,
    );

    _loadCitiesAndLanguages();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _rateController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── ALL ORIGINAL LOGIC PRESERVED ──────────────────────────────────────────

  Future<void> _debugToken() async {
    final token = await SecureStorage().getAccessToken();
    if (token != null) {
      if (kDebugMode)
        print('✅ TOKEN EXISTS: ${token.substring(0, 50)}...');
    } else {
      if (kDebugMode) print('❌ NO TOKEN FOUND!');
      if (kDebugMode) print('⚠️  Please login again');
    }
  }

  Future<void> _loadCitiesAndLanguages() async {
    try {
      final cities = await _profileApi.getCities();
      final languages = await _profileApi.getLanguages();
      setState(() {
        _cities = cities;
        _languages = languages;
      });
    } catch (e) {
      _showError('Failed to load data: $e');
    }
  }

  void _onSubmitTapped() {
    if (!_validatePage1()) return;
    if (!_validatePage2()) return;
    _handleSubmitProfile();
  }

  bool _validatePage1() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showError('Please enter your phone number');
      return false;
    }
    if (_selectedCountry == null) {
      _showError('Please select your country');
      return false;
    }
    if (_selectedCityId == null) {
      _showError('Please select your city');
      return false;
    }
    if (_selectedDateOfBirth == null) {
      _showError('Please select your date of birth');
      return false;
    }
    if (_selectedGender == null) {
      _showError('Please select your gender');
      return false;
    }
    if (_selectedLanguageIds.isEmpty) {
      _showError('Please select at least one language');
      return false;
    }
    return true;
  }

  bool _validatePage2() {
    if (_govIdFile == null) {
      _showError('Please upload your government ID');
      return false;
    }
    if (_profilePhotoFile == null) {
      _showError('Please upload your profile photo');
      return false;
    }
    return true;
  }

  void _handleSubmitProfile() async {
    setState(() => _isLoading = true);
    try {
      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.first;
      final lastName =
      nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final response = await _profileApi.completeGuideProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: '+$_countryCode${_phoneController.text.trim()}',
        dateOfBirth: _formatDate(_selectedDateOfBirth!),
        gender: _selectedGender!.toLowerCase(),
        country: _selectedCountry!.name,
        cityId: _selectedCityId!,
        experienceYears:
        int.tryParse(_experienceController.text.trim()),
        education: _educationController.text.trim(),
        ratePerHour: double.tryParse(_rateController.text.trim()),
        languageIds: _selectedLanguageIds.toList(),
        governmentId: _govIdFile!,
        profilePhoto: _profilePhotoFile!,
        license: _licenseFile,
      );

      if (!mounted) return;

      final status = response['verification_status'] as String?;
      if (status == 'verified') {
        Navigator.pushNamedAndRemoveUntil(
            context, '/guideDashboard', (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, '/approvalPending', (route) => false);
      }
    } catch (e) {
      _showError('Failed to submit profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCountryPicker({bool showPhoneCode = false}) {
    showCountryPicker(
      context: context,
      showPhoneCode: showPhoneCode,
      onSelect: (Country country) {
        setState(() {
          if (showPhoneCode) {
            _countryCode = country.phoneCode;
          } else {
            _selectedCountry = country;
          }
        });
      },
    );
  }

  void _showCityPicker() {
    if (_cities.isEmpty) {
      _showError('Cities are loading...');
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              _sheetHandle(),
              _sheetHeader('Select City', Icons.location_city_outlined),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: _cities.length,
                  itemBuilder: (context, index) {
                    final city = _cities[index];
                    final isSelected =
                        _selectedCityId == city['id'];
                    return _sheetListTile(
                      title: city['name'],
                      subtitle: city['country'],
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedCityId = city['id'];
                          _selectedCityName = city['name'];
                        });
                        Navigator.pop(context);
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

  void _showLanguageMultiSelect() {
    if (_languages.isEmpty) {
      _showError('Languages are loading...');
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) =>
            StatefulBuilder(builder: (context, setSheetState) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    _sheetHandle(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue
                                  .withOpacity(0.09),
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.translate_outlined,
                                color: AppColors.primaryBlue,
                                size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select Languages',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0D1B2A),
                                  ),
                                ),
                                if (_selectedLanguageIds.isNotEmpty)
                                  Text(
                                    '${_selectedLanguageIds.length} selected',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Done',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: _languages.length,
                        itemBuilder: (context, index) {
                          final lang = _languages[index];
                          final isSelected =
                          _selectedLanguageIds.contains(lang['id']);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () {
                                setSheetState(() {
                                  if (isSelected) {
                                    _selectedLanguageIds
                                        .remove(lang['id']);
                                    _selectedLanguageNames
                                        .remove(lang['name']);
                                  } else {
                                    _selectedLanguageIds
                                        .add(lang['id']);
                                    _selectedLanguageNames
                                        .add(lang['name']);
                                  }
                                });
                                setState(() {});
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 13),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      .withOpacity(0.07)
                                      : Colors.grey[50],
                                  borderRadius:
                                  BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : Colors.grey[200]!,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lang['name'],
                                            style: TextStyle(
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? AppColors.primaryBlue
                                                  : Colors.grey[800],
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            lang['code'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 180),
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? AppColors.primaryBlue
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primaryBlue
                                              : Colors.grey[300]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 13,
                                      )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() => _selectedDateOfBirth = picked);
    }
  }

  Future<void> _pickFile(String field) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file =
    await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        switch (field) {
          case 'govId':
            _govIdFile = file;
            _govIdFileName = file.name;
            break;
          case 'profilePhoto':
            _profilePhotoFile = file;
            _profilePhotoFileName = file.name;
            break;
          case 'license':
            _licenseFile = file;
            _licenseFileName = file.name;
            break;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
                child: Text(message,
                    style: const TextStyle(fontSize: 14))),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Gradient header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.22,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF1565C0),
                    Color(0xFF1E88E5),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                            'assets/images/yaloo_logo.png'),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Guide Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            'Fill in your details to get started',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.80),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.explore_outlined,
                                color: Colors.white, size: 13),
                            SizedBox(width: 5),
                            Text(
                              'Guide',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Scrollable content ───────────────────────
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // ── Personal Information ────────
                            _sectionCard(
                              title: 'Personal Information',
                              icon: Icons.person_outline_rounded,
                              children: [
                                _formField(
                                  controller: _nameController,
                                  hint: 'Full Name',
                                  icon: Icons.person_outline,
                                ),
                                const SizedBox(height: 12),
                                _phoneField(),
                                const SizedBox(height: 12),
                                _pickerButton(
                                  hint: 'Country',
                                  icon: Icons.public_outlined,
                                  value: _selectedCountry?.name,
                                  onTap: _showCountryPicker,
                                ),
                                const SizedBox(height: 12),
                                _pickerButton(
                                  hint: 'City',
                                  icon: Icons.location_city_outlined,
                                  value: _selectedCityName,
                                  onTap: _showCityPicker,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _pickerButton(
                                        hint: 'Date of Birth',
                                        icon: Icons
                                            .calendar_today_outlined,
                                        value: _selectedDateOfBirth ==
                                            null
                                            ? null
                                            : '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}',
                                        onTap: _showDatePicker,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _dropdownField(
                                        hint: 'Gender',
                                        icon: Icons.wc_outlined,
                                        value: _selectedGender,
                                        items: [
                                          'Male',
                                          'Female',
                                          'Other',
                                          'Prefer not to say'
                                        ],
                                        onChanged: (val) => setState(
                                                () =>
                                            _selectedGender = val),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _pickerButton(
                                  hint: 'Languages Spoken',
                                  icon: Icons.translate_outlined,
                                  value: _selectedLanguageNames
                                      .isEmpty
                                      ? null
                                      : _selectedLanguageNames
                                      .join(', '),
                                  onTap: _showLanguageMultiSelect,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── Professional Details ────────
                            _sectionCard(
                              title: 'Professional Details',
                              icon: Icons.work_outline_rounded,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _formField(
                                        controller:
                                        _experienceController,
                                        hint: 'Experience (yrs)',
                                        icon: Icons.work_outline,
                                        keyboardType:
                                        TextInputType.number,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _formField(
                                        controller: _rateController,
                                        hint: 'Rate / Hour (\$)',
                                        icon: Icons
                                            .attach_money_outlined,
                                        keyboardType:
                                        TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _formField(
                                  controller: _educationController,
                                  hint: 'Education / Qualifications',
                                  icon: Icons.school_outlined,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── Verification Documents ──────
                            _sectionCard(
                              title: 'Verification Documents',
                              icon: Icons.verified_outlined,
                              subtitle:
                              'Government ID and a selfie are required. License is optional.',
                              children: [
                                _uploadButton(
                                  label: 'Government ID / Passport',
                                  icon: Icons.badge_outlined,
                                  fileName: _govIdFileName,
                                  isRequired: true,
                                  onPressed: () =>
                                      _pickFile('govId'),
                                ),
                                const SizedBox(height: 10),
                                _uploadButton(
                                  label: 'Profile Photo (selfie)',
                                  icon: Icons.camera_alt_outlined,
                                  fileName: _profilePhotoFileName,
                                  isRequired: true,
                                  onPressed: () =>
                                      _pickFile('profilePhoto'),
                                ),
                                const SizedBox(height: 10),
                                _uploadButton(
                                  label:
                                  'License / Certificate (Optional)',
                                  icon: Icons.school_outlined,
                                  fileName: _licenseFileName,
                                  isRequired: false,
                                  onPressed: () =>
                                      _pickFile('license'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // ── Submit button ───────────────
                            _submitButton(
                              label: 'Submit Profile',
                              onTap: _isLoading
                                  ? null
                                  : _onSubmitTapped,
                            ),
                            const SizedBox(height: 36),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared UI helpers ───────────────────────────────────────────────────────

  Widget _sectionCard({
    required String title,
    required IconData icon,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    color: AppColors.primaryBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0D1B2A),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _formField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w400),
          prefixIcon: Icon(icon,
              color: AppColors.primaryBlue, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _phoneField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          hintText: 'Phone Number',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: InkWell(
            onTap: () => _showCountryPicker(showPhoneCode: true),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_outlined,
                      color: AppColors.primaryBlue, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '+$_countryCode',
                    style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0D1B2A),
                        fontWeight: FontWeight.w500),
                  ),
                  Icon(Icons.arrow_drop_down,
                      color: Colors.grey[400], size: 18),
                ],
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _pickerButton({
    required String hint,
    required IconData icon,
    String? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: value != null
              ? AppColors.primaryBlue.withOpacity(0.05)
              : const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null
                ? AppColors.primaryBlue.withOpacity(0.3)
                : const Color(0xFFE8EAED),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: value != null
                  ? AppColors.primaryBlue
                  : Colors.grey[400],
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: value != null
                      ? const Color(0xFF0D1B2A)
                      : Colors.grey[400],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[400], size: 18),
          ],
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String hint,
    required IconData icon,
    String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: value != null
            ? AppColors.primaryBlue.withOpacity(0.05)
            : const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null
              ? AppColors.primaryBlue.withOpacity(0.3)
              : const Color(0xFFE8EAED),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.w400),
        items: items
            .map((item) => DropdownMenuItem<String>(
          value: item,
          child: Text(item,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis),
        ))
            .toList(),
        onChanged: onChanged,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
          TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon,
              color: value != null
                  ? AppColors.primaryBlue
                  : Colors.grey[400],
              size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
        ),
        icon: Icon(Icons.arrow_drop_down,
            color: Colors.grey[400], size: 20),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _uploadButton({
    required String label,
    required IconData icon,
    String? fileName,
    required bool isRequired,
    required VoidCallback onPressed,
  }) {
    final bool isUploaded = fileName != null;
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isUploaded
              ? AppColors.primaryBlue.withOpacity(0.07)
              : const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUploaded
                ? AppColors.primaryBlue
                : const Color(0xFFE8EAED),
            width: isUploaded ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isUploaded
                    ? AppColors.primaryBlue.withOpacity(0.12)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isUploaded
                    ? Icons.check_circle_rounded
                    : icon,
                color: isUploaded
                    ? AppColors.primaryBlue
                    : Colors.grey[500],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUploaded ? fileName : label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isUploaded
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isUploaded
                          ? AppColors.primaryBlue
                          : Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isUploaded)
                    Text(
                      isRequired ? 'Required' : 'Optional',
                      style: TextStyle(
                        fontSize: 11,
                        color: isRequired
                            ? Colors.orange[600]
                            : Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              isUploaded
                  ? Icons.edit_outlined
                  : Icons.upload_rounded,
              color: isUploaded
                  ? AppColors.primaryBlue
                  : Colors.grey[400],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _submitButton({
    required String label,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          disabledBackgroundColor:
          const Color(0xFF1565C0).withOpacity(0.45),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Bottom sheet helpers ────────────────────────────────────────────────────

  Widget _sheetHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _sheetHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D1B2A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetListTile({
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBlue.withOpacity(0.07)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryBlue
                  : Colors.grey[200]!,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Colors.grey[800],
                        fontSize: 15,
                      ),
                    ),
                    if (subtitle != null)
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500])),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded,
                    color: AppColors.primaryBlue, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}