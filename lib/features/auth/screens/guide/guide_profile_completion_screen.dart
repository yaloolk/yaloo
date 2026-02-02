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
    extends State<GuideProfileCompletionScreen> {
  bool _isLoading = false;

  late final ProfileCompletionApi _profileApi;

  // --- Page 1 Data ---
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

  // --- Page 2 Data - Changed from File to XFile ---
  String? _govIdFileName;
  String? _profilePhotoFileName;
  String? _licenseFileName;
  XFile? _govIdFile; // Changed to XFile
  XFile? _profilePhotoFile; // Changed to XFile
  XFile? _licenseFile; // Changed to XFile

  @override
  void initState() {
    super.initState();
    _debugToken();
    final dio = Dio(BaseOptions(
      baseUrl: 'http://192.168.10.23:8000/api',
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _debugToken() async {
    final token = await SecureStorage().getAccessToken();
    if (token != null) {
      if (kDebugMode) {
        print('✅ TOKEN EXISTS: ${token.substring(0, 50)}...');
      }
    } else {
      if (kDebugMode) {
        print('❌ NO TOKEN FOUND!');
      }
      if (kDebugMode) {
        print('⚠️  Please login again');
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Fixed header ───
            Padding(
              padding: EdgeInsets.only(top: 28.h, left: 24.w, right: 24.w, bottom: 4.h),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/yaloo_logo.png',
                    width: 36.w,
                    height: 36.h,
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete Your Profile',
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Fill in the details below to get started',
                        style: AppTextStyles.textSmall.copyWith(
                          color: AppColors.primaryGray,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Scrollable body ───
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),

                    // ── Section: Personal Info ──
                    _buildSectionLabel('Personal Information', Icons.person_outline),
                    SizedBox(height: 14.h),

                    _buildShadowedTextField(
                      controller: _nameController,
                      hint: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 12.h),
                    _buildPhoneField(),
                    SizedBox(height: 12.h),
                    _buildShadowedPickerButton(
                      hint: 'Country',
                      icon: Icons.public_outlined,
                      value: _selectedCountry?.name,
                      onTap: _showCountryPicker,
                    ),
                    SizedBox(height: 12.h),
                    _buildShadowedPickerButton(
                      hint: 'City',
                      icon: Icons.location_city_outlined,
                      value: _selectedCityName,
                      onTap: _showCityPicker,
                    ),
                    SizedBox(height: 12.h),

                    // ── Row: DOB + Gender side by side ──
                    Row(
                      children: [
                        Expanded(
                          child: _buildShadowedPickerButton(
                            hint: 'Date of Birth',
                            icon: Icons.calendar_today_outlined,
                            value: _selectedDateOfBirth == null
                                ? null
                                : "${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}",
                            onTap: _showDatePicker,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildShadowedDropdown(
                            hint: 'Gender',
                            icon: Icons.wc_outlined,
                            value: _selectedGender,
                            items: ['Male', 'Female', 'Other', 'Prefer not to say'],
                            onChanged: (val) {
                              setState(() {
                                _selectedGender = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    _buildShadowedPickerButton(
                      hint: 'Languages Spoken',
                      icon: Icons.translate_outlined,
                      value: _selectedLanguageNames.isEmpty
                          ? null
                          : _selectedLanguageNames.join(', '),
                      onTap: _showLanguageMultiSelect,
                    ),
                    SizedBox(height: 24.h),

                    // ── Section: Professional Details ──
                    _buildSectionLabel('Professional Details', Icons.work_outline),
                    SizedBox(height: 14.h),

                    Row(
                      children: [
                        Expanded(
                          child: _buildShadowedTextField(
                            controller: _experienceController,
                            hint: 'Experience (years)',
                            icon: Icons.work_outline,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildShadowedTextField(
                            controller: _rateController,
                            hint: 'Rate / Hour (\$)',
                            icon: Icons.attach_money_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _buildShadowedTextField(
                      controller: _educationController,
                      hint: 'Education / Qualifications',
                      icon: Icons.school_outlined,
                    ),
                    SizedBox(height: 24.h),

                    // ── Section: Verification Documents ──
                    _buildSectionLabel('Verification Documents', Icons.verified_outlined),
                    SizedBox(height: 6.h),
                    Text(
                      'Government ID and a selfie are required. License is optional.',
                      style: AppTextStyles.textSmall.copyWith(
                        color: AppColors.primaryGray,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 14.h),

                    _buildUploadButton(
                      label: 'Government ID / Passport',
                      icon: Icons.badge_outlined,
                      fileName: _govIdFileName,
                      onPressed: () => _pickFile('govId'),
                    ),
                    SizedBox(height: 12.h),
                    _buildUploadButton(
                      label: 'Profile Photo (selfie)',
                      icon: Icons.camera_alt_outlined,
                      fileName: _profilePhotoFileName,
                      onPressed: () => _pickFile('profilePhoto'),
                    ),
                    SizedBox(height: 12.h),
                    _buildUploadButton(
                      label: 'License / Certificate  (Optional)',
                      icon: Icons.school_outlined,
                      fileName: _licenseFileName,
                      onPressed: () => _pickFile('license'),
                    ),

                    // ── Submit button (bottom) ──
                    SizedBox(height: 32.h),
                    _buildSubmitButton(),
                    SizedBox(height: 36.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Section label helper
  // ─────────────────────────────────────────────
  Widget _buildSectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withAlpha(12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Icon(icon, color: AppColors.primaryBlue, size: 17.w),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Submit button
  // ─────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onSubmitTapped,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLoading ? AppColors.primaryGray : AppColors.primaryBlue,
          disabledBackgroundColor: AppColors.primaryGray,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
          width: 24.w,
          height: 24.h,
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : Text(
          'Submit Profile',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _onSubmitTapped() {
    if (!_validatePage1()) return;
    if (!_validatePage2()) return;
    _handleSubmitProfile();
  }

  // ─────────────────────────────────────────────
  // Validation (unchanged logic)
  // ─────────────────────────────────────────────
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

  // ─────────────────────────────────────────────
  // Submit handler (unchanged logic)
  // ─────────────────────────────────────────────
  void _handleSubmitProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // 1. Get the response from the API
      final response = await _profileApi.completeGuideProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: '+$_countryCode${_phoneController.text.trim()}',
        dateOfBirth: _formatDate(_selectedDateOfBirth!),
        gender: _selectedGender!.toLowerCase(),
        country: _selectedCountry!.name,
        cityId: _selectedCityId!,
        experienceYears: int.tryParse(_experienceController.text.trim()),
        education: _educationController.text.trim(),
        ratePerHour: double.tryParse(_rateController.text.trim()),
        languageIds: _selectedLanguageIds.toList(),
        governmentId: _govIdFile!,
        profilePhoto: _profilePhotoFile!,
        license: _licenseFile,
      );

      if (!mounted) return;

      // 2. Check the status from the response
      // Assuming response contains the serialized GuideProfile which has 'verification_status'
      final status = response['verification_status'] as String?;

      if (status == 'verified') {
        // If auto-verified, go straight to Dashboard
        Navigator.pushNamedAndRemoveUntil(
            context,
            '/guideDashboard', // Replace with your actual dashboard route name
                (route) => false
        );
      } else {
        // Otherwise, go to Pending Screen
        Navigator.pushNamedAndRemoveUntil(
            context,
            '/approvalPending',
                (route) => false
        );
      }

    } catch (e) {
      _showError('Failed to submit profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ─────────────────────────────────────────────
  // Pickers (unchanged logic)
  // ─────────────────────────────────────────────
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select City'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _cities.length,
            itemBuilder: (context, index) {
              final city = _cities[index];
              return ListTile(
                title: Text(city['name']),
                subtitle: Text(city['country']),
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
      ),
    );
  }

  void _showLanguageMultiSelect() {
    if (_languages.isEmpty) {
      _showError('Languages are loading...');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Select Languages'),
            contentPadding: EdgeInsets.zero,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _languages.map((lang) {
                  final isSelected = _selectedLanguageIds.contains(lang['id']);
                  return CheckboxListTile(
                    title: Text(lang['name']),
                    subtitle: Text(lang['code']),
                    value: isSelected,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (bool? selected) {
                      setDialogState(() {
                        if (selected == true) {
                          _selectedLanguageIds.add(lang['id']);
                          _selectedLanguageNames.add(lang['name']);
                        } else {
                          _selectedLanguageIds.remove(lang['id']);
                          _selectedLanguageNames.remove(lang['name']);
                        }
                      });
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Done',
                    style: TextStyle(color: AppColors.primaryBlue)),
              ),
            ],
          );
        },
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
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _pickFile(String field) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        switch (field) {
          case 'govId':
            _govIdFile = file; // Store XFile directly
            _govIdFileName = file.name;
            break;
          case 'profilePhoto':
            _profilePhotoFile = file; // Store XFile directly
            _profilePhotoFileName = file.name;
            break;
          case 'license':
            _licenseFile = file; // Store XFile directly
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ─────────────────────────────────────────────
  // UI Widgets (unchanged)
  // ─────────────────────────────────────────────
  Widget _buildShadowedTextField({
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.textSmall.copyWith(color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.textSmall.copyWith(
            color: AppColors.primaryGray.withAlpha(150),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 16.0),
            child: Icon(icon, color: AppColors.primaryGray),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r),
            borderSide: BorderSide.none,
          ),
          contentPadding:
          EdgeInsets.only(top: 20.h, bottom: 20.h, right: 20.w),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        style: AppTextStyles.textSmall.copyWith(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Phone Number',
          hintStyle: AppTextStyles.textSmall.copyWith(
            color: AppColors.primaryGray.withAlpha(150),
          ),
          prefixIcon: InkWell(
            onTap: () {
              _showCountryPicker(showPhoneCode: true);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_outlined, color: AppColors.primaryGray),
                  SizedBox(width: 8.w),
                  Text(
                    "+$_countryCode",
                    style:
                    AppTextStyles.textSmall.copyWith(color: Colors.black),
                  ),
                  Icon(Icons.arrow_drop_down, color: AppColors.primaryGray),
                ],
              ),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r),
            borderSide: BorderSide.none,
          ),
          contentPadding:
          EdgeInsets.only(top: 20.h, bottom: 20.h, right: 20.w),
        ),
      ),
    );
  }

  Widget _buildShadowedPickerButton({
    required String hint,
    required IconData icon,
    String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
            top: 20.h, bottom: 20.h, left: 20.w, right: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGray.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGray),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                value ?? hint,
                style: AppTextStyles.textSmall.copyWith(
                  color: value != null
                      ? Colors.black
                      : AppColors.primaryGray.withAlpha(150),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppColors.primaryGray),
          ],
        ),
      ),
    );
  }

  Widget _buildShadowedDropdown({
    required String hint,
    required IconData icon,
    String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        style: AppTextStyles.textSmall.copyWith(color: Colors.black),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item,
                style: AppTextStyles.textSmall,
                overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.textSmall.copyWith(
            color: AppColors.primaryGray.withAlpha(150),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 16.0),
            child: Icon(icon, color: AppColors.primaryGray),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r),
            borderSide: BorderSide.none,
          ),
          contentPadding:
          EdgeInsets.only(top: 20.h, bottom: 20.h, right: 0.w),
        ),
        icon: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Icon(Icons.arrow_drop_down, color: AppColors.primaryGray),
        ),
      ),
    );
  }

  Widget _buildUploadButton({
    required String label,
    required IconData icon,
    String? fileName,
    required VoidCallback onPressed,
  }) {
    bool isUploaded = fileName != null;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.thirdBlue : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: isUploaded ? Border.all(color: AppColors.primaryBlue) : null,
          boxShadow: [
            if (!isUploaded)
              BoxShadow(
                color: AppColors.primaryGray.withAlpha(20),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isUploaded ? Icons.check_circle_outline : icon,
                color: isUploaded
                    ? AppColors.primaryBlue
                    : AppColors.primaryGray),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                isUploaded ? fileName : label,
                style: AppTextStyles.textSmall.copyWith(
                    color: isUploaded
                        ? AppColors.primaryBlue
                        : AppColors.primaryGray,
                    fontWeight:
                    isUploaded ? FontWeight.bold : FontWeight.normal),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}