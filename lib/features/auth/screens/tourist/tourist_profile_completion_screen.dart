// lib/features/auth/presentation/screens/tourist_profile_completion_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
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

  // Add variables
  List<Map<String, dynamic>> _apiLanguages = [];
  String? _selectedLanguageId; // We store the UUID now, not the name

  final Map<String, String> _travelStyleOptions = {
    'solo': 'Solo Traveler',
    'couple': 'Couple',
    'family': 'Family',
    'group': 'Group',
    'business': 'Business',
    'backpacker': 'Backpacker',
  };

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  // --- UI Helpers for Icon Mapping ---
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant_menu_rounded;
      case 'sports': return Icons.sports_tennis_rounded;
      case 'adventure': return Icons.landscape_rounded;
      case 'entertainment': return Icons.movie_filter_rounded;
      case 'nature': return Icons.eco_rounded;
      case 'culture': return Icons.museum_rounded;
      case 'learning': return Icons.school_rounded;
      case 'social': return Icons.people_rounded;
      default: return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Slightly off-white for depth
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                    child: _buildProfileDetailsPage(),
                  ),
                  _buildInterestsPage(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/images/yaloo_logo.png',
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.public_rounded,
                  color: AppColors.primaryBlue,
                  size: 40,
                ),
              ),
              // Step Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Step ${_currentPage + 1} of 2",
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentPage + 1) / 2,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          'Complete Profile',
          style: AppTextStyles.headlineLarge.copyWith(fontSize: 28),
        ),
        Text(
          'Tell us a bit about yourself.',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        const SizedBox(height: 30),

        _buildSectionLabel("Personal Info"),
        Row(
          children: [
            Expanded(child: CustomTextField(controller: _firstNameController, icon: Icons.person_outline, hintText: 'First Name', hint: '',)),
            const SizedBox(width: 12),
            Expanded(child: CustomTextField(controller: _lastNameController, icon: Icons.person_outline, hintText: 'Last Name', hint: '',)),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(controller: _phoneController, icon: Icons.phone_outlined, keyboardType: TextInputType.phone, hintText: 'Phone Number', hint: '',),
        const SizedBox(height: 16),
        CustomPickerButton(
          hint: 'Date of Birth',
          icon: Icons.calendar_today_outlined,
          value: _selectedDateOfBirth == null
              ? null
              : "${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}",
          onTap: _showDatePicker,
        ),

        const SizedBox(height: 24),
        _buildSectionLabel("Travel Documents"),
        CustomTextField(controller: _passportController, icon: Icons.badge_outlined, hintText: 'Passport/ NIC No', hint: '',),
        const SizedBox(height: 16),
        CustomPickerButton(hint: 'Country', icon: Icons.public_outlined, value: _selectedCountry?.name, onTap: _showCountryPicker),

        const SizedBox(height: 24),
        _buildSectionLabel("Preferences"),
        CustomPickerButton(hint: 'Language', icon: Icons.translate_outlined, value: _selectedLanguage?.name, onTap: _showLanguagePicker),
        const SizedBox(height: 16),
        CustomPickerButton(
          hint: 'Travel Style',
          icon: Icons.style_outlined,
          // Show the display name from the map, or null if nothing selected
          value: _selectedTravelStyle != null
              ? _travelStyleOptions[_selectedTravelStyle]
              : null,
          onTap: _showTravelStylePicker,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInterestsPage() {
    if (_isLoadingInterests) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_apiInterests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text("No interests available", style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    final currentInterests = _apiInterests
        .where((i) => i['category'] == _activeCategory)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Interests', style: AppTextStyles.headlineLarge.copyWith(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                'Pick topics to personalize your feed.',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),

        // Stylish Category Tabs
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isActive = category == _activeCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _activeCategory = category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isActive ? AppColors.primaryBlue : Colors.grey[300]!,
                        width: 1.5,
                      ),
                      boxShadow: isActive ? [
                        BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
                      ] : [],
                    ),
                    child: Row(
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
                            color: isActive ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        // Beautiful Interest Chips
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: currentInterests.map((interest) {
                final id = interest['id'];
                final name = interest['name'];
                final isSelected = _selectedInterestIds.contains(id);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedInterestIds.remove(id);
                      } else {
                        _selectedInterestIds.add(id);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryBlue : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: isSelected ? AppColors.primaryBlue : Colors.grey[800],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.check_circle, size: 16, color: AppColors.primaryBlue),
                        ]
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    bool isLastPage = _currentPage == 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _isLoading ? null : () {
              if (_currentPage == 0) {
                _handleSkip();
              } else {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[400],
            ),
            child: Text(
              _currentPage == 0 ? 'Skip' : 'Back',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          CircularNavButton(
            label: isLastPage ? 'Finish' : 'Next',
            isLoading: _isLoading,
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
      final profileData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'date_of_birth': _selectedDateOfBirth?.toIso8601String().split('T')[0],
        'country': _selectedCountry?.name,
        'passport_number': _passportController.text.trim(),
        if (_selectedTravelStyle != null) 'travel_style': _selectedTravelStyle,
        'interest_ids': _selectedInterestIds.toList(),
        'preferred_language': _selectedLanguageId, // Send the UUID!
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
            colorScheme: ColorScheme.light(primary: AppColors.primaryBlue),
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
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
        ),
      ),
    );
  }

  void _showTravelStylePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Optional: Header for the sheet
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "Select Travel Style",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Divider(height: 1, color: Colors.grey[300]),

              // List of Options
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: _travelStyleOptions.entries.map((entry) {
                    final isSelected = _selectedTravelStyle == entry.key;
                    return ListTile(
                      leading: Icon(
                        Icons.circle,
                        size: 10,
                        color: isSelected ? AppColors.primaryBlue : Colors.grey[300],
                      ),
                      title: Text(
                        entry.value,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primaryBlue : Colors.grey[800],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedTravelStyle = entry.key;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: _apiLanguages.length,
          itemBuilder: (context, index) {
            final lang = _apiLanguages[index];
            return ListTile(
              title: Text(lang['name']),
              onTap: () {
                setState(() {
                  _selectedLanguage = null; // Clear the old object if you used one
                  _selectedLanguageId = lang['id']; // Store UUID
                  // Optional: Store name for display
                  _firstNameController.text = _firstNameController.text; // Force rebuild if needed
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }
}