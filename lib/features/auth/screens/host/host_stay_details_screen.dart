// lib/features/auth/screens/host/host_stay_details_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/services/api_service.dart';

class HostStayDetailsScreen extends StatefulWidget {
  const HostStayDetailsScreen({super.key});

  @override
  State<HostStayDetailsScreen> createState() => _HostStayDetailsScreenState();
}

class _HostStayDetailsScreenState extends State<HostStayDetailsScreen> {
  final DjangoApiService _apiService = DjangoApiService();
  bool _isLoading = false;

  // ── Stay Basics ──
  final _stayNameController = TextEditingController();
  String? _selectedStayType;
  final List<String> _stayTypes = [
    'homestay', 'farm_stay', 'villa', 'guesthouse', 'eco_lodge', 'hostel'
  ];

  // ── Address & Location ──
  final _houseNoController = TextEditingController();
  final _streetController = TextEditingController();
  final _townController = TextEditingController();
  final _postalCodeController = TextEditingController();
  String? _selectedCityId;
  String? _selectedCityName;
  List<Map<String, dynamic>> _cities = [];
  double? _latitude;
  double? _longitude;

  // ── Capacity & Pricing ──
  final _roomCountController = TextEditingController();
  final _maxGuestsController = TextEditingController();
  final _pricePerNightController = TextEditingController();
  final _bathroomCountController = TextEditingController();
  bool _sharedBathrooms = false;

