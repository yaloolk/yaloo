import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

// --- NEW IMPORTS ---
import 'package:language_picker/language_picker.dart'; // We need this
import 'package:language_picker/languages.dart';
import 'package:image_picker/image_picker.dart';


class GuideProfileCompletionScreen extends StatefulWidget {
  const GuideProfileCompletionScreen({super.key});

  @override
  State<GuideProfileCompletionScreen> createState() =>
      _GuideProfileCompletionScreenState();
}

class _GuideProfileCompletionScreenState
    extends State<GuideProfileCompletionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // --- Page 1 Data ---
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  Country? _selectedCountry;
  String _countryCode = '94'; // Default to Sri Lanka
  DateTime? _selectedDateOfBirth;
  String? _selectedGender;

  // UPDATED: Changed from Set to a single Language object
  Language? _selectedLanguage;

  // --- Page 2 Data ---
  String? _govIdFileName;
  String? _profilePhotoFileName;
  String? _licenseFileName;
  XFile? _govIdFile;
  XFile? _profilePhotoFile;
  XFile? _licenseFile;


  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              Image.asset(
                'assets/images/yaloo_logo.png',
                width: 80.w,
                height: 80.h,
              ),
              SizedBox(height: 20.h),

              // PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Disable swiping
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
              SizedBox(height: 20.h),
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
            'Complete Your Profile',
            style: AppTextStyles.headlineLarge
                .copyWith(fontSize: 32.sp, fontWeight: FontWeight.bold),
          ),
           SizedBox(height: 10.h),
          Text(
            'Tell us more about yourself to get started.',
            style: AppTextStyles.textSmall
                .copyWith(color: AppColors.primaryGray, fontSize: 16.sp),
          ),
           SizedBox(height: 40.h),

          _buildShadowedTextField(
            controller: _nameController,
            hint: 'Full Name',
            icon: Icons.person_outline,
          ),
           SizedBox(height: 16.h),
          _buildPhoneField(), // Phone with Country Code
           SizedBox(height: 16.h),
          _buildShadowedPickerButton(
            hint: 'Country',
            icon: Icons.public_outlined,
            value: _selectedCountry?.name,
            onTap: _showCountryPicker,
          ),
           SizedBox(height: 16.h),
          _buildShadowedTextField(
            controller: _cityController,
            hint: 'City',
            icon: Icons.location_city_outlined,
          ),
           SizedBox(height: 16.h),
          _buildShadowedPickerButton(
            hint: 'Date of Birth',
            icon: Icons.calendar_today_outlined,
            value: _selectedDateOfBirth == null
                ? null
                : "${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}",
            onTap: _showDatePicker,
          ),
           SizedBox(height: 16.h),
          _buildShadowedDropdown(
              hint: 'Gender',
              icon: Icons.wc_outlined,
              value: _selectedGender,
              items: ['Male', 'Female', 'Other', 'Prefer not to say'],
              onChanged: (val) {
                setState(() { _selectedGender = val; });
              }
          ),
           SizedBox(height: 16.h),
          // UPDATED: This button now uses the single-select logic
          _buildShadowedPickerButton(
            hint: 'Languages Spoken',
            icon: Icons.translate_outlined,
            value: _selectedLanguage?.name, // Display the single language name
            onTap: _showLanguagePicker, // Use your provided function
          ),
           SizedBox(height: 20.h),
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
            'Verification',
            style: AppTextStyles.headlineLarge
                .copyWith(fontSize: 32.sp, fontWeight: FontWeight.bold),
          ),
           SizedBox(height: 10.h),
          Text(
            'Please upload the following documents to get verified.',
            style: AppTextStyles.textSmall
                .copyWith(color: AppColors.primaryGray, fontSize: 16.sp),
          ),
           SizedBox(height: 40.h),

          _buildUploadButton(
            label: 'Government ID / Passport',
            icon: Icons.badge_outlined,
            fileName: _govIdFileName,
            onPressed: () => _pickFile('govId'), // UPDATED
          ),
           SizedBox(height: 16.h),
          _buildUploadButton(
            label: 'Profile Photo (for verification)',
            icon: Icons.camera_alt_outlined,
            fileName: _profilePhotoFileName,
            onPressed: () => _pickFile('profilePhoto'), // UPDATED
          ),
           SizedBox(height: 16.h),
          _buildUploadButton(
            label: 'License/Certificate (Optional)',
            icon: Icons.school_outlined,
            fileName: _licenseFileName,
            onPressed: () => _pickFile('license'), // UPDATED
          ),
           SizedBox(height: 20.h),
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
        // Show "Back" on page 2, "Skip" on page 1
        TextButton(
          onPressed: () {
            if (isLastPage) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            } else {
              // This is the "Skip" button on Page 1
              // TODO: Handle Skip (e.g., navigate to Home)
              Navigator.pushReplacementNamed(context, '/guideDashboard');
            }
          },
          child: Text(
            isLastPage ? 'Back' : 'Skip',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryGray),
          ),
        ),

        // Continue / Complete Button
        Row(
          children: [
            Text(
              isLastPage ? 'Submit' : 'Continue',
              style: AppTextStyles.headlineLarge.copyWith(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(width: 15.w),
            ElevatedButton(
              onPressed: _isLoading ? null : () {
                if (isLastPage) {
                  // --- This is the FINAL SUBMIT ---
                  _handleSubmitProfile();
                } else {
                  // Go to the next page
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoading ? AppColors.primaryGray : AppColors.primaryBlue,
                shape: const StadiumBorder(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
               ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Icon(Icons.arrow_forward, color: Colors.white, size: 28.w),
            ),
          ],
        ),
      ],
    );
  }

  // --- Form Field Widgets (Unchanged) ---

  Widget _buildShadowedTextField({
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    TextInputType? keyboardType,
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        // UPDATED: Set the style for the *typed text*
        style: AppTextStyles.textSmall.copyWith(color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          // UPDATED: Set the style for the *hint text*
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
          contentPadding: EdgeInsets.only(top: 20.0, bottom: 20.0, right: 20.0),
        ),
      ),
    );
  }

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
        // UPDATED: Set the style for the *typed text*
        style: AppTextStyles.textSmall.copyWith(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Phone Number',
          // UPDATED: Set the style for the *hint text*
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
        const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20, right: 12),
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
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGray),
             SizedBox(width: 16.w),
            Expanded(
              child: Text(
                value ?? hint,
                // This widget already had the correct logic
                style: AppTextStyles.textSmall.copyWith(
                  color: value != null
                      ? Colors.black // Darker color for value
                      : AppColors.primaryGray.withAlpha(150), // Lighter color for hint
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
        // UPDATED: Set the style for the *selected item*
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
          // This was already correct
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

  Widget _buildUploadButton({
    required String label,
    required IconData icon,
    String? fileName, // UPDATED: Use fileName
    required VoidCallback onPressed,
  }) {
    bool isUploaded = fileName != null;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.thirdBlue : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isUploaded ? Border.all(color: AppColors.primaryBlue) : null,
          boxShadow: [
            if (!isUploaded)
              BoxShadow(
                color: AppColors.primaryGray.withAlpha(20),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                isUploaded ? Icons.check_circle_outline : icon,
                color: isUploaded ? AppColors.primaryBlue : AppColors.primaryGray
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                isUploaded ? fileName! : label, // Show file name
                // UPDATED: Apply the correct style
                style: AppTextStyles.textSmall.copyWith(
                    color: isUploaded ? AppColors.primaryBlue : AppColors.primaryGray,
                    fontWeight: isUploaded ? FontWeight.bold : FontWeight.normal
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
      // ... (rest of country picker theme from previous example)
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
              primary: AppColors.primaryBlue, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
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

  // UPDATED: This now uses the 'language_picker' dialog
  // This is the exact code you provided.
  void _showLanguagePicker() {
    showDialog(
      context: context,
      builder: (context) => LanguagePickerDialog(
        titlePadding: const EdgeInsets.all(16.0),
        searchCursorColor: AppColors.primaryBlue,
        searchInputDecoration: const InputDecoration(
          hintText: 'Search language...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        isSearchable: true,
        title: const Text('Select your language'),
        onValuePicked: (Language language) {
          setState(() {
            _selectedLanguage = language;
          });
        },
        itemBuilder: _buildLanguageItem,
      ),
    );
  }

  // ADDED: This helper is required by _showLanguagePicker
  Widget _buildLanguageItem(Language language) {
    return Row(
      children: <Widget>[
         SizedBox(width: 8.w),
        Text(language.name, style: TextStyle(fontSize: 16.sp)),
        const Spacer(),
        Text('(${language.isoCode})',
            style: const TextStyle(color: Colors.grey)),
      ],
    );
  }


  // NEW: File picking logic
  Future<void> _pickFile(String field) async {
    final ImagePicker picker = ImagePicker();
    // You can also use ImageSource.camera
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      // Update the state with the file object and its name
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
    } else {
      // User canceled the picker
    }
  }

  void _handleSubmitProfile() async {
    setState(() { _isLoading = true; });

    // --- TODO: BACKEND LOGIC ---
    // 1. Get current user's UID

    // 2. Upload files (ID, Profile, License) to Firebase Storage
    //    Use the state variables: _govIdFile, _profilePhotoFile, _licenseFile
    //    Get the download URLs for each.

    // 3. Create a map of all the data
    // final guideDetails = {
    //   'fullName': _nameController.text,
    //   'phone': "+$_countryCode${_phoneController.text}",
    //   'country': _selectedCountry?.name,
    //   'city': _cityController.text,
    //   'dob': _selectedDateOfBirth,
    //   'gender': _selectedGender,
    //   'languages': _selectedLanguage?.name, // It's now single-select
    //   'idUrl': "URL from _govIdFile upload",
    //   'profilePhotoUrl': "URL from _profilePhotoFile upload",
    //   'licenseUrl': "URL from _licenseFile upload (or null)",
    // };
    //
    // 4. Save to Firestore
    // await FirebaseFirestore.instance.collection('users').doc(uid).update({
    //   'details': guideDetails,
    //   'profileCompleted': true,
    // });
    // --- END BACKEND LOGIC ---

    // --- MOCKUP: Simulate save ---
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _isLoading = false; });

    // 5. Navigate to success screen
    Navigator.pushReplacementNamed(context, '/profileSubmitted');
  }
}