import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_text_field.dart';
import 'package:yaloo/core/widgets/custom_picker_button.dart';

import '../../../core/widgets/icon_Button.dart';

// (Mock data lists remain the same...)
// --- MOCK DATA ---
final List<String> sliderImages = [
  "assets/images/sigiriya.jpg",
  "assets/images/galle.jpg",
  "assets/images/ella.jpg",
];
final List<Map<String, String>> topGuides = [
  {"name": "Hadhi", "location": "Kandy", "rating": "4.6", "image": "assets/images/guide_1.jpg"},
  {"name": "Hisham", "location": "Galle", "rating": "4.8", "image": "assets/images/guide_2.jpg"},
  {"name": "Aman", "location": "Ella", "rating": "4.7", "image": "assets/images/guide_3.jpg"},
];
// -----------------


class FindGuideScreen extends StatefulWidget {
  const FindGuideScreen({Key? key}) : super(key: key);

  @override
  State<FindGuideScreen> createState() => _FindGuideScreenState();
}

class _FindGuideScreenState extends State<FindGuideScreen> {
  final _sliderPageController = PageController();
  final _cityController = TextEditingController();
  final _hourController = TextEditingController();
  final _minuteController = TextEditingController();

  DateTime? _selectedDate;
  bool _isAm = true;

  @override
  void dispose() {
    _sliderPageController.dispose();
    _cityController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildImageSlider(),
              const SizedBox(height: 24),
              _buildFormSection(),
              const SizedBox(height: 24),
              _buildSectionHeader("Top Rated Guides"),
              const SizedBox(height: 16),
              _buildTopGuidesSlider(),
              const SizedBox(height: 24), // Padding for floating button
            ],
          ),
        ),
      ),
      // --- REMOVED the floatingActionButton ---
      // The button is now in tourist_dashboard_screen.dart
    );
  }

  // --- 1. Header (Matches UI) ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop(); // Go back to the Home screen
            },
            icon: Icon(FontAwesomeIcons.arrowLeft, color: AppColors.primaryBlack, size: 24),
          ),
          const Spacer(),
          Text(
            'Find a Guide',
            style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          CustomIconButton(
            onPressed: () { /* TODO: Handle Search */ },
            icon: Icon(FontAwesomeIcons.magnifyingGlass, color: AppColors.primaryBlack, size: 24),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              CustomIconButton(
                onPressed: () { /* TODO: Handle notification */ },
                icon: Icon(FontAwesomeIcons.bell, color: AppColors.primaryBlack, size: 24),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. Image Slider (Matches UI) ---
  Widget _buildImageSlider() {
    return Column(
      children: [
        Container(
          height: 180,
          child: PageView.builder(
            controller: _sliderPageController,
            itemCount: sliderImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(sliderImages[index]), // Use local asset
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SmoothPageIndicator(
          controller: _sliderPageController,
          count: sliderImages.length,
          effect: WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: AppColors.primaryBlue,
            dotColor: AppColors.secondaryGray,
          ),
        ),
      ],
    );
  }

  // --- 3. Form Section (Matches UI) ---
  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book a Guide Now!',
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // City Field
          _buildFormLabel("City"),
          CustomTextField(
            controller: _cityController,
            hintText: 'e.g., Colombo',
            icon: FontAwesomeIcons.mapLocationDot, hint: '',
          ),
          const SizedBox(height: 16),
          // Date Field
          _buildFormLabel("Date"),
          CustomPickerButton(
            hint: 'MM / DD / YYYY',
            icon: FontAwesomeIcons.calendarDay,
            value: _selectedDate == null
                ? null
                : "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}",
            onTap: _showDatePicker,
          ),
          const SizedBox(height: 16),
          // Time Field
          _buildFormLabel("Time"),
          _buildTimePicker(),
          const SizedBox(height: 24),
          // Search Button
          ElevatedButton(
            onPressed: () {
              // TODO: Handle Search Logic
              Navigator.pushNamed(context, '/guideList');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: const StadiumBorder(),
              minimumSize: const Size(double.infinity, 52),
            ),
            child: Text(
              'Search',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for form field labels
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

  // Custom Time Picker Widget
  Widget _buildTimePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
      child: Row(
        children: [
          Icon(FontAwesomeIcons.clock, color: AppColors.primaryGray, size: 20),
          SizedBox(width: 16),
          // Hour
          SizedBox(
            width: 40,
            child: TextField(
              controller: _hourController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTextStyles.textSmall.copyWith(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'HH',
                hintStyle: AppTextStyles.textSmall.copyWith(
                  color: AppColors.primaryGray.withAlpha(150),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Text(':', style: AppTextStyles.textSmall.copyWith(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          // Minute
          SizedBox(
            width: 40,
            child: TextField(
              controller: _minuteController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTextStyles.textSmall.copyWith(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'MM',
                hintStyle: AppTextStyles.textSmall.copyWith(
                  color: AppColors.primaryGray.withAlpha(150),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Spacer(),
          // AM/PM Toggle
          ToggleButtons(
            isSelected: [_isAm, !_isAm],
            onPressed: (index) {
              setState(() {
                _isAm = index == 0;
              });
            },
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.white,
            color: AppColors.primaryBlue,
            fillColor: AppColors.primaryBlue,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text('AM', style: AppTextStyles.textSmall.copyWith(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text('PM', style: AppTextStyles.textSmall.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 4. Top Rated Guides (Matches UI) ---
  Widget _buildSectionHeader(String title) {
    // ... (This widget is unchanged) ...
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () { /* TODO: Handle "See All" */ },
            child: Text(
              "See All",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.thirdGray,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopGuidesSlider() {
    return Container(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: topGuides.length,
        itemBuilder: (context, index) {
          final guide = topGuides[index];
          return _buildGuideCard(
            name: guide['name']!,
            location: guide['location']!,
            rating: guide['rating']!,
            imageUrl: guide['image']!,
            isFirst: index == 0,
            isLast: index == topGuides.length - 1,
          );
        },
      ),
    );
  }

  Widget _buildGuideCard({
    required String name,
    required String location,
    required String rating,
    required String imageUrl,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(
        left: isFirst ? 24.0 : 8.0,
        right: isLast ? 24.0 : 8.0,
        bottom: 8.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(50),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dark gradient for text
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(FontAwesomeIcons.expand, color: Colors.white, size: 20),
            ),
          ),
          // Guide Info
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.mapPin, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                    ),
                    const Spacer(),
                    Icon(FontAwesomeIcons.solidStar, color: Colors.yellow, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Date Picker Logic ---
  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}