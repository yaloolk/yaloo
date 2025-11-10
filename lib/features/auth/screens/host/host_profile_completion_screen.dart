import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

// --- IMPORT YOUR CUSTOM WIDGETS ---
import 'package:yaloo/core/widgets/custom_text_field.dart';
import 'package:yaloo/core/widgets/custom_picker_button.dart';
import 'package:yaloo/core/widgets/custom_upload_button.dart';
import 'package:yaloo/core/widgets/circular_nav_button.dart';
// ---------------------------------

class HostProfileCompletionScreen extends StatefulWidget {
  const HostProfileCompletionScreen({super.key});

  @override
  State<HostProfileCompletionScreen> createState() =>
      _HostProfileCompletionScreenState();
}

class _HostProfileCompletionScreenState
    extends State<HostProfileCompletionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // --- Page 1 Data ---
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _bioController = TextEditingController();

  Country? _selectedCountry;
  String _countryCode = '94'; // Default to Sri Lanka
  String? _accommodationType;

  // For multi-select amenities
  final Set<String> _selectedAmenities = {};
  final List<String> _allAmenities = [
    'Wi-Fi', 'Kitchen', 'Air Conditioning', 'Hot Water', 'Parking', 'TV'
  ];

  // --- Page 2 Data ---
  String? _govIdFileName;
  String? _profilePhotoFileName;
  List<XFile> _propertyPhotoFiles = []; // To hold multiple photos

  XFile? _govIdFile;
  XFile? _profilePhotoFile;


  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Image.asset(
                'assets/images/yaloo_logo.png',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 20),

              // PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() { _currentPage = page; });
                  },
                  children: [
                    _buildProfileDetailsPage(),
                    _buildVerificationPage(),
                  ],
                ),
              ),

              // Bottom Navigation
              _buildBottomNavigation(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Page 1: Profile Details ---
  Widget _buildProfileDetailsPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete Your Host Profile',
            style: AppTextStyles.headlineLarge
                .copyWith(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Tell us about yourself and your place.',
            style: AppTextStyles.textSmall
                .copyWith(color: AppColors.primaryGray, fontSize: 16),
          ),
          const SizedBox(height: 40),

          CustomTextField(
            controller: _nameController,
            hint: 'Full Name',
            icon: Icons.person_outline, hintText: 'Full Name',
          ),
          const SizedBox(height: 16),
          _buildPhoneField(), // Phone with Country Code
          const SizedBox(height: 16),
          // CustomPickerButton(
          //   hint: 'Country',
          //   icon: Icons.public_outlined,
          //   value: _selectedCountry?.name,
          //   onTap: _showCountryPicker,
          // ),
          // const SizedBox(height: 16),
          CustomTextField(
            controller: _locationController,
            hint: 'Village / Town / City',
            icon: Icons.location_on_outlined, hintText: 'Village / Town / City',
          ),
          const SizedBox(height: 16),
          _buildShadowedDropdown(
              hint: 'Accommodation Type',
              icon: Icons.home_work_outlined,
              value: _accommodationType,
              items: ['Homestay', 'Private Room', 'Entire Place', 'Guesthouse'],
              onChanged: (val) {
                setState(() { _accommodationType = val; });
              }
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _priceController,
            hint: 'Price per Night (Dollar)',
            icon: Icons.attach_money_outlined,
            keyboardType: TextInputType.number, hintText: 'Price per Night (Dollar)',
          ),
          const SizedBox(height: 16),
          CustomPickerButton(
            hint: 'Select Facilities',
            icon: Icons.kitchen_outlined,
            value: _selectedAmenities.isEmpty
                ? null
                : _selectedAmenities.join(', '),
            onTap: _showAmenityMultiSelect,
          ),
          const SizedBox(height: 16),
          // CustomTextArea(
          //   controller: _bioController,
          //   hint: 'About Your Place (for tourists)',
          //   icon: Icons.edit_outlined, hintText: 'About Your Place (for tourists)',
          // ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Page 2: Verification ---
  Widget _buildVerificationPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification & Photos',
            style: AppTextStyles.headlineLarge
                .copyWith(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Upload documents for verification and photos of your property.',
            style: AppTextStyles.textSmall
                .copyWith(color: AppColors.primaryGray, fontSize: 16),
          ),
          const SizedBox(height: 40),

          CustomUploadButton(
            label: 'Government ID / Passport',
            icon: Icons.badge_outlined,
            fileName: _govIdFileName,
            onPressed: () => _pickFile('govId'),
          ),
          const SizedBox(height: 16),
          CustomUploadButton(
            label: 'Profile Photo (for verification)',
            icon: Icons.camera_alt_outlined,
            fileName: _profilePhotoFileName,
            onPressed: () => _pickFile('profilePhoto'),
          ),
          const SizedBox(height: 16),
          CustomUploadButton(
            // Show how many photos are selected
            label: 'Upload Property Photos',
            icon: Icons.photo_library_outlined,
            fileName: _propertyPhotoFiles.isEmpty
                ? null
                : "${_propertyPhotoFiles.length} photos selected",
            onPressed: _pickMultiplePropertyPhotos,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Bottom Navigation ---
  Widget _buildBottomNavigation() {
    bool isLastPage = _currentPage == 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            if (isLastPage) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            } else {
              // TODO: Handle Skip
              Navigator.pushReplacementNamed(context, '/hostDashboard');
            }
          },
          child: Text(
            isLastPage ? 'Back' : 'Skip',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryGray),
          ),
        ),

        // Use the CircularNavButton custom widget
        CircularNavButton(
          label: isLastPage ? 'Submit' : 'Continue',
          isLoading: _isLoading,
          onPressed: () {
            if (isLastPage) {
              _handleSubmitProfile();
            } else {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
      ],
    );
  }

  // --- Form Field Widgets ---

  // This widget is unique to this page
  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20),
            blurRadius: 20,
            offset: Offset(0, 5),
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
                  SizedBox(width: 8),
                  Text(
                    "+$_countryCode",
                    style: AppTextStyles.textSmall.copyWith(color: Colors.black),
                  ),
                  Icon(Icons.arrow_drop_down, color: AppColors.primaryGray),
                ],
              ),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.only(top: 20.0, bottom: 20.0, right: 20.0),
        ),
      ),
    );
  }

  // This is a standard dropdown, so we define it here
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        style: AppTextStyles.textSmall.copyWith(color: Colors.black),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: AppTextStyles.textSmall, overflow: TextOverflow.ellipsis,),
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
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.only(top: 20.0, bottom: 20.0, right: 0),
        ),
        icon: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Icon(Icons.arrow_drop_down, color: AppColors.primaryGray),
        ),
      ),
    );
  }

  // --- Action Handlers ---

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
      // ... (rest of country picker theme)
    );
  }

  void _showAmenityMultiSelect() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Select Amenities'),
              contentPadding: EdgeInsets.zero,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _allAmenities.map((amenity) {
                    final isSelected = _selectedAmenities.contains(amenity);
                    return CheckboxListTile(
                      title: Text(amenity),
                      value: isSelected,
                      activeColor: AppColors.primaryBlue,
                      onChanged: (bool? selected) {
                        setDialogState(() {
                          if (selected == true) {
                            _selectedAmenities.add(amenity);
                          } else {
                            _selectedAmenities.remove(amenity);
                          }
                        });
                        setState(() {}); // Update main page
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Done', style: TextStyle(color: AppColors.primaryBlue)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickFile(String field) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return; // User canceled

    setState(() {
      if (field == 'govId') {
        _govIdFile = file;
        _govIdFileName = file.name;
      } else if (field == 'profilePhoto') {
        _profilePhotoFile = file;
        _profilePhotoFileName = file.name;
      }
    });
  }

  Future<void> _pickMultiplePropertyPhotos() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> files = await picker.pickMultipleMedia();

    if (files.isNotEmpty) {
      setState(() {
        _propertyPhotoFiles.addAll(files);
      });
    }
  }

  void _handleSubmitProfile() async {
    setState(() { _isLoading = true; });

    // --- TODO: BACKEND LOGIC ---
    // 1. Get UID
    // 2. Upload _govIdFile, _profilePhotoFile
    // 3. Upload ALL files in _propertyPhotoFiles list (loop)
    // 4. Get all download URLs
    // 5. Create 'hostDetails' map
    // 6. Save to Firestore

    // --- MOCKUP: Simulate save ---
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _isLoading = false; });

    Navigator.pushReplacementNamed(context, '/profileSubmitted');
  }
}