import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'package:country_picker/country_picker.dart';
import 'package:language_picker/language_picker.dart';
import 'package:language_picker/languages.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_picker_button.dart';
import '../../../../core/widgets/circular_nav_button.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({Key? key}) : super(key: key);

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Country? _selectedCountry;
  Language? _selectedLanguage;

  final Set<String> _selectedInterests = {};
  final List<Map<String, dynamic>> _allInterests = [
    {'name': 'Beach', 'icon': Icons.beach_access},
    {'name': 'Mountains', 'icon': Icons.terrain},
    {'name': 'Culture', 'icon': Icons.museum},
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Adventure', 'icon': Icons.explore},
    {'name': 'Festivals', 'icon': Icons.celebration},
    {'name': 'Nature', 'icon': Icons.eco},
  ];

  @override
  void dispose() {
    _pageController.dispose();
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
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.public_rounded,
                      color: AppColors.primaryBlue,
                      size: 40,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildProfileDetailsPage(),
                    _buildInterestsPage(),
                  ],
                ),
              ),
              _buildBottomNavigation(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetailsPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete Yaloo Profile',
            style: AppTextStyles.headlineLarge
                .copyWith(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Let\'s personalize your journey',
            style: AppTextStyles.textSmall
                .copyWith(color: AppColors.primaryGray, fontSize: 16),
          ),
          const SizedBox(height: 40),

          CustomTextField(
            hint: 'Passport/ NIC No',
            icon: Icons.badge_outlined, hintText: 'Passport/ NIC No',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            hint: 'Age',
            icon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.number, hintText: 'Age',
          ),
          const SizedBox(height: 16),
          CustomPickerButton(
            hint: 'Country',
            icon: Icons.public_outlined,
            value: _selectedCountry?.name,
            onTap: _showCountryPicker,
          ),
          const SizedBox(height: 16),
          CustomPickerButton(
            hint: 'Language',
            icon: Icons.translate_outlined,
            value: _selectedLanguage?.name,
            onTap: _showLanguagePicker,
          ),
        ],
      ),
    );
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.primaryGray.withAlpha(100),
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildLanguageItem(Language language) {
    return Row(
      children: <Widget>[
        const SizedBox(width: 8.0),
        Text(language.name, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Text('(${language.isoCode})',
            style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildInterestsPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are you interested in?',
            style: AppTextStyles.headlineLarge
                .copyWith(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Select a few to personalize your recommendations.',
            style: AppTextStyles.textSmall
                .copyWith(color: AppColors.primaryGray, fontSize: 16),
          ),
          const SizedBox(height: 30),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemCount: _allInterests.length,
            itemBuilder: (context, index) {
              final interest = _allInterests[index];
              final isSelected = _selectedInterests.contains(interest['name']);
              return _buildInterestChip(
                text: interest['name']!,
                icon: interest['icon']!,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(interest['name']);
                    } else {
                      _selectedInterests.add(interest['name']!);
                    }
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInterestChip({
    required String text,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.thirdBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.secondaryGray,
            width: 1.5,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: AppColors.primaryGray.withAlpha(20),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primaryBlue : AppColors.primaryGray,
                size: 32),
            const SizedBox(height: 8),
            Text(
              text,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isSelected
                    ? AppColors.primaryBlue
                    : const Color(0xFF001A33),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    bool isLastPage = _currentPage == 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            // TODO: Handle Skip
          },
          child: Text(
            'Skip',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryGray),
          ),
        ),

        CircularNavButton(
          label: isLastPage ? 'Complete' : 'Continue',
          onPressed: () {
            if (isLastPage) {
              // TODO: Handle Complete
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
}