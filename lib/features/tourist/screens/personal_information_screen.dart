import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/custom_primary_button.dart';
import 'package:country_picker/country_picker.dart';
import 'package:language_picker/languages.dart';
import 'package:language_picker/language_picker.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  // --- Controllers ---
  final _emailController = TextEditingController(text: "cora.hayes@example.com");
  final _phoneController = TextEditingController(text: "+1 234 567 890");
  final _passportController = TextEditingController(text: "A1B2C3D4E");

  // Emergency Contact
  final _ecNameController = TextEditingController();
  final _ecRelationshipController = TextEditingController();
  final _ecPhoneController = TextEditingController();

  // --- State Variables ---
  String _selectedCountry = "United States";
  DateTime? _dateOfBirth;
  String? _selectedGender = "Female";

  // --- UPDATED: Multi-select Languages ---
  // We store the selected Language objects
  List<Language> _selectedLanguages = [];

  @override
  void initState() {
    super.initState();
    _dateOfBirth = DateTime(1995, 10, 26);

    // Initialize with some default languages if needed
    _selectedLanguages = [
      Languages.english,
      Languages.spanish,
    ];
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passportController.dispose();
    _ecNameController.dispose();
    _ecRelationshipController.dispose();
    _ecPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Personal Information'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Personal Info Section ---
            _buildLabel("Email"),
            _buildTextField(controller: _emailController, icon: FontAwesomeIcons.envelope),
            SizedBox(height: 16.h),

            _buildLabel("Phone No."),
            _buildTextField(controller: _phoneController, icon: FontAwesomeIcons.phone),
            SizedBox(height: 16.h),

            _buildLabel("Country"),
            _buildPickerField(
              text: _selectedCountry,
              icon: FontAwesomeIcons.earthAmericas,
              onTap: _pickCountry,
            ),
            SizedBox(height: 16.h),

            _buildLabel("Date of Birth"),
            _buildPickerField(
              text: _dateOfBirth != null
                  ? "${_dateOfBirth!.month}/${_dateOfBirth!.day}/${_dateOfBirth!.year}"
                  : "Select Date",
              icon: FontAwesomeIcons.cakeCandles,
              onTap: _pickDate,
            ),
            SizedBox(height: 16.h),

            _buildLabel("Passport No."),
            _buildTextField(controller: _passportController, icon: FontAwesomeIcons.briefcase),
            SizedBox(height: 16.h),

            _buildLabel("Gender"),
            _buildDropdownField(
              value: _selectedGender,
              items: ["Male", "Female", "Other", "Prefer not to say"],
              icon: FontAwesomeIcons.venusMars,
              onChanged: (val) => setState(() => _selectedGender = val),
            ),
            SizedBox(height: 16.h),

            _buildLabel("Languages"),
            _buildPickerField(
              // UPDATED: Display comma-separated list of names
              text: _selectedLanguages.isEmpty
                  ? "Select Languages"
                  : _selectedLanguages.map((l) => l.name).join(", "),
              icon: FontAwesomeIcons.language,
              onTap: _showMultiSelectLanguageDialog, // <-- Calls new dialog
            ),

            SizedBox(height: 32.h),

            // --- Emergency Contact Section ---
            Text(
              "EMERGENCY CONTACT",
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGray,
                fontSize: 14.sp,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 16.h),

            _buildLabel("Contact Name"),
            _buildTextField(controller: _ecNameController, hint: "e.g., Jane Doe"),
            SizedBox(height: 16.h),

            _buildLabel("Relationship"),
            _buildTextField(controller: _ecRelationshipController, hint: "e.g., Partner"),
            SizedBox(height: 16.h),

            _buildLabel("Contact Phone No."),
            _buildTextField(controller: _ecPhoneController, hint: "e.g., +1 987 654 3210"),

            SizedBox(height: 40.h),

            // --- Save Button ---
            CustomPrimaryButton(
              text: "Save Changes",
              onPressed: _saveProfileChanges,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: AppTextStyles.textSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937), // Dark gray
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? hint,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.secondaryGray.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        style: AppTextStyles.textSmall.copyWith(color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.primaryGray.withOpacity(0.5)),
          prefixIcon: icon != null
              ? Icon(icon, color: AppColors.primaryGray, size: 18.w)
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildPickerField({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.secondaryGray.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGray, size: 18.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.textSmall.copyWith(color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: AppColors.primaryGray),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.secondaryGray.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGray, size: 18.w),
          SizedBox(width: 12.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryGray),
                isExpanded: true,
                style: AppTextStyles.textSmall.copyWith(color: Colors.black),
                onChanged: onChanged,
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Actions ---

  void _pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country.name;
        });
      },
    );
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primaryBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  // --- UPDATED: Multi-Select Language Logic ---
  void _showMultiSelectLanguageDialog() {
    // We create a temporary list to hold changes inside the dialog
    // Initialize it with the currently selected languages
    List<Language> tempSelected = List.from(_selectedLanguages);

    // Common languages to show at the top or filter
    // For this example, we will use the full list from the package `defaultLanguages`
    final List<Language> allLanguages = _selectedLanguages;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Languages"),
              content: SizedBox(
                width: double.maxFinite,
                height: 400.h, // Fixed height for the list
                child: Column(
                  children: [
                    // Optional: Search Bar could go here
                    Expanded(
                      child: ListView.builder(
                        itemCount: allLanguages.length,
                        itemBuilder: (context, index) {
                          final language = allLanguages[index];
                          final isSelected = tempSelected.contains(language);

                          return CheckboxListTile(
                            title: Text(language.name),
                            subtitle: Text(language.isoCode),
                            value: isSelected,
                            activeColor: AppColors.primaryBlue,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  tempSelected.add(language);
                                } else {
                                  tempSelected.remove(language);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    // Update the main state with the new selection
                    setState(() {
                      _selectedLanguages = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Save", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- Save Function ---
  void _saveProfileChanges() {
    // 1. Collect all data
    final updatedData = {
      'email': _emailController.text,
      'phone': _phoneController.text,
      'country': _selectedCountry,
      'dob': _dateOfBirth,
      'passport': _passportController.text,
      'gender': _selectedGender,
      'languages': _selectedLanguages.map((l) => l.name).toList(),
      'emergencyContact': {
        'name': _ecNameController.text,
        'relationship': _ecRelationshipController.text,
        'phone': _ecPhoneController.text,
      }
    };

    // 2. TODO: Send `updatedData` to your Backend / Firebase
    print("Saving Data: $updatedData");

    // 3. Navigate back
    Navigator.pop(context);

    // Optional: Show a success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile Updated Successfully!')),
    );
  }
}