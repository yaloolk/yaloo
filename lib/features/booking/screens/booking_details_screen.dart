import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  bool _canSubmit = false;
  bool _isLoading = false;

  String _guideName = "Guide";
  String _guideImage = "assets/images/guide_1.jpg";
  String _bookingType = "guide";

  final _nameController = TextEditingController(text: 'jhon');
  final _passportController = TextEditingController(text: '0000');
  final _emailController = TextEditingController(text: 'example@gmail.com');
  final _phoneController = TextEditingController(text: '00000');

  Country? _selectedCountry;
  String _phoneCountryFlag = '🇺🇸';
  String _phoneCountryCode = '1';
  String? _selectedGender = "Female";
  bool _saveDetails = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _passportController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _guideName = args['name'] ?? 'Guide';
        _guideImage = args['image'] ?? 'assets/images/guide_1.jpg';
        _bookingType = args['bookingType'] ?? 'guide';
      }
    } catch (e) {
      print("Error getting arguments: $e");
    }
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

  void _validateForm() {
    final fieldsAreValid = _nameController.text.isNotEmpty &&
        _passportController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _selectedCountry != null &&
        _selectedGender != null;

    final canSubmit = fieldsAreValid && _saveDetails;

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
            icon: Icon(FontAwesomeIcons.circleQuestion, color: AppColors.primaryBlack, size: 24.w),
          ),
          SizedBox(width: 12.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepProgressIndicator(
                currentStep: 0,
                steps: [
                  {'Details': FontAwesomeIcons.user},
                  if (_bookingType == 'guide')
                    {'Tour Info': FontAwesomeIcons.mountain}
                  else
                    {'Stay Info': FontAwesomeIcons.house},
                  {'Payment': FontAwesomeIcons.creditCard},
                ],
              ),
              _buildProviderCard(),
              SizedBox(height: 24.h),
              Text(
                'Almost done! Kindly provide your information below.',
                style: AppTextStyles.textSmall.copyWith(
                  color: AppColors.primaryGray,
                  fontSize: 16.sp,
                  height: 1.5.h,
                ),
              ),
              SizedBox(height: 24.h),
              _buildFormLabel("Full name"),
              CustomTextField(
                controller: _nameController,
                hintText: 'Enter your full name',
                icon: FontAwesomeIcons.user,
                hint: 'Maria',
              ),
              SizedBox(height: 16.h),
              _buildFormLabel("Passport Number"),
              CustomTextField(
                controller: _passportController,
                hintText: 'Enter your passport number',
                icon: FontAwesomeIcons.passport,
                hint: 'N478**',
              ),
              SizedBox(height: 16.h),
              _buildFormLabel("Email"),
              CustomTextField(
                controller: _emailController,
                hintText: 'Enter your email',
                icon: FontAwesomeIcons.envelope,
                keyboardType: TextInputType.emailAddress,
                hint: 'youremail@domain.com',
              ),
              SizedBox(height: 16.h),
              _buildFormLabel("Phone number"),
              _buildPhoneField(),
              SizedBox(height: 16.h),
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
                  SizedBox(width: 16.w),
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
              SizedBox(height: 20.h),
              _buildSaveDetailsCheckbox(),
              SizedBox(height: 20.h),
              CustomPrimaryButton(
                text: 'Submit',
                isLoading: _isLoading,
                onPressed: _canSubmit // TODO: Handle Submit Logic
                    ? () {
                  if (_bookingType == 'guide') {
                    Navigator.pushNamed(context, '/tourInformation',
                        arguments: {'bookingType': 'guide'});
                  } else {
                    Navigator.pushNamed(context, '/stayDetails',
                        arguments: {'bookingType': 'host'});
                  }
                }
                    : null,
              ),
              SizedBox(height: 20.h),
              _buildFaqLink(),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
      floatingActionButton: const FloatingChatButton(),
    );
  }

  Widget _buildProviderCard() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.thirdBlue,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundImage: AssetImage(_guideImage),
              onBackgroundImageError: (e, s) =>
                  Icon(FontAwesomeIcons.user, color: AppColors.primaryGray),
            ),
            SizedBox(width: 12.w),
            Text(
              _guideName,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.check_circle, color: AppColors.primaryBlue, size: 20.w),
          ],
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 16.w),
      child: Text.rich(
        TextSpan(
          text: label,
          style: AppTextStyles.textSmall
              .copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.bold),
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
        borderRadius: BorderRadius.circular(24.r),
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
              padding: EdgeInsets.only(left: 20.w, right: 10.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_phoneCountryFlag, style: TextStyle(fontSize: 24.sp)),
                  SizedBox(width: 8.w),
                  Text("+$_phoneCountryCode",
                      style: AppTextStyles.textSmall.copyWith(color: Colors.black)),
                  Icon(Icons.arrow_drop_down, color: AppColors.primaryGray),
                ],
              ),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.only(top: 20.h, bottom: 20.h, right: 20.w),
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
            _validateForm();
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
        icon: Icon(FontAwesomeIcons.circleQuestion, color: AppColors.primaryGray, size: 16.w),
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
        _validateForm();
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
                  setState(() {
                    _selectedGender = 'Male';
                  });
                  _validateForm();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Female'),
                onTap: () {
                  setState(() {
                    _selectedGender = 'Female';
                  });
                  _validateForm();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Other'),
                onTap: () {
                  setState(() {
                    _selectedGender = 'Other';
                  });
                  _validateForm();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Prefer not to say'),
                onTap: () {
                  setState(() {
                    _selectedGender = 'Prefer not to say';
                  });
                  _validateForm();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
