import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _allFaqs = [
    {
      "question": "How do I book a guide?",
      "answer": "You can book a guide by navigating to the Home screen, selecting 'Guide', browsing the available guides, and clicking 'Book' on their profile."
    },
    {
      "question": "Can I cancel my booking?",
      "answer": "Yes, you can cancel your booking up to 24 hours before the scheduled time for a full refund. Go to 'My Bookings' to manage your reservations."
    },
    {
      "question": "Is my payment information safe?",
      "answer": "Absolutely. We use industry-standard encryption and trusted payment gateways like Stripe and PayPal to ensure your data is secure."
    },
    {
      "question": "How do I become a host?",
      "answer": "Go to your profile settings and select 'Become a Host'. You'll need to complete a verification process and list your property details."
    },
    {
      "question": "What if I have an emergency during a trip?",
      "answer": "In case of an emergency, use the SOS button on the home screen or contact local authorities immediately. You can also reach our 24/7 support team."
    },
  ];

  List<Map<String, String>> _filteredFaqs = [];

  @override
  void initState() {
    super.initState();
    _filteredFaqs = _allFaqs;
    _searchController.addListener(_filterFaqs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFaqs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFaqs = _allFaqs.where((faq) {
        return faq['question']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'FAQs'),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchController,
                style: AppTextStyles.textSmall.copyWith(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search for help...',
                  hintStyle: TextStyle(color: AppColors.primaryGray),
                  prefixIcon: Icon(Icons.search, color: AppColors.primaryGray, size: 20.w),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),

          // --- FAQ List ---
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: _filteredFaqs.length,
              itemBuilder: (context, index) {
                final faq = _filteredFaqs[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.secondaryGray.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          faq['question']!,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        iconColor: AppColors.primaryBlue,
                        collapsedIconColor: AppColors.primaryGray,
                        childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                        children: [
                          Text(
                            faq['answer']!,
                            style: AppTextStyles.textSmall.copyWith(
                              color: const Color(0xFF4B5563), // Darker gray for readability
                              height: 1.5,
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
        ],
      ),
    );
  }
}