  // ── Toggles & Verification ──
  bool _entirePlaceAvailable = false;
  final _priceEntirePlaceController = TextEditingController();
  final _pricePerExtraGuestController = TextEditingController();
  bool _halfDayAvailable = false;
  final _pricePerHalfdayController = TextEditingController();
  bool _isSltdaRegistered = false;
  XFile? _sltdaFile;
  String? _sltdaFileName;
  List<XFile> _propertyPhotos = [];

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

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
                    padding: EdgeInsets.only(
                        top: 28.h, left: 24.w, right: 24.w, bottom: 4.h),
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
                              'Add Your Stay',
                              style: AppTextStyles.headlineLarge.copyWith(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Tell us about the place you want to list',
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

                          // ── Stay Name ──
                          _buildSectionLabel('Stay Name', Icons.home_outlined),
                          SizedBox(height: 14.h),
                          _buildShadowedTextField(
                            controller: _stayNameController,
                            hint: 'e.g. Lakeside Village Homestay',
                            icon: Icons.home_outlined,
                          ),
                          SizedBox(height: 28.h),
                          _buildSectionLabel('Stay Type', Icons.category_outlined),
                          _buildShadowedDropdown(
                                  hint: 'Stay Type',
                                  icon: Icons.category_outlined,
                                  value: _selectedStayType,
                                  items: _stayTypes,
                                  onChanged: (val) => setState(() => _selectedStayType = val),
                                ),
                                SizedBox(height: 28.h),
                          // ── Address ──
                          _buildSectionLabel('Address', Icons.location_on_outlined),
                          SizedBox(height: 14.h),

                          Row(
                            children: [
                              Expanded(
                                child: _buildShadowedTextField(
                                  controller: _houseNoController,
                                  hint: 'House No.',
                                  icon: Icons.maps_home_work_outlined,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildShadowedTextField(
                                  controller: _postalCodeController,
                                  hint: 'Postal Code',
                                  icon: Icons.mail_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          _buildShadowedTextField(
                            controller: _streetController,
                            hint: 'Street',
                            icon: Icons.route_outlined,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildShadowedTextField(
                                  controller: _townController,
                                  hint: 'Town',
                                  icon: Icons.location_city_outlined,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildShadowedPickerButton(
                                  hint: 'City',
                                  icon: Icons.business_outlined,
                                  value: _selectedCityName,
                                  onTap: _showCityPicker,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          // ── Map location picker ──
                          _buildMapLocationButton(),
                          SizedBox(height: 28.h),

                          // ── Capacity & Pricing ──
                          _buildSectionLabel(
                              'Rooms & Pricing', Icons.people_outlined),
                          SizedBox(height: 14.h),

                          Row(
                            children: [
                              Expanded(
                                child: _buildShadowedTextField(
                                  controller: _roomCountController,
                                  hint: 'Rooms',
                                  icon: Icons.bed_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildShadowedTextField(
                                  controller: _maxGuestsController,
                                  hint: 'Max Guests / Room',
                                  icon: Icons.person_add_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          _buildShadowedTextField(
                            controller: _pricePerNightController,
                            hint: 'Price per Night (\$)',
                            icon: Icons.attach_money_outlined,
                            keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                          ),
                          SizedBox(height: 28.h),

                          // ── Entire Place toggle ──
                          _buildSectionLabel(
                              'Entire Place', Icons.apartment_outlined),
                          SizedBox(height: 10.h),
                          _buildToggleRow(
                            label: 'Entire place is available',
                            value: _entirePlaceAvailable,
                            onChanged: (val) {
                              setState(() => _entirePlaceAvailable = val);
                            },
                          ),
                          // conditional fields
                          if (_entirePlaceAvailable) ...[
                      SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildShadowedTextField(
                          controller: _priceEntirePlaceController,
                          hint: 'Entire Place Price (\$)',
                          icon: Icons.attach_money_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildShadowedTextField(
                          controller: _pricePerExtraGuestController,
                          hint: 'Extra Guest Price (\$)',
                          icon: Icons.person_add_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 28.h),

                // ── Bathrooms ──
                _buildSectionLabel('Bathrooms', Icons.bathroom_outlined),
                SizedBox(height: 14.h),
                _buildShadowedTextField(
                  controller: _bathroomCountController,
                  hint: 'Number of Bathrooms',
                  icon: Icons.bathroom_outlined,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12.h),
                _buildToggleRow(
                  label: 'Shared bathrooms',
                  value: _sharedBathrooms,
                  onChanged: (val) {
                    setState(() => _sharedBathrooms = val);
                  },
                ),
                SizedBox(height: 28.h),

                // ── Half-Day ──
                _buildSectionLabel(
                    'Half-Day Availability', Icons.access_time_outlined),
                SizedBox(height: 10.h),
            _buildToggleRow(
              label: 'Half-day available',
              hint: '2:00 PM – 8:00 PM',
              value: _halfDayAvailable,
              onChanged: (val) {
                setState(() => _halfDayAvailable = val);
              },
            ),
            if (_halfDayAvailable) ...[
        SizedBox(height: 14.h),
    _buildShadowedTextField(
    controller: _pricePerHalfdayController,
    hint: 'Half-Day Price (\$)',
    icon: Icons.attach_money_outlined,
    keyboardType: const TextInputType.numberWithOptions(
    decimal: true),
    ),
    ],
    SizedBox(height: 28.h),

                                // Verification
                                _buildSectionLabel('Verification', Icons.verified_user_outlined),
                                SizedBox(height: 10.h),
                                _buildToggleRow(
                                  label: 'Are you SLTDA Registered?',
                                  hint: 'Sri Lanka Tourism Development Authority',
                                  value: _isSltdaRegistered,
                                  onChanged: (val) => setState(() => _isSltdaRegistered = val),
                                ),
                                if (_isSltdaRegistered) ...[
                                  SizedBox(height: 12.h),
                                  _buildUploadButton(
                                    label: 'SLTDA Document',
                                    icon: Icons.file_present_outlined,
                                    fileName: _sltdaFileName,
                                    onPressed: _pickSltdaDoc,
                                  ),
                                ],

                                SizedBox(height: 28.h),

                                // Gallery
                                _buildSectionLabel('Property Photos', Icons.photo_library_outlined),
                                SizedBox(height: 14.h),
                                _buildPhotoGallery(),
                                _buildUploadButton(
                                  label: 'Add Gallery Photos',
                                  icon: Icons.add_a_photo_outlined,
                                  onPressed: _pickPropertyPhotos,
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
    if (!_isSltdaRegistered) {
      _showError('You must be SLTDA registered to submit a stay');
      return false;
    }
    if (_sltdaFile == null) {
      _showError('Please upload your SLTDA document');
      return false;
    }
    if (_stayNameController.text.trim().isEmpty || _selectedStayType == null) {
      _showError('Please enter stay name and type');
      return false;
    }
    if (_propertyPhotos.isEmpty) {
      _showError('Please upload property photos');
      return false;
    }
    // ... Additional address/price validations
    return true;
  }

  // ─────────────────────────────────────────────
  // SUBMIT
  // ─────────────────────────────────────────────
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
        'entire_place_is_available': _entirePlaceAvailable.toString(),
        'price_entire_place': _priceEntirePlaceController.text.trim(),
        'price_per_extra_guest': _pricePerExtraGuestController.text.trim(),
        'halfday_available': _halfDayAvailable.toString(),
        'price_per_halfday': _pricePerHalfdayController.text.trim(),
      };

      // Call Multipart API
      await _apiService.createStay(stayData, _propertyPhotos, _sltdaFile);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/approvalPending', (r) => false);
    } catch (e) {
      _showError('Submission failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────
  // CITY PICKER
  // ─────────────────────────────────────────────
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

  // ─────────────────────────────────────────────
  // MAP LOCATION PICKER
  // ─────────────────────────────────────────────
  Future<void> _openMapPicker() async {
    LatLng initialPos = const LatLng(7.8731, 80.7718);
    try {
      final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      initialPos = LatLng(pos.latitude, pos.longitude);
    } catch (_) {}
    if (!mounted) return;
    final LatLng? picked = await Navigator.push(context, MaterialPageRoute(builder: (_) => _MapPickerScreen(initialPosition: initialPos)));
    if (picked != null) setState(() { _latitude = picked.latitude; _longitude = picked.longitude; });
  }

  // ─────────────────────────────────────────────
  // FILE PICKER
  // ─────────────────────────────────────────────
  Future<void> _pickSltdaDoc() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      _sltdaFile = file;
      _sltdaFileName = file.name;
    });
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
          child: Center(
              child: Icon(icon, color: AppColors.primaryBlue, size: 17.w)),
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
          'Submit Stay',
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

  Widget _buildShadowedPickerButton({
    required String hint,
    required IconData icon,
    String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        EdgeInsets.only(top: 20.h, bottom: 20.h, left: 20.w, right: 12.w),
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

  // Map location button — shows pinned coords or a "Pin Location" prompt
  Widget _buildMapLocationButton() {
    final bool isPinned = _latitude != null && _longitude != null;
    return GestureDetector(
      onTap: _openMapPicker,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: isPinned ? AppColors.thirdBlue : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: isPinned
              ? Border.all(color: AppColors.primaryBlue)
              : null,
          boxShadow: [
            if (!isPinned)
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
              isPinned ? Icons.check_circle_outline : Icons.map_outlined,
              color: isPinned ? AppColors.primaryBlue : AppColors.primaryGray,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                isPinned
                    ? 'Pinned: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}'
                    : 'Pin Location on Map',
                style: AppTextStyles.textSmall.copyWith(
                  color: isPinned
                      ? AppColors.primaryBlue
                      : AppColors.primaryGray,
                  fontWeight:
                  isPinned ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShadowedDropdown({required String hint, required IconData icon, String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: AppColors.primaryGray.withAlpha(20), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        style: AppTextStyles.textSmall.copyWith(color: Colors.black),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTextStyles.textSmall))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray.withAlpha(150)),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 16.0),
            child: Icon(icon, color: AppColors.primaryGray),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.r), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: 18.h),
        ),
        icon: const Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: Icon(Icons.arrow_drop_down, color: AppColors.primaryGray),
        ),
      ),
    );
  }



  // Simple toggle row with optional hint text
  Widget _buildToggleRow({required String label, String? hint, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: AppColors.primaryGray.withAlpha(20), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.textSmall.copyWith(color: Colors.black87, fontSize: 14.sp)),
                if (hint != null)
                  Text(hint, style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray, fontSize: 11.sp)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryBlue,
          ),
        ],
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
                isUploaded ? fileName! : label,
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

  Widget _buildPhotoGallery() {
    if (_propertyPhotos.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 100.h,
      margin: EdgeInsets.only(bottom: 14.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _propertyPhotos.length,
        itemBuilder: (ctx, i) => Stack(
          children: [
            Container(
              width: 100.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                image: DecorationImage(
                  image: FileImage(File(_propertyPhotos[i].path)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 5, right: 15,
              child: GestureDetector(
                onTap: () => setState(() => _propertyPhotos.removeAt(i)),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SEPARATE SCREEN: Full-screen Google Maps pin picker.
// User taps to place a marker, then hits "Confirm".
// Returns the selected LatLng back to the parent via Navigator.pop.
// ═══════════════════════════════════════════════════════════
class _MapPickerScreen extends StatefulWidget {
  final LatLng initialPosition;
  const _MapPickerScreen({required this.initialPosition});
  @override
  State<_MapPickerScreen> createState() => __MapPickerScreenState();
}

class __MapPickerScreenState extends State<_MapPickerScreen> {
  LatLng? _selectedPoint;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: widget.initialPosition, zoom: 14),
            onTap: (p) => setState(() => _selectedPoint = p),
            markers: _selectedPoint != null ? {Marker(markerId: const MarkerId('m'), position: _selectedPoint!)} : {},
          ),
          Positioned(bottom: 20, left: 20, right: 20, child: ElevatedButton(onPressed: _selectedPoint == null ? null : () => Navigator.pop(context, _selectedPoint), child: const Text("Confirm")))
        ],
      ),
    );
  }
}