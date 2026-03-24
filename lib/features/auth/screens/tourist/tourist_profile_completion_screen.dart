// lib/features/auth/presentation/screens/tourist_profile_completion_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'package:country_picker/country_picker.dart';
import 'package:language_picker/languages.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_picker_button.dart';
import '../../../../core/widgets/circular_nav_button.dart';
import '../../../../core/services/api_service.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final DjangoApiService _apiService = DjangoApiService();

  // State Variables
  int _currentPage = 0;
  bool _isLoading = false;
  bool _isLoadingInterests = true;

  // Data for Interests
  List<Map<String, dynamic>> _apiInterests = [];
  List<String> _categories = [];
  String _activeCategory = '';
  final Set<String> _selectedInterestIds = {};

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passportController = TextEditingController();

  Country? _selectedCountry;
  Language? _selectedLanguage;
  DateTime? _selectedDateOfBirth;
  String? _selectedTravelStyle;
  String? _fullPhoneNumber;

  // Add variables
  List<Map<String, dynamic>> _apiLanguages = [];
  String? _selectedLanguageId;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final Map<String, String> _travelStyleOptions = {
    'solo': 'Solo Traveler',
    'couple': 'Couple',
    'family': 'Family',
    'group': 'Group',
    'business': 'Business',
    'backpacker': 'Backpacker',
  };

  final Map<String, IconData> _travelStyleIcons = {
    'solo': Icons.person_outline_rounded,
    'couple': Icons.favorite_outline_rounded,
    'family': Icons.family_restroom_rounded,
    'group': Icons.groups_outlined,
    'business': Icons.business_center_outlined,
    'backpacker': Icons.backpack_outlined,
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    _fetchInterests();
    _fetchLanguages();
  }

  Future<void> _fetchLanguages() async {
    try {
      final languages = await _apiService.getLanguages();
      setState(() {
        _apiLanguages = languages;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching languages: $e");
      }
    }
  }

  Future<void> _fetchInterests() async {
    try {
      final interests = await _apiService.getAllInterests();
      final categories = interests
          .map((e) => e['category'] as String)
          .toSet()
          .toList();
      categories.sort();

      if (mounted) {
        setState(() {
          _apiInterests = interests;
          _categories = categories;
          if (_categories.isNotEmpty) {
            _activeCategory = _categories.first;
          }
          _isLoadingInterests = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching interests: $e');
      }
      if (mounted) setState(() => _isLoadingInterests = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passportController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // --- UI Helpers for Icon Mapping ---
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant_rounded;
      case 'sports': return Icons.sports_soccer_rounded;
      case 'adventure': return Icons.terrain_rounded;
      case 'entertainment': return Icons.celebration_rounded;
      case 'nature': return Icons.nature_people_rounded;
      case 'culture': return Icons.museum_rounded;
      case 'learning': return Icons.school_rounded;
      case 'social': return Icons.groups_2_rounded;
      default: return Icons.star_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food': return const Color(0xFFFF6B6B);
      case 'sports': return const Color(0xFF4ECDC4);
      case 'adventure': return const Color(0xFFFFBE0B);
      case 'entertainment': return const Color(0xFFB537F2);
      case 'nature': return const Color(0xFF06D6A0);
      case 'culture': return const Color(0xFFFF8C42);
      case 'learning': return const Color(0xFF118AB2);
      case 'social': return const Color(0xFFEF476F);
      default: return AppColors.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Clean minimal background
      body: SafeArea(
        child: Column(
          children: [
            _buildModernHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                  _fadeController.reset();
                  _fadeController.forward();
                },
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                      child: _buildProfileDetailsPage(),
                    ),
                  ),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildInterestsPage(),
                  ),
                ],
              ),
            ),
            _buildModernBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Simple Logo
              Image.asset(
                'assets/images/yaloo_logo.png',
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.explore_rounded,
                  color: AppColors.primaryBlue,
                  size: 40,
                ),
              ),

              // Minimal Step Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Step ${_currentPage + 1} of 2",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Clean Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / 2,
              backgroundColor: Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // Clean Title Section
        Text(
          'Complete Your Profile',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tell us a bit about yourself',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 32),

        _buildMinimalSectionHeader("Personal Information"),
        const SizedBox(height: 12),

        // Name Fields
        _buildMinimalTextField(
          controller: _firstNameController,
          icon: Icons.person_outline,
          hint: 'First Name',
        ),
        const SizedBox(height: 12),
        _buildMinimalTextField(
          controller: _lastNameController,
          icon: Icons.person_outline,
          hint: 'Last Name',
        ),

        const SizedBox(height: 12),

        // Phone Field
        _buildMinimalPhoneField(),

        const SizedBox(height: 12),

        // Date Picker
        _buildMinimalPickerButton(
          hint: 'Date of Birth',
          icon: Icons.calendar_today_outlined,
          value: _selectedDateOfBirth == null
              ? null
              : "${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}",
          onTap: _showDatePicker,
        ),

        const SizedBox(height: 28),
        _buildMinimalSectionHeader("Travel Documents"),
        const SizedBox(height: 12),

        _buildMinimalTextField(
          controller: _passportController,
          icon: Icons.badge_outlined,
          hint: 'Passport / NIC Number',
        ),
        const SizedBox(height: 12),
        _buildMinimalPickerButton(
          hint: 'Country',
          icon: Icons.public_outlined,
          value: _selectedCountry?.name,
          onTap: _showCountryPicker,
        ),

        const SizedBox(height: 28),
        _buildMinimalSectionHeader("Preferences"),
        const SizedBox(height: 12),

        _buildMinimalPickerButton(
          hint: 'Preferred Language',
          icon: Icons.language_outlined,
          value: _selectedLanguageId != null
              ? _apiLanguages.firstWhere((lang) => lang['id'] == _selectedLanguageId)['name']
              : null,
          onTap: _showLanguagePicker,
        ),

        const SizedBox(height: 12),

        _buildMinimalPickerButton(
          hint: 'Travel Style',
          icon: Icons.luggage_outlined,
          value: _selectedTravelStyle != null
              ? _travelStyleOptions[_selectedTravelStyle]
              : null,
          onTap: _showTravelStylePicker,
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMinimalSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildMinimalTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildMinimalPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: IntlPhoneField(
        controller: _phoneController,
        disableLengthCheck: true,
        showCountryFlag: true,
        flagsButtonPadding: const EdgeInsets.only(left: 12),
        dropdownIconPosition: IconPosition.trailing,
        dropdownIcon: Icon(
          Icons.arrow_drop_down,
          color: Colors.grey[600],
          size: 24,
        ),
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
          fontWeight: FontWeight.w400,
        ),
        dropdownTextStyle: TextStyle(
          fontSize: 15,
          color: Colors.grey[700],
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'Phone Number',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primaryBlue, size: 20),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        initialCountryCode: 'LK',
        onChanged: (phone) {
          _fullPhoneNumber = phone.completeNumber;
        },
      ),
    );
  }

  Widget _buildMinimalPickerButton({
    required String hint,
    required IconData icon,
    String? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: value != null ? Colors.black87 : Colors.grey[400],
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsPage() {
    if (_isLoadingInterests) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryBlue, strokeWidth: 3),
            const SizedBox(height: 16),
            Text(
              "Loading interests...",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_apiInterests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.interests_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No interests available",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final currentInterests = _apiInterests
        .where((i) => i['category'] == _activeCategory)
        .toList();

    return Column(
      children: [
        // Header Section
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Your Interests',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose topics that interest you',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (_selectedInterestIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${_selectedInterestIds.length} selected',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Clean Category Tabs
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isActive = category == _activeCategory;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _activeCategory = category),
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isActive ? AppColors.primaryBlue : Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(category),
                            size: 18,
                            color: isActive ? Colors.white : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category[0].toUpperCase() + category.substring(1),
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Interest Chips
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: currentInterests.map((interest) {
                final id = interest['id'];
                final name = interest['name'];
                final isSelected = _selectedInterestIds.contains(id);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedInterestIds.remove(id);
                        } else {
                          _selectedInterestIds.add(id);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue.withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryBlue : Colors.grey[300]!,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: isSelected ? AppColors.primaryBlue : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppColors.primaryBlue,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildModernBottomBar() {
    bool isLastPage = _currentPage == 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back/Skip Button
          if (_currentPage == 0)
            TextButton(
              onPressed: _isLoading ? null : _handleSkip,
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _isLoading ? null : () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              icon: Icon(Icons.arrow_back, size: 18, color: Colors.grey[600]),
              label: Text(
                'Back',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
            ),

          const Spacer(),

          // Next/Finish Button
          ElevatedButton(
            onPressed: _isLoading ? null : () {
              if (isLastPage) {
                _handleComplete();
              } else {
                if (_validatePageOne()) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLastPage ? 'Finish' : 'Continue',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  isLastPage ? Icons.check : Icons.arrow_forward,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers & Logic ---

  bool _validatePageOne() {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      _showError("Please enter your name");
      return false;
    }
    return true;
  }

  Future<void> _handleSkip() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.skipProfileCompletion();
      if (mounted) Navigator.pushReplacementNamed(context, '/touristDashboard');
    } catch (e) {
      _showError('Failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleComplete() async {
    setState(() => _isLoading = true);
    try {
      // VALIDATION: Check if full phone number was captured
      if (_fullPhoneNumber == null || _fullPhoneNumber!.isEmpty) {
        throw Exception("Please enter a valid phone number");
      }

      final profileData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),

        // ❌ DON'T USE THIS: _phoneController.text (It misses the country code)
        // ✅ USE THIS:
        'phone_number': _fullPhoneNumber,

        'date_of_birth': _selectedDateOfBirth?.toIso8601String().split('T')[0],
        'country': _selectedCountry?.name,
        'passport_number': _passportController.text.trim(),
        if (_selectedTravelStyle != null) 'travel_style': _selectedTravelStyle,
        'interest_ids': _selectedInterestIds.toList(),
        'preferred_language': _selectedLanguageId,
      };

      await _apiService.completeTouristProfile(profileData);
      if (mounted) Navigator.pushReplacementNamed(context, '/touristDashboard');
    } catch (e) {
      _showError('Failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDateOfBirth = picked);
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country country) => setState(() => _selectedCountry = country),
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        inputDecoration: InputDecoration(
          labelText: 'Search Country',
          hintText: 'Start typing...',
          prefixIcon: const Icon(Icons.search_rounded),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primaryBlue),
          ),
        ),
      ),
    );
  }

  void _showTravelStylePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Travel Style",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),

              ...(_travelStyleOptions.entries.map((entry) {
                final isSelected = _selectedTravelStyle == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedTravelStyle = entry.key);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryBlue.withValues(alpha: 0.08)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : Colors.grey[200]!,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _travelStyleIcons[entry.key] ?? Icons.style_outlined,
                              color: isSelected ? AppColors.primaryBlue : Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? AppColors.primaryBlue : Colors.grey[700],
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList()),
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.language_rounded,
                            color: AppColors.primaryBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Select Language",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: _apiLanguages.length,
                      itemBuilder: (context, index) {
                        final lang = _apiLanguages[index];
                        final isSelected = _selectedLanguageId == lang['id'];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedLanguage = null;
                                  _selectedLanguageId = lang['id'];
                                });
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryBlue.withValues(alpha: 0.08)
                                      : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : Colors.grey[200]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        lang['name'],
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? AppColors.primaryBlue : Colors.grey[800],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.primaryBlue,
                                        size: 24,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}