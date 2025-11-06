import 'package:flutter/material.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import 'package:country_picker/country_picker.dart';
import 'package:language_picker/language_picker.dart';
import 'package:language_picker/languages.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({Key? key}) : super(key: key);

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // --- Page 1 Data ---
  Country? _selectedCountry;
  Language? _selectedLanguage;

  // --- Page 2 Data ---
  final Set<String> _selectedInterests = {};

  // --- THIS WAS THE MISSING LIST ---
  final List<Map<String, dynamic>> _allInterests = [
    {'name': 'Beach', 'icon': Icons.beach_access},
    {'name': 'Mountains', 'icon': Icons.terrain},
    {'name': 'Culture', 'icon': Icons.museum},
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Adventure', 'icon': Icons.explore},
    {'name': 'Festivals', 'icon': Icons.celebration},
    {'name': 'Nature', 'icon': Icons.eco},
  ];
  // ---------------------------------

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
              // Header Logo
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

              // PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Disable swiping
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

          // Passport/NIC Field
          _buildShadowedTextField(
            hint: 'Passport/ NIC No',
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 16),

          // Age Field
          _buildShadowedTextField(
            hint: 'Age',
            icon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // UPDATED: Country Picker
          _buildShadowedPickerButton(
            hint: 'Country',
            icon: Icons.public_outlined,
            // Display the selected country's name, or the hint
            value: _selectedCountry?.name,
            onTap: _showCountryPicker,
          ),
          const SizedBox(height: 16),

          // UPDATED: Language Picker
          _buildShadowedPickerButton(
            hint: 'Language',
            icon: Icons.translate_outlined,
            // Display the selected language's name, or the hint
            value: _selectedLanguage?.name,
            onTap: _showLanguagePicker,
          ),
        ],
      ),
    );
  }

  // --- NEW: Helper method to show Country Picker ---
  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      // Optional: Show phone code
      showPhoneCode: false,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
      // Optional: Stylize the picker
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        // Style the search field
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

  // --- NEW: Helper method to show Language Picker ---
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

// Helper for rendering each language item
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


  // --- Page 2: Interests ---
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

          // Grid of interests
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4, // Adjust this ratio to get desired height
            ),
            itemCount: _allInterests.length, // Now this will work
            itemBuilder: (context, index) {
              final interest = _allInterests[index]; // Now this will work
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

  // --- Reusable Widgets ---

  Widget _buildShadowedTextField({
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(18),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
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

  // --- NEW: Reusable widget for picker buttons ---
  Widget _buildShadowedPickerButton({
    required String hint,
    required IconData icon,
    String? value, // The text to display (e.g., "Sri Lanka")
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
              color: AppColors.primaryGray.withAlpha(18),
              blurRadius: 20,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGray),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value ?? hint, // Show selected value or hint
                style: AppTextStyles.bodySmall.copyWith(
                  // Use dark text if a value is selected, gray if it's just the hint
                  color: value != null
                      ? Colors.black
                      : AppColors.primaryGray.withAlpha(150),
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppColors.primaryGray),
          ],
        ),
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
            if (!isSelected) // Only show shadow if not selected
              BoxShadow(
                color: AppColors.primaryGray.withAlpha(18),
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

  // --- Bottom Navigation ---
  Widget _buildBottomNavigation() {
    bool isLastPage = _currentPage == 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Skip Button
        TextButton(
          onPressed: () {
            // TODO: Handle Skip (e.g., navigate to Home)
            // Navigator.pushReplacementNamed(context, '/home');
          },
          child: Text(
            'Skip',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryGray),
          ),
        ),

        // Continue / Complete Button
        Row(
          children: [
            Text(
              isLastPage ? 'Complete' : 'Continue',
              style: AppTextStyles.headlineLarge.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 15),
            ElevatedButton(
              onPressed: () {
                if (isLastPage) {
                  // TODO: Handle Complete (Save data and navigate to Home)
                  // Navigator.pushReplacementNamed(context, '/home');
                } else {
                  // Go to the next page
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: const StadiumBorder(), // This makes it a "pill"
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 28,),
            ),
          ],
        ),
      ],
    );
  }
}