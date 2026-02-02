// lib/features/auth/presentation/screens/host_profile_completion_screen.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_picker/country_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/network/api_client.dart';
import 'package:yaloo/core/storage/secure_storage.dart';
import 'package:yaloo/features/auth/data/api/profile_completion_api.dart';

class HostProfileCompletionScreen extends StatefulWidget {
  const HostProfileCompletionScreen({super.key});

  @override
  State<HostProfileCompletionScreen> createState() =>
      _HostProfileCompletionScreenState();
}

class _HostProfileCompletionScreenState
    extends State<HostProfileCompletionScreen> {
  bool _isLoading = false;

  // ── API ──
  late final ProfileCompletionApi _profileApi;

  // ── Controllers ──
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // ── State ──
  String _countryCode = '94';
  String? _selectedGender;

  // ── Uploads ──
  XFile? _profilePhotoFile;
  String? _profilePhotoFileName;

  XFile? _govIdFile;
  String? _govIdFileName;

  XFile? _otherDocFile;
  String? _otherDocFileName;

  @override
  void initState() {
    super.initState();

    final apiClient = ApiClient();
    final secureStorage = SecureStorage();

    _profileApi = ProfileCompletionApi(
      apiClient: apiClient,
      secureStorage: secureStorage,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Fixed header ──
            Padding(
              padding:
              EdgeInsets.only(top: 28.h, left: 24.w, right: 24.w, bottom: 4.h),
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

            // ── Scrollable body ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),

                    // ── Personal Info ──
                    _buildSectionLabel(
                        'Personal Information', Icons.person_outline),
                    SizedBox(height: 14.h),

                    _buildShadowedTextField(
                      controller: _nameController,
                      hint: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 12.h),
                    _buildPhoneField(),
                    SizedBox(height: 12.h),
                    _buildShadowedDropdown(
                      hint: 'Gender',
                      icon: Icons.wc_outlined,
                      value: _selectedGender,
                      items: [
                        'Male',
                        'Female',
                        'Other',
                        'Prefer not to say',
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedGender = val;
                        });
                      },
                    ),
                    SizedBox(height: 28.h),

                    // ── Verification Documents ──
                    _buildSectionLabel(
                        'Verification Documents', Icons.verified_outlined),
                    SizedBox(height: 6.h),
                    Text(
                      'Profile photo and Government ID are required.',
                      style: AppTextStyles.textSmall.copyWith(
                        color: AppColors.primaryGray,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 14.h),

                    _buildUploadButton(
                      label: 'Profile Photo',
                      icon: Icons.camera_alt_outlined,
                      fileName: _profilePhotoFileName,
                      onPressed: () => _pickFile('profilePhoto'),
                    ),
                    SizedBox(height: 12.h),
                    _buildUploadButton(
                      label: 'Government ID / Passport',
                      icon: Icons.badge_outlined,
                      fileName: _govIdFileName,
                      onPressed: () => _pickFile('govId'),
                    ),
                    SizedBox(height: 12.h),
                    _buildUploadButton(
                      label: 'Other Document (Optional)',
                      icon: Icons.description_outlined,
                      fileName: _otherDocFileName,
                      onPressed: () => _pickFile('otherDoc'),
                    ),

                    // ── Submit ──
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
  // VALIDATION
  // ─────────────────────────────────────────────
  bool _validate() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showError('Please enter your phone number');
      return false;
    }
    if (_selectedGender == null) {
      _showError('Please select your gender');
      return false;
    }
    if (_profilePhotoFile == null) {
      _showError('Please upload your profile photo');
      return false;
    }
    if (_govIdFile == null) {
      _showError('Please upload your Government ID');
      return false;
    }
    return true;
  }

  // ─────────────────────────────────────────────
  // SUBMIT
  // ─────────────────────────────────────────────
  Future<void> _handleSubmit() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    try {
      // ── split full name into first / last ──
      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.first;
      final lastName =
      nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // ── build the full phone number with country code ──
      final phoneNumber = '+$_countryCode${_phoneController.text.trim()}';

      // ── lowercase gender so it matches the DB choices ──
      // "Prefer not to say" is not a DB choice; map it to "other"
      final gender = _selectedGender! == 'Prefer not to say'
          ? 'other'
          : _selectedGender!.toLowerCase();

      // ── POST to backend ──
      await _profileApi.completeHostProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        gender: gender,
        profilePhoto: _profilePhotoFile!,
        governmentId: _govIdFile!,
        otherDoc: _otherDocFile, // null → backend ignores it (optional)
      );

      if (!mounted) return;

      // Host always moves to Stay Details next.
      // Full verification only completes after the stay + SLTDA doc
      // are submitted and reviewed by admin.
      Navigator.pushReplacementNamed(context, '/hostStayDetails');
    } catch (e) {
      _showError('Failed to submit profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────
  // FILE PICKER
  // ─────────────────────────────────────────────
  Future<void> _pickFile(String field) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() {
      switch (field) {
        case 'profilePhoto':
          _profilePhotoFile = file;
          _profilePhotoFileName = file.name;
          break;
        case 'govId':
          _govIdFile = file;
          _govIdFileName = file.name;
          break;
        case 'otherDoc':
          _otherDocFile = file;
          _otherDocFileName = file.name;
          break;
      }
    });
  }

  // ─────────────────────────────────────────────
  // COUNTRY CODE PICKER (phone prefix only)
  // ─────────────────────────────────────────────
  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _countryCode = country.phoneCode;
        });
      },
    );
  }

  // ─────────────────────────────────────────────
  // ERROR
  // ─────────────────────────────────────────────
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ═══════════════════════════════════════════════
  // UI WIDGETS
  // ═══════════════════════════════════════════════

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
          child:
          Center(child: Icon(icon, color: AppColors.primaryBlue, size: 17.w)),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor:
          _isLoading ? AppColors.primaryGray : AppColors.primaryBlue,
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
          'Continue',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildShadowedTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
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
          hintStyle: AppTextStyles.textSmall
              .copyWith(color: AppColors.primaryGray.withAlpha(150)),
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
          hintStyle: AppTextStyles.textSmall
              .copyWith(color: AppColors.primaryGray.withAlpha(150)),
          prefixIcon: InkWell(
            onTap: _showCountryPicker,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_outlined, color: AppColors.primaryGray),
                  SizedBox(width: 8.w),
                  Text('+$_countryCode',
                      style: AppTextStyles.textSmall
                          .copyWith(color: Colors.black)),
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
        items: items
            .map((item) => DropdownMenuItem<String>(
          value: item,
          child: Text(item,
              style: AppTextStyles.textSmall,
              overflow: TextOverflow.ellipsis),
        ))
            .toList(),
        onChanged: onChanged,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.textSmall
              .copyWith(color: AppColors.primaryGray.withAlpha(150)),
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
    final bool isUploaded = fileName != null;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.thirdBlue : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border:
          isUploaded ? Border.all(color: AppColors.primaryBlue) : null,
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
          children: [
            Icon(
              isUploaded ? Icons.check_circle_outline : icon,
              color: isUploaded
                  ? AppColors.primaryBlue
                  : AppColors.primaryGray,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                isUploaded ? fileName : label,
                style: AppTextStyles.textSmall.copyWith(
                  color: isUploaded
                      ? AppColors.primaryBlue
                      : AppColors.primaryGray,
                  fontWeight:
                  isUploaded ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}