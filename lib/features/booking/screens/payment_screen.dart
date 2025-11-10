import 'package:flutter/material.dart';
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
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- 3. Payment Options ---
              _buildPaymentOption(
                  title: 'Credit/Debit Card',
                  method: PaymentMethod.card,
                  icons: [
                    FaIcon(FontAwesomeIcons.ccVisa, color: Color(0xFF1A1F71), size: 24),
                    SizedBox(width: 8),
                    FaIcon(FontAwesomeIcons.ccMastercard, color: Color(0xFFEB001B), size: 24),
                  ]
              ),
              if (_paymentMethod == PaymentMethod.card)
                _buildCreditCardForm(),

              const SizedBox(height: 16),
              Divider(color: AppColors.secondaryGray),
              const SizedBox(height: 16),

              _buildPaymentOption(
                  title: 'PayPal',
                  method: PaymentMethod.paypal,
                  icons: [
                    Image.network( // Using network image for PayPal logo
                      'https://www.paypalobjects.com/webstatic/mktg/Logo/pp-logo-100px.png',
                      height: 24,
                    ),
                  ]
              ),
              if (_paymentMethod == PaymentMethod.paypal)
                _buildPayPalInfo(),

              const SizedBox(height: 32),

              // --- 4. Pay Button ---
              CustomPrimaryButton(
                text: 'PAY',
                onPressed: _canPay ? () {
                  // TODO: Handle Payment Logic
                  // e.g., call Stripe/PayPal SDK
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
            style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.secondaryGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pay securely with your Bank Account using Visa or Mastercard',
            style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
          ),
          const SizedBox(height: 16),
          _buildFormLabel("Card Number"),
          CustomTextField(
            controller: _cardNumberController,
            hintText: 'XXXX XXXX XXXX XXXX',
            icon: FontAwesomeIcons.creditCard,
            keyboardType: TextInputType.number, hint: '',
          ),
          const SizedBox(height: 16),
          _buildFormLabel("Name on Card"),
          CustomTextField(
            controller: _nameOnCardController,
            hintText: 'Name on Card',
            icon: FontAwesomeIcons.user, hint: '',
          ),
          const SizedBox(height: 16),
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
                      keyboardType: TextInputType.datetime, hint: '',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormLabel("CVV Code"),
                    CustomTextField(
                      controller: _cvvController,
                      hintText: 'XXX',
                      icon: FontAwesomeIcons.lock,
                      keyboardType: TextInputType.number, hint: '',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSaveCardCheckbox(),
        ],
      ),
    );
  }

  Widget _buildPayPalInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.secondaryGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'You will be redirected to PayPal website to complete your order securely.',
        style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
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
        icon: Icon(FontAwesomeIcons.circleQuestion, color: AppColors.primaryGray, size: 16),
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