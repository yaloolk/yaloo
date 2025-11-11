import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/floating_chat_button.dart';
import 'package:yaloo/core/widgets/step_progress_indicator.dart';
import 'package:yaloo/core/widgets/custom_text_field.dart';
import 'package:yaloo/core/widgets/custom_primary_button.dart';

enum PaymentMethod { card, paypal }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _paymentMethod = PaymentMethod.card;
  bool _saveCard = false;
  String _totalPrice = "0.00"; // Default

  bool _canPay = false;

  // Form Controllers
  final _cardNumberController = TextEditingController();
  final _nameOnCardController = TextEditingController();
  final _expireDateController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_validateForm);
    _nameOnCardController.addListener(_validateForm);
    _expireDateController.addListener(_validateForm);
    _cvvController.addListener(_validateForm);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch the total from the previous screen
    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _totalPrice = args['total']?.toStringAsFixed(2) ?? '0.00';
      }
    } catch (e) {
      print("Error getting arguments: $e");
    }
    _validateForm();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nameOnCardController.dispose();
    _expireDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _validateForm() {
    bool fieldsAreValid = false;
    if (_paymentMethod == PaymentMethod.card) {
      fieldsAreValid = _cardNumberController.text.isNotEmpty &&
          _nameOnCardController.text.isNotEmpty &&
          _expireDateController.text.isNotEmpty &&
          _cvvController.text.isNotEmpty;
    } else if (_paymentMethod == PaymentMethod.paypal) {
      fieldsAreValid = true; // Just need to select PayPal
    }

    if (_canPay != fieldsAreValid) {
      setState(() {
        _canPay = fieldsAreValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Payment',
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
              // --- 1. Step Progress (Now on Step 3) ---
              StepProgressIndicator(
                currentStep: 2, // We are on the third step
                steps: const [
                  {'Details': FontAwesomeIcons.user},
                  {'Tour Info': FontAwesomeIcons.map},
                  {'Payment': FontAwesomeIcons.creditCard},
                ],
              ),

              // --- 2. Total Price ---
              Center(
                child: Text(
                  '\$ $_totalPrice',
                  style: AppTextStyles.headlineLargeBlack.copyWith(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // --- 3. Payment Options ---
              _buildPaymentOption(
                  title: 'Credit/Debit Card',

                  method: PaymentMethod.card,
                  icons: [
                    Image.asset(
                      'assets/images/visa_logo.png',
                      width: 40.w,
                      height: 24.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 8.w),
                    Image.asset(
                      'assets/images/mastercard_logo.png',
                      width: 40.w,
                      height: 24.h,
                      fit: BoxFit.contain,
                    ),
                  ]
              ),
              if (_paymentMethod == PaymentMethod.card)
                _buildCreditCardForm(),

              SizedBox(height: 16.h),
              Divider(color: AppColors.secondaryGray),
              SizedBox(height: 16.h),

              _buildPaymentOption(
                  title: 'PayPal',
                  method: PaymentMethod.paypal,
                  icons: [
                    Image.asset(
                      'assets/images/paypal_logo.png',
                      width: 80.w,
                      height: 24.h,
                      fit: BoxFit.contain,
                    ),
                  ]
              ),
              if (_paymentMethod == PaymentMethod.paypal)
                _buildPayPalInfo(),

              SizedBox(height: 32.h),

              // --- 4. Pay Button ---
              CustomPrimaryButton(
                text: 'PAY',
                onPressed: _canPay ? () {
                  // TODO: Handle Payment Logic
                  // e.g., call Stripe/PayPal SDK
                  Navigator.pushNamed(context, '/bookingRequestSent');
                } : null,
              ),
              SizedBox(height: 20.h),
              _buildFaqLink(),
              SizedBox(height: 100.h), // Padding for chat button
            ],
          ),
        ),
      ),
      floatingActionButton: const FloatingChatButton(),
    );
  }

  // --- Helper Widgets for this page ---

  Widget _buildPaymentOption({
    required String title,
    required PaymentMethod method,
    required List<Widget> icons
  }) {
    return RadioListTile<PaymentMethod>(
      title: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ...icons,
        ],
      ),
      value: method,
      groupValue: _paymentMethod,
      onChanged: (PaymentMethod? value) {
        if (value != null) {
          setState(() {
            _paymentMethod = value;
          });
          _validateForm(); // Re-validate when payment method changes
        }
      },
      activeColor: AppColors.primaryBlue,
    );
  }

  Widget _buildCreditCardForm() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pay securely with your Bank Account using Visa or Mastercard',
            style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
          ),
          SizedBox(height: 16.h),
          _buildFormLabel("Card Number"),
          CustomTextField(
            controller: _cardNumberController,
            hintText: 'XXXX XXXX XXXX XXXX',
            icon: FontAwesomeIcons.creditCard,
            keyboardType: TextInputType.number,
            hint: '',
          ),
          SizedBox(height: 16.h),
          _buildFormLabel("Name on Card"),
          CustomTextField(
            controller: _nameOnCardController,
            hintText: 'Name on Card',
            icon: FontAwesomeIcons.user,
            hint: '',
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormLabel("Expire Date"),
                    CustomTextField(
                      controller: _expireDateController,
                      hintText: 'MM/YY',
                      icon: FontAwesomeIcons.calendar,
                      keyboardType: TextInputType.datetime,
                      hint: '',
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormLabel("CVV Code"),
                    CustomTextField(
                      controller: _cvvController,
                      hintText: 'XXX',
                      icon: FontAwesomeIcons.lock,
                      keyboardType: TextInputType.number,
                      hint: '',
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _buildSaveCardCheckbox(),
        ],
      ),
    );
  }

  Widget _buildPayPalInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You will be redirected to PayPal website to complete your order securely.',
            style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Color(0xFF0070E0),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.lock,
                  color: Colors.white,
                  size: 16.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'PayPal Secured Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 16.w),
      child: Text(
        label,
        style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSaveCardCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _saveCard,
          onChanged: (val) {
            setState(() {
              _saveCard = val ?? false;
            });
          },
          activeColor: AppColors.primaryBlue,
        ),
        Text(
          'Save card for future payments',
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
          'Get Payment Assistance',
          style: AppTextStyles.textSmall.copyWith(
            color: AppColors.primaryGray,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}