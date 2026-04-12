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
    extends State<HostProfileCompletionScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;

  // ── ALL ORIGINAL STATE & LOGIC PRESERVED ──
  late final ProfileCompletionApi _profileApi;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _countryCode = '94';
  String? _selectedGender;

  XFile? _profilePhotoFile;
  String? _profilePhotoFileName;

  XFile? _govIdFile;
  String? _govIdFileName;

  XFile? _otherDocFile;
  String? _otherDocFileName;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    final apiClient = ApiClient();
    final secureStorage = SecureStorage();

    _profileApi = ProfileCompletionApi(
      apiClient: apiClient,
      secureStorage: secureStorage,
    );

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
    _animController.dispose();
    super.dispose();
  }

  // ── ALL ORIGINAL LOGIC PRESERVED ──────────────────────────────────────────

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

  Future<void> _handleSubmit() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);

    try {
      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.first;
      final lastName =
      nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final phoneNumber = '+$_countryCode${_phoneController.text.trim()}';

      final gender = _selectedGender! == 'Prefer not to say'
          ? 'other'
          : _selectedGender!.toLowerCase();

      await _profileApi.completeHostProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        gender: gender,
        profilePhoto: _profilePhotoFile!,
        governmentId: _govIdFile!,
        otherDoc: _otherDocFile,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/hostStayDetails');
    } catch (e) {
      _showError('Failed to submit profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFile(String field) async {
    final ImagePicker picker = ImagePicker();

    // ADD COMPRESSION HERE: Limit quality and max dimensions
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compresses image to 70% quality (drastically reduces file size)
      maxWidth: 1920,   // Prevents massive 4K+ resolutions
      maxHeight: 1920,
    );

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
          // Gradient header — warm purple/violet for Host role
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
                    Color(0xFF4A148C),
                    Color(0xFF7B1FA2),
                    Color(0xFFAB47BC),
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
                  padding:
                  const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                              color:
                              Colors.black.withOpacity(0.15),
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
                            'Host Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            'Verify your identity to start hosting',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                              Colors.white.withOpacity(0.80),
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
                          borderRadius:
                          BorderRadius.circular(20),
                          border: Border.all(
                              color:
                              Colors.white.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.home_outlined,
                                color: Colors.white, size: 13),
                            SizedBox(width: 5),
                            Text(
                              'Host',
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
                              accentColor:
                              const Color(0xFF7B1FA2),
                              children: [
                                _formField(
                                  controller: _nameController,
                                  hint: 'Full Name',
                                  icon: Icons.person_outline,
                                  accentColor:
                                  const Color(0xFF7B1FA2),
                                ),
                                const SizedBox(height: 12),
                                _phoneField(),
                                const SizedBox(height: 12),
                                _dropdownField(
                                  hint: 'Gender',
                                  icon: Icons.wc_outlined,
                                  value: _selectedGender,
                                  items: [
                                    'Male',
                                    'Female',
                                    'Other',
                                    'Prefer not to say',
                                  ],
                                  accentColor:
                                  const Color(0xFF7B1FA2),
                                  onChanged: (val) => setState(
                                          () => _selectedGender = val),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── Verification Documents ──────
                            _sectionCard(
                              title: 'Verification Documents',
                              icon: Icons.verified_outlined,
                              accentColor:
                              const Color(0xFF7B1FA2),
                              subtitle:
                              'Profile photo and Government ID are required.',
                              children: [
                                _uploadButton(
                                  label: 'Profile Photo',
                                  icon: Icons.camera_alt_outlined,
                                  fileName: _profilePhotoFileName,
                                  isRequired: true,
                                  accentColor:
                                  const Color(0xFF7B1FA2),
                                  onPressed: () =>
                                      _pickFile('profilePhoto'),
                                ),
                                const SizedBox(height: 10),
                                _uploadButton(
                                  label:
                                  'Government ID / Passport',
                                  icon: Icons.badge_outlined,
                                  fileName: _govIdFileName,
                                  isRequired: true,
                                  accentColor:
                                  const Color(0xFF7B1FA2),
                                  onPressed: () =>
                                      _pickFile('govId'),
                                ),
                                const SizedBox(height: 10),
                                _uploadButton(
                                  label:
                                  'Other Document (Optional)',
                                  icon:
                                  Icons.description_outlined,
                                  fileName: _otherDocFileName,
                                  isRequired: false,
                                  accentColor:
                                  const Color(0xFF7B1FA2),
                                  onPressed: () =>
                                      _pickFile('otherDoc'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // ── Submit ──────────────────────
                            _submitButton(),
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

  // ── UI helpers ─────────────────────────────────────────────────────────────

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
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
                  color: accentColor.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
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
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: accentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: accentColor,
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
    Color accentColor = const Color(0xFF7B1FA2),
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
          prefixIcon:
          Icon(icon, color: accentColor, size: 18),
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
          hintStyle: TextStyle(
              color: Colors.grey[400], fontSize: 14),
          prefixIcon: InkWell(
            onTap: _showCountryPicker,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone_outlined,
                      color: Color(0xFF7B1FA2), size: 18),
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

  Widget _dropdownField({
    required String hint,
    required IconData icon,
    String? value,
    required List<String> items,
    Color accentColor = const Color(0xFF7B1FA2),
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: value != null
            ? accentColor.withOpacity(0.05)
            : const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null
              ? accentColor.withOpacity(0.3)
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
          hintStyle: TextStyle(
              color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon,
              color: value != null ? accentColor : Colors.grey[400],
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
    Color accentColor = const Color(0xFF7B1FA2),
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
              ? accentColor.withOpacity(0.07)
              : const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUploaded
                ? accentColor
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
                    ? accentColor.withOpacity(0.12)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle_rounded : icon,
                color: isUploaded ? accentColor : Colors.grey[500],
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
                          ? accentColor
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
              isUploaded ? Icons.edit_outlined : Icons.upload_rounded,
              color: isUploaded ? accentColor : Colors.grey[400],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B1FA2),
          disabledBackgroundColor:
          const Color(0xFF7B1FA2).withOpacity(0.45),
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
          children: const [
            Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}