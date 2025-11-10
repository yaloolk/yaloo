import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/floating_chat_button.dart';
import 'package:yaloo/core/widgets/step_progress_indicator.dart';
import 'package:yaloo/core/widgets/custom_text_field.dart';
import 'package:yaloo/core/widgets/custom_picker_button.dart';
import 'package:yaloo/core/widgets/custom_primary_button.dart';
import 'package:country_picker/country_picker.dart';

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({super.key});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  // --- Page State ---
  bool _canSubmit = false;
  bool _isLoading = false;

  // --- Mock Guide Data (will be filled by arguments) ---
  String _guideName = "Guide";
  String _guideImage = "assets/images/guide_1.jpg";

  // --- Form Controllers ---
  final _nameController = TextEditingController(text: 'jhon');
  final _passportController = TextEditingController(text: '0000');
  final _emailController = TextEditingController(text: 'example@gmail.com');
  final _phoneController = TextEditingController(text: '00000');

  // --- Form State Variables ---
  Country? _selectedCountry;
  String _phoneCountryFlag = '🇺🇸'; // Default to US flag
  String _phoneCountryCode = '1';   // Default to US code
  String? _selectedGender = "Female";
  bool _saveDetails = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to all controllers
    _nameController.addListener(_validateForm);
    _passportController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch the guide data passed from the previous screen
    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
      if (args != null) {
        _guideName = args['name'] ?? 'Guide';
        _guideImage = args['image'] ?? 'assets/images/guide_1.jpg';
      }
    } catch (e) {
      print("Error getting arguments: $e");
    }
    // Run initial validation
    _validateForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passportController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- Validation Logic ---
  void _validateForm() {
    final bool fieldsAreValid = _nameController.text.isNotEmpty &&
        _passportController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _selectedCountry != null &&
        _selectedGender != null;

    final bool canSubmit = fieldsAreValid && _saveDetails;

    if (_canSubmit != canSubmit) {
      setState(() {
        _canSubmit = canSubmit;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Booking Details',
        actions: [
          IconButton(
            onPressed: () { /* TODO: Show Help */ },
            icon: Icon(FontAwesomeIcons.circleQuestion, color: AppColors.primaryBlack, size: 24),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepProgressIndicator(
                currentStep: 0,
                steps: const [
                  {'Details': FontAwesomeIcons.user},
                  {'Tour Info': FontAwesomeIcons.map},
                  {'Payment': FontAwesomeIcons.creditCard},
                ],
              ),

              _buildProviderCard(),
              const SizedBox(height: 24),

              Text(
                'Almost done! Kindly provide your information below.',
                style: AppTextStyles.textSmall.copyWith(
                  color: AppColors.primaryGray,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildFormLabel("Full name"),
              CustomTextField(
                controller: _nameController,
                hintText: 'Enter your full name',
                icon: FontAwesomeIcons.user, hint: ' Maria',
              ),
              const SizedBox(height: 16),
              _buildFormLabel("Passport Number"),
              CustomTextField(
                controller: _passportController,
                hintText: 'Enter your passport number',
                icon: FontAwesomeIcons.passport, hint: 'N478**',
              ),
              const SizedBox(height: 16),
              _buildFormLabel("Email"),
              CustomTextField(
                controller: _emailController,
                hintText: 'Enter your email',
                icon: FontAwesomeIcons.envelope,
                keyboardType: TextInputType.emailAddress, hint: 'youremail@domain.com',
              ),
              const SizedBox(height: 16),
              _buildFormLabel("Phone number"),
              _buildPhoneField(),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormLabel("Country"),
                        CustomPickerButton(
                          hint: 'Select Country',
                          icon: FontAwesomeIcons.flag,
                          value: _selectedCountry?.name,
                          onTap: _showCountryPicker,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormLabel("Gender"),
                        CustomPickerButton(
                          hint: 'Select Gender',
                          icon: FontAwesomeIcons.venusMars,
                          value: _selectedGender,
                          onTap: _showGenderPicker,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSaveDetailsCheckbox(),
              const SizedBox(height: 20),
              CustomPrimaryButton(
                text: 'Submit',
                isLoading: _isLoading,
                // UPDATED: Button is enabled/disabled based on state
                onPressed: _canSubmit ? () {
                  // TODO: Handle Submit Logic
                  Navigator.pushNamed(context, '/tourInformation');
                } : null,
              ),
              const SizedBox(height: 20),
              _buildFaqLink(),
              const SizedBox(height: 100), // Padding for chat button
            ],
          ),
        ),
      ),
      floatingActionButton: const FloatingChatButton(),
    );
  }

  // --- Helper Widgets for this page ---

  Widget _buildProviderCard() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.thirdBlue,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              // UPDATED: Use dynamic image
              backgroundImage: AssetImage(_guideImage),
              onBackgroundImageError: (e, s) => Icon(FontAwesomeIcons.user, color: AppColors.primaryGray),
            ),
            const SizedBox(width: 12),
            Text(
              _guideName, // UPDATED: Use dynamic name
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.check_circle, color: AppColors.primaryBlue, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
      child: Text.rich(
        TextSpan(
          text: label,
          style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.bold),
          children: [
            TextSpan(text: ' *', style: TextStyle(color: AppColors.primaryRed)),
          ],
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
        style: AppTextStyles.textSmall.copyWith(color: Colors.black),
        decoration: InputDecoration(
          hintText: '123-456-7890',
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
                  // UPDATED: Show flag emoji
                  Text(
                    _phoneCountryFlag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "+$_phoneCountryCode",
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

  Widget _buildSaveDetailsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _saveDetails,
          onChanged: (val) {
            setState(() {
              _saveDetails = val ?? false;
            });
            _validateForm(); // Re-validate
          },
          activeColor: AppColors.primaryBlue,
        ),
        Text(
          'Save your details for future booking',
          style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
        ),
      ],
    );
  }

  Widget _buildFaqLink() {
    return Center(
      child: TextButton.icon(
        onPressed: () { /* TODO: Open FAQs */ },
        icon: Icon(FontAwesomeIcons.circleQuestion, color: AppColors.primaryGray, size: 16),
        label: Text(
          'FAQs & Help',
          style: AppTextStyles.textSmall.copyWith(
            color: AppColors.primaryGray,
            fontWeight: FontWeight.bold,
          ),
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
            _phoneCountryFlag = country.flagEmoji;
            _phoneCountryCode = country.phoneCode;
          } else {
            _selectedCountry = country;
          }
        });
        _validateForm(); // Re-validate
      },
    );
  }

  void _showGenderPicker() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              ListTile(
                title: Text('Male'),
                onTap: () {
                  setState(() { _selectedGender = 'Male'; });
                  _validateForm(); // Re-validate
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Female'),
                onTap: () {
                  setState(() { _selectedGender = 'Female'; });
                  _validateForm(); // Re-validate
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Other'),
                onTap: () {
                  setState(() { _selectedGender = 'Other'; });
                  _validateForm(); // Re-validate
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Prefer not to say'),
                onTap: () {
                  setState(() { _selectedGender = 'Prefer not to say'; });
                  _validateForm(); // Re-validate
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
    );
  }
}