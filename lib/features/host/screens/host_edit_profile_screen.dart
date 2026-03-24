// lib/features/host/screens/host_edit_profile_screen.dart
// ✅ COMPLETE & FIXED — Gender dropdown safe, date picker, photo upload, all fields wired

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:yaloo/features/host/providers/host_provider.dart';

class HostEditProfileScreen extends StatefulWidget {
  const HostEditProfileScreen({super.key});

  @override
  State<HostEditProfileScreen> createState() => _HostEditProfileScreenState();
}

class _HostEditProfileScreenState extends State<HostEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  final _countryCtrl   = TextEditingController();
  final _bioCtrl       = TextEditingController();

  // ── Gender: always null or exactly one of the three lowercase strings ──
  String? _gender;

  // Valid gender values that EXACTLY match the DropdownMenuItems below
  static const List<String> _validGenders = ['male', 'female', 'other'];

  DateTime? _dateOfBirth;
  bool _isSaving       = false;
  bool _isUploadingPic = false;

  final ImagePicker _picker = ImagePicker();

  // ── Map whatever the server returns to a safe dropdown value ─────────
  String? _normaliseGender(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final lower = raw.trim().toLowerCase();
    if (_validGenders.contains(lower)) return lower;
    return null; // unknown value → null so dropdown shows hint
  }

  DateTime? _parseDob(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    // Try ISO format first (YYYY-MM-DD), then common display formats
    final formats = [
      DateFormat('yyyy-MM-dd'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('MM/dd/yyyy'),
      DateFormat('yyyy-MM-ddTHH:mm:ss'),
    ];
    for (final fmt in formats) {
      try {
        return fmt.parseStrict(raw.split('T').first.trim());
      } catch (_) {}
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _populateFields());
  }

  void _populateFields() {
    final profile = context.read<HostProvider>().profile;
    if (profile == null) return;

    _firstNameCtrl.text = profile.firstName;
    _lastNameCtrl.text  = profile.lastName;
    _phoneCtrl.text     = profile.phoneNumber;
    _countryCtrl.text   = profile.country;
    _bioCtrl.text       = profile.profileBio;

    setState(() {
      _gender      = _normaliseGender(profile.gender);
      _dateOfBirth = _parseDob(profile.dateOfBirth);
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _countryCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  // ── Date Picker ──────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _dateOfBirth ?? DateTime(now.year - 25, 1, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      helpText: 'Select date of birth',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2563EB),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  // ── Save ─────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Phone validation
    final phone = _phoneCtrl.text.trim();
    if (phone.isNotEmpty && !phone.startsWith('+')) {
      _showSnack('Phone number must include country code (e.g. +94)', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final payload = <String, dynamic>{
      'first_name': _firstNameCtrl.text.trim(),
      'last_name':  _lastNameCtrl.text.trim(),
      'country':    _countryCtrl.text.trim(),
      'profile_bio': _bioCtrl.text.trim(),
    };

    if (phone.isNotEmpty) payload['phone_number'] = phone;
    if (_gender != null)  payload['gender'] = _gender;
    if (_dateOfBirth != null) {
      payload['date_of_birth'] = DateFormat('yyyy-MM-dd').format(_dateOfBirth!);
    }

    final success = await context.read<HostProvider>().updateProfile(payload);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      _showSnack('Profile updated successfully');
      Navigator.pop(context);
    } else {
      final err = context.read<HostProvider>().error ?? 'Update failed';
      _showSnack(err, isError: true);
    }
  }

  // ── Profile Picture ──────────────────────────────────────────────────
  Future<void> _pickAndUploadPhoto() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null || !mounted) return;

    setState(() => _isUploadingPic = true);
    final ok = await context.read<HostProvider>().updateProfilePicture(file);
    if (!mounted) return;
    setState(() => _isUploadingPic = false);

    _showSnack(ok ? 'Profile picture updated!' : 'Upload failed', isError: !ok);
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── BUILD ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.black87),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
              )
                  : const Text(
                'Save',
                style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          children: [
            // ── Avatar ────────────────────────────────────────────────
            _buildAvatarSection(),
            const SizedBox(height: 32),

            // ── Personal Info ─────────────────────────────────────────
            _sectionLabel('Personal Information'),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(child: _buildField(
                  controller: _firstNameCtrl,
                  label: 'First Name',
                  icon: Icons.person_outline,
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildField(
                  controller: _lastNameCtrl,
                  label: 'Last Name',
                  icon: Icons.person_outline,
                )),
              ],
            ),
            const SizedBox(height: 14),

            _buildField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              hint: '+94 77 000 0000',
              icon: Icons.phone_outlined,
              keyboard: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[+\d\s\-()]'))],
              validator: (v) {
                final val = (v ?? '').trim();
                if (val.isNotEmpty && !val.startsWith('+')) {
                  return 'Must include country code (e.g. +94)';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            _buildField(
              controller: _countryCtrl,
              label: 'Country',
              icon: Icons.public_outlined,
            ),
            const SizedBox(height: 14),

            // ── Date of Birth ─────────────────────────────────────────
            _buildDateField(),
            const SizedBox(height: 14),

            // ── Gender dropdown ───────────────────────────────────────
            _buildGenderDropdown(),
            const SizedBox(height: 28),

            // ── Bio ───────────────────────────────────────────────────
            _sectionLabel('About Me'),
            const SizedBox(height: 14),

            _buildField(
              controller: _bioCtrl,
              label: 'Bio',
              hint: 'Tell guests about yourself as a host…',
              icon: Icons.notes_outlined,
              maxLines: 5,
              maxLength: 500,
            ),
            const SizedBox(height: 32),

            // ── Save button ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF2563EB).withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Avatar ─────────────────────────────────────────────────────────────
  Widget _buildAvatarSection() {
    return Center(
      child: Consumer<HostProvider>(
        builder: (_, provider, __) {
          final profile = provider.profile;
          final pic  = profile?.profilePic ?? '';
          final name = profile?.fullName ?? '';

          return Stack(
            children: [
              GestureDetector(
                onTap: _pickAndUploadPhoto,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                    boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                    backgroundImage: pic.isNotEmpty ? NetworkImage(pic) : null,
                    child: _isUploadingPic
                        ? const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB))
                        : pic.isEmpty
                        ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'H',
                      style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                    )
                        : null,
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: _pickAndUploadPhoto,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Date Field ─────────────────────────────────────────────────────────
  Widget _buildDateField() {
    final dobText = _dateOfBirth != null
        ? DateFormat('dd MMMM yyyy').format(_dateOfBirth!)
        : '';

    return GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          controller: TextEditingController(text: dobText),
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            hintText: 'Tap to select',
            prefixIcon: Icon(Icons.cake_outlined, size: 20, color: Colors.grey.shade400),
            suffixIcon: Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
    );
  }

  // ── Gender Dropdown ────────────────────────────────────────────────────
  Widget _buildGenderDropdown() {
    // Safety: ensure _gender is null or exactly one of the valid values
    final safeGender = _validGenders.contains(_gender) ? _gender : null;

    return DropdownButtonFormField<String>(
      value: safeGender,
      isExpanded: true,
      hint: Text('Select gender', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: Icon(Icons.wc_outlined, size: 20, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: const [
        DropdownMenuItem(value: 'male',   child: Text('Male')),
        DropdownMenuItem(value: 'female', child: Text('Female')),
        DropdownMenuItem(value: 'other',  child: Text('Other')),
      ],
      onChanged: (v) => setState(() => _gender = v),
    );
  }

  // ── Generic Text Field ─────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        counterText: maxLength != null ? null : '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
  );
}