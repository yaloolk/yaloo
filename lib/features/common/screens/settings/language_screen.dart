import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/custom_primary_button.dart';
import 'package:language_picker/languages.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // --- State ---
  Language _selectedLanguage = Languages.english; // Default selection
  final TextEditingController _searchController = TextEditingController();

  // We initialize with the default list from the package
  List<Language> _allLanguages = Languages.defaultLanguages;
  List<Language> _filteredLanguages = [];

  @override
  void initState() {
    super.initState();

    _allLanguages = Languages.defaultLanguages; // FIXED
    _filteredLanguages = _allLanguages;

    _searchController.addListener(_filterLanguages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Search Logic ---
  void _filterLanguages() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLanguages = _allLanguages;
      } else {
        _filteredLanguages = _allLanguages.where((lang) {
          return lang.name.toLowerCase().contains(query) ||
              lang.isoCode.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // --- Save Logic ---
  void _saveLanguage() {
    // TODO: Save the selected language to your app's settings/database
    print("Saved Language: ${_selectedLanguage.name} (${_selectedLanguage.isoCode})");

    Navigator.pop(context); // Go back

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("App language changed to ${_selectedLanguage.name}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Language',
      ),
      body: Column(
        children: [
          // --- 1. Search Bar ---
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB), // Light gray
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchController,
                style: AppTextStyles.textSmall.copyWith(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search language',
                  hintStyle: TextStyle(color: AppColors.primaryGray),
                  prefixIcon: Icon(Icons.search, color: AppColors.primaryGray, size: 20.w),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),

          // --- 2. Language List ---
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: _filteredLanguages.length,
              itemBuilder: (context, index) {
                final language = _filteredLanguages[index];
                final isSelected = _selectedLanguage.isoCode == language.isoCode;

                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedLanguage = language;
                      });
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        // Highlight selected item with light blue background
                        color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: _buildLanguageItem(language, isSelected),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- 3. Save Button ---
          Padding(
            padding: EdgeInsets.all(24.w),
            child: CustomPrimaryButton(
              text: "Save",
              onPressed: _saveLanguage,
            ),
          ),
        ],
      ),
    );
  }

  // --- Your Custom Item Builder ---
  Widget _buildLanguageItem(Language language, bool isSelected) {
    return Row(
      children: <Widget>[
        SizedBox(width: 8.w),
        // Language Name
        Text(
          language.name,
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 16.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primaryBlue : const Color(0xFF374151),
          ),
        ),
        const Spacer(),
        // ISO Code (e.g., en, es)
        Text(
          '(${language.isoCode})',
          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
        ),
        // Checkmark for selected
        if (isSelected) ...[
          SizedBox(width: 12.w),
          Icon(FontAwesomeIcons.circleCheck, color: AppColors.primaryBlue, size: 20.w),
        ]
      ],
    );
  }
}