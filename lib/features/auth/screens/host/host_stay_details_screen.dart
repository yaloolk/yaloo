// lib/features/auth/screens/host/host_stay_details_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/services/api_service.dart';

class HostStayDetailsScreen extends StatefulWidget {
  const HostStayDetailsScreen({super.key});

  @override
  State<HostStayDetailsScreen> createState() =>
      _HostStayDetailsScreenState();
}

class _HostStayDetailsScreenState extends State<HostStayDetailsScreen>
    with SingleTickerProviderStateMixin {
  final DjangoApiService _apiService = DjangoApiService();
  bool _isLoading = false;

  // ── ALL ORIGINAL STATE PRESERVED ──────────────────────────────────────────

  final _stayNameController = TextEditingController();
  String? _selectedStayType;
  final List<String> _stayTypes = [
    'homestay',
    'farm_stay',
    'villa',
    'guesthouse',
    'eco_lodge',
    'hostel'
  ];

  final _houseNoController = TextEditingController();
  final _streetController = TextEditingController();
  final _townController = TextEditingController();
  final _postalCodeController = TextEditingController();
  String? _selectedCityId;
  String? _selectedCityName;
  List<Map<String, dynamic>> _cities = [];
  double? _latitude;
  double? _longitude;

  final _roomCountController = TextEditingController();
  final _maxGuestsController = TextEditingController();
  final _pricePerNightController = TextEditingController();
  final _bathroomCountController = TextEditingController();
  bool _sharedBathrooms = false;

  bool _entirePlaceAvailable = false;
  final _priceEntirePlaceController = TextEditingController();
  final _pricePerExtraGuestController = TextEditingController();
  bool _halfDayAvailable = false;
  final _pricePerHalfdayController = TextEditingController();
  bool _isSltdaRegistered = false;
  XFile? _sltdaFile;
  String? _sltdaFileName;
  final List<XFile> _propertyPhotos = [];

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Accent colour for this screen
  static const _accent = Color(0xFF00695C);

  @override
  void initState() {
    super.initState();
    _loadCities();

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
    _stayNameController.dispose();
    _houseNoController.dispose();
    _streetController.dispose();
    _townController.dispose();
    _postalCodeController.dispose();
    _roomCountController.dispose();
    _maxGuestsController.dispose();
    _pricePerNightController.dispose();
    _bathroomCountController.dispose();
    _priceEntirePlaceController.dispose();
    _pricePerExtraGuestController.dispose();
    _pricePerHalfdayController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── ALL ORIGINAL LOGIC PRESERVED ──────────────────────────────────────────

  Future<void> _loadCities() async {
    try {
      final cities = await _apiService.getList('accounts/cities/');
      setState(() => _cities = cities);
    } catch (e) {
      _showError('Failed to load cities: $e');
    }
  }

  Future<void> _pickPropertyPhotos() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _propertyPhotos.addAll(images));
    }
  }

  bool _validate() {
    if (!_isSltdaRegistered) {
      _showError('You must be SLTDA registered to submit a stay');
      return false;
    }
    if (_sltdaFile == null) {
      _showError('Please upload your SLTDA document');
      return false;
    }
    if (_stayNameController.text.trim().isEmpty ||
        _selectedStayType == null) {
      _showError('Please enter stay name and type');
      return false;
    }
    if (_propertyPhotos.isEmpty) {
      _showError('Please upload property photos');
      return false;
    }
    return true;
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> stayData = {
        'name': _stayNameController.text.trim(),
        'type': _selectedStayType,
        'house_no': _houseNoController.text.trim(),
        'street': _streetController.text.trim(),
        'town': _townController.text.trim(),
        'city_id': _selectedCityId,
        'postal_code': _postalCodeController.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'room_count': _roomCountController.text.trim(),
        'max_guests': _maxGuestsController.text.trim(),
        'price_per_night': _pricePerNightController.text.trim(),
        'bathroom_count': _bathroomCountController.text.trim(),
        'shared_bathrooms': _sharedBathrooms.toString(),
        'entire_place_is_available':
        _entirePlaceAvailable.toString(),
        'price_entire_place':
        _priceEntirePlaceController.text.trim(),
        'price_per_extra_guest':
        _pricePerExtraGuestController.text.trim(),
        'halfday_available': _halfDayAvailable.toString(),
        'price_per_halfday': _pricePerHalfdayController.text.trim(),
      };

      await _apiService.createStay(
          stayData, _propertyPhotos, _sltdaFile);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, '/approvalPending', (r) => false);
    } catch (e) {
      _showError('Submission failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              _sheetHeader(
                  'Select City', Icons.location_city_outlined),
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

  Future<void> _openMapPicker() async {
    LatLng initialPos = const LatLng(7.8731, 80.7718);
    try {
      final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high));
      initialPos = LatLng(pos.latitude, pos.longitude);
    } catch (_) {}
    if (!mounted) return;
    final LatLng? picked = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                _MapPickerScreen(initialPosition: initialPos)));
    if (picked != null) {
      setState(() {
        _latitude = picked.latitude;
        _longitude = picked.longitude;
      });
    }
  }

  Future<void> _pickSltdaDoc() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file =
    await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      _sltdaFile = file;
      _sltdaFileName = file.name;
    });
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
          // Teal/Green gradient header for stay listing
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
                    Color(0xFF004D40),
                    Color(0xFF00695C),
                    Color(0xFF26A69A),
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
                          borderRadius:
                          BorderRadius.circular(14),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'List Your Stay',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              'Tell us about the place you want to list',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.80),
                              ),
                              // 2. Add these to handle the text gracefully if it wraps
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                            Icon(Icons.home_work_outlined,
                                color: Colors.white, size: 13),
                            SizedBox(width: 5),
                            Text(
                              'Stay',
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

                // ── Scrollable body ──────────────────────────
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
                            // ── Stay Basics ─────────────────
                            _sectionCard(
                              title: 'Stay Details',
                              icon: Icons.home_outlined,
                              children: [
                                _formField(
                                  controller:
                                  _stayNameController,
                                  hint:
                                  'e.g. Lakeside Village Homestay',
                                  icon: Icons.home_outlined,
                                ),
                                const SizedBox(height: 12),
                                _dropdownField(
                                  hint: 'Stay Type',
                                  icon:
                                  Icons.category_outlined,
                                  value: _selectedStayType,
                                  items: _stayTypes,
                                  onChanged: (val) => setState(
                                          () =>
                                      _selectedStayType =
                                          val),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── Address ─────────────────────
                            _sectionCard(
                              title: 'Address & Location',
                              icon: Icons.location_on_outlined,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _formField(
                                        controller:
                                        _houseNoController,
                                        hint: 'House No.',
                                        icon: Icons
                                            .maps_home_work_outlined,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _formField(
                                        controller:
                                        _postalCodeController,
                                        hint: 'Postal Code',
                                        icon: Icons.mail_outlined,
                                        keyboardType:
                                        TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _formField(
                                  controller: _streetController,
                                  hint: 'Street',
                                  icon: Icons.route_outlined,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _formField(
                                        controller:
                                        _townController,
                                        hint: 'Town',
                                        icon: Icons
                                            .location_city_outlined,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _pickerButton(
                                        hint: 'City',
                                        icon: Icons
                                            .business_outlined,
                                        value: _selectedCityName,
                                        onTap: _showCityPicker,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _mapLocationButton(),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── Rooms & Pricing ─────────────
                            _sectionCard(
                              title: 'Rooms & Pricing',
                              icon: Icons.people_outlined,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _formField(
                                        controller:
                                        _roomCountController,
                                        hint: 'Rooms',
                                        icon: Icons.bed_outlined,
                                        keyboardType:
                                        TextInputType.number,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _formField(
                                        controller:
                                        _maxGuestsController,
                                        hint: 'Max Guests',
                                        icon: Icons
                                            .person_add_outlined,
                                        keyboardType:
                                        TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _formField(
                                  controller:
                                  _pricePerNightController,
                                  hint: 'Price per Night (\$)',
                                  icon: Icons.attach_money_outlined,
                                  keyboardType: const TextInputType
                                      .numberWithOptions(
                                      decimal: true),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── Entire Place ────────────────
                            _sectionCard(
                              title: 'Entire Place',
                              icon: Icons.apartment_outlined,
                              children: [
                                _toggleRow(
                                  label:
                                  'Entire place available',
                                  value: _entirePlaceAvailable,
                                  onChanged: (val) => setState(
                                          () =>
                                      _entirePlaceAvailable =
                                          val),
                                ),
                                if (_entirePlaceAvailable) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _formField(
                                          controller:
                                          _priceEntirePlaceController,
                                          hint:
                                          'Entire Place (\$)',
                                          icon: Icons
                                              .attach_money_outlined,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(
                                              decimal: true),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _formField(
                                          controller:
                                          _pricePerExtraGuestController,
                                          hint:
                                          'Extra Guest (\$)',
                                          icon: Icons
                                              .person_add_outlined,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(
                                              decimal: true),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── Bathrooms ───────────────────
                            _sectionCard(
                              title: 'Bathrooms',
                              icon: Icons.bathroom_outlined,
                              children: [
                                _formField(
                                  controller:
                                  _bathroomCountController,
                                  hint: 'Number of Bathrooms',
                                  icon: Icons.bathroom_outlined,
                                  keyboardType:
                                  TextInputType.number,
                                ),
                                const SizedBox(height: 12),
                                _toggleRow(
                                  label: 'Shared bathrooms',
                                  value: _sharedBathrooms,
                                  onChanged: (val) => setState(
                                          () =>
                                      _sharedBathrooms = val),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── Half-Day ────────────────────
                            _sectionCard(
                              title: 'Half-Day Availability',
                              icon: Icons.access_time_outlined,
                              children: [
                                _toggleRow(
                                  label: 'Half-day available',
                                  hint: '2:00 PM – 8:00 PM',
                                  value: _halfDayAvailable,
                                  onChanged: (val) => setState(
                                          () =>
                                      _halfDayAvailable = val),
                                ),
                                if (_halfDayAvailable) ...[
                                  const SizedBox(height: 12),
                                  _formField(
                                    controller:
                                    _pricePerHalfdayController,
                                    hint: 'Half-Day Price (\$)',
                                    icon: Icons
                                        .attach_money_outlined,
                                    keyboardType: const TextInputType
                                        .numberWithOptions(
                                        decimal: true),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── Verification ────────────────
                            _sectionCard(
                              title: 'Verification',
                              icon:
                              Icons.verified_user_outlined,
                              subtitle:
                              'SLTDA registration is required to list your stay.',
                              children: [
                                _toggleRow(
                                  label:
                                  'SLTDA Registered?',
                                  hint:
                                  'Sri Lanka Tourism Development Authority',
                                  value: _isSltdaRegistered,
                                  onChanged: (val) => setState(
                                          () =>
                                      _isSltdaRegistered =
                                          val),
                                ),
                                if (_isSltdaRegistered) ...[
                                  const SizedBox(height: 12),
                                  _uploadButton(
                                    label: 'SLTDA Document',
                                    icon: Icons
                                        .file_present_outlined,
                                    fileName: _sltdaFileName,
                                    isRequired: true,
                                    onPressed: _pickSltdaDoc,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),

                            // ── Property Photos ─────────────
                            _sectionCard(
                              title: 'Property Photos',
                              icon:
                              Icons.photo_library_outlined,
                              subtitle:
                              'Add at least one photo of your property.',
                              children: [
                                if (_propertyPhotos.isNotEmpty)
                                  _buildPhotoGallery(),
                                _uploadButton(
                                  label: 'Add Gallery Photos',
                                  icon:
                                  Icons.add_a_photo_outlined,
                                  fileName: _propertyPhotos
                                      .isEmpty
                                      ? null
                                      : '${_propertyPhotos.length} photo${_propertyPhotos.length == 1 ? '' : 's'} added',
                                  isRequired: true,
                                  onPressed:
                                  _pickPropertyPhotos,
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
                  color: _accent.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                Icon(icon, color: _accent, size: 18),
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
                color: _accent.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: _accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: _accent,
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
          prefixIcon:
          Icon(icon, color: _accent, size: 18),
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
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: value != null
            ? _accent.withOpacity(0.05)
            : const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null
              ? _accent.withOpacity(0.3)
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
              color: value != null ? _accent : Colors.grey[400],
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
              ? _accent.withOpacity(0.05)
              : const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null
                ? _accent.withOpacity(0.3)
                : const Color(0xFFE8EAED),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: value != null ? _accent : Colors.grey[400],
                size: 18),
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

  Widget _mapLocationButton() {
    final bool isPinned =
        _latitude != null && _longitude != null;
    return GestureDetector(
      onTap: _openMapPicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isPinned
              ? _accent.withOpacity(0.07)
              : const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPinned
                ? _accent
                : const Color(0xFFE8EAED),
            width: isPinned ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isPinned
                    ? _accent.withOpacity(0.12)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPinned
                    ? Icons.check_circle_rounded
                    : Icons.map_outlined,
                color: isPinned ? _accent : Colors.grey[500],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPinned
                        ? 'Location Pinned'
                        : 'Pin Location on Map',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isPinned
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isPinned
                          ? _accent
                          : Colors.grey[700],
                    ),
                  ),
                  if (isPinned)
                    Text(
                      '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500]),
                    )
                  else
                    Text(
                      'Tap to open map',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400]),
                    ),
                ],
              ),
            ),
            Icon(
              isPinned
                  ? Icons.edit_outlined
                  : Icons.arrow_forward_ios_rounded,
              color: isPinned ? _accent : Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow({
    required String label,
    String? hint,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: value
            ? _accent.withOpacity(0.05)
            : const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? _accent.withOpacity(0.3)
              : const Color(0xFFE8EAED),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: value
                        ? _accent
                        : Colors.grey[800],
                  ),
                ),
                if (hint != null)
                  Text(
                    hint,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _accent,
            activeTrackColor: _accent.withOpacity(0.25),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[200],
          ),
        ],
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
              ? _accent.withOpacity(0.07)
              : const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUploaded ? _accent : const Color(0xFFE8EAED),
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
                    ? _accent.withOpacity(0.12)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle_rounded : icon,
                color:
                isUploaded ? _accent : Colors.grey[500],
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
                          ? _accent
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
              color: isUploaded ? _accent : Colors.grey[400],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return Container(
      height: 90,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _propertyPhotos.length,
        itemBuilder: (ctx, i) => Stack(
          children: [
            Container(
              width: 90,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                image: DecorationImage(
                  image: FileImage(
                      File(_propertyPhotos[i].path)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 14,
              child: GestureDetector(
                onTap: () => setState(
                        () => _propertyPhotos.removeAt(i)),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      size: 13, color: Colors.white),
                ),
              ),
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
          backgroundColor: _accent,
          disabledBackgroundColor:
          _accent.withOpacity(0.45),
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
              'Submit Stay',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.check_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Sheet helpers ───────────────────────────────────────────────────────────

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
              color: _accent.withOpacity(0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _accent, size: 20),
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
                ? _accent.withOpacity(0.07)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? _accent : Colors.grey[200]!,
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
                      title,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? _accent
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
                    color: _accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SEPARATE SCREEN: Full-screen Google Maps pin picker.
// ALL ORIGINAL LOGIC PRESERVED — only UI polished.
// ═══════════════════════════════════════════════════════════
class _MapPickerScreen extends StatefulWidget {
  final LatLng initialPosition;
  const _MapPickerScreen({required this.initialPosition});

  @override
  State<_MapPickerScreen> createState() =>
      __MapPickerScreenState();
}

class __MapPickerScreenState extends State<_MapPickerScreen> {
  LatLng? _selectedPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
                target: widget.initialPosition, zoom: 14),
            onTap: (p) => setState(() => _selectedPoint = p),
            markers: _selectedPoint != null
                ? {
              Marker(
                  markerId: const MarkerId('m'),
                  position: _selectedPoint!)
            }
                : {},
          ),

          // Top instruction banner
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.touch_app_outlined,
                        color: const Color(0xFF00695C),
                        size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Tap on the map to pin your property location',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Confirm button
          Positioned(
            bottom: 28,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedPoint == null
                    ? null
                    : () => Navigator.pop(
                    context, _selectedPoint),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00695C),
                  disabledBackgroundColor:
                  const Color(0xFF00695C).withOpacity(0.40),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedPoint == null
                          ? Icons.location_off_outlined
                          : Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedPoint == null
                          ? 'Tap the map to select'
                          : 'Confirm Location',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}