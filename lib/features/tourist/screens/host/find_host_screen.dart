import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_text_field.dart';
import 'package:yaloo/core/widgets/custom_picker_button.dart';
import 'package:yaloo/features/tourist/widgets/profile_list_card.dart';
import 'package:yaloo/core/widgets/custom_icon_button.dart';

import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_primary_button.dart'; // <-- Import icon button

// --- MOCK DATA ---
final List<String> sliderImages = [
  "assets/images/host_1.png",
  "assets/images/host_2.png",
  "assets/images/host_3.jpg",
  "https://placehold.co/600x400/f4a261/white?text=Host+Image+3",
];
final List<Map<String, String>> topHosts = [
  {"name": "Silva's Village Home", "location": "Kandy", "rating": "4.6", "image": "assets/images/host_1.png"},
  {"name": "Elle Garden Stay", "location": "Ella", "rating": "4.8", "image": "assets/images/host_2.png"},
  {"name": "Galle Fort Villa", "location": "Galle", "rating": "4.7", "image": "assets/images/host_3.jpg"},
];
// -----------------

class FindHostScreen extends StatefulWidget {
  const FindHostScreen({super.key});

  @override
  State<FindHostScreen> createState() => _FindHostScreenState();
}

class _FindHostScreenState extends State<FindHostScreen> {
  final _sliderPageController = PageController();
  final _cityController = TextEditingController();

  DateTimeRange? _selectedDateRange;
  int _guestCount = 3;
  int _roomCount = 1;

  @override
  void dispose() {
    _sliderPageController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Find a Host',
        actions: [
          CustomIconButton(
            onPressed: () { /* TODO: Handle Search */ },
            icon: Icon(CupertinoIcons.search,
                color: AppColors.primaryBlack, size: 24.w),
          ),
          SizedBox(width: 12.w),
          Stack(
            alignment: Alignment.center, // Aligns the dot better
            children: [
              CustomIconButton(
                onPressed: () { /* TODO: Handle notification */ },
                icon: Icon(CupertinoIcons.bell, color: AppColors.primaryBlack, size: 24.w),
              ),
              Positioned(
                top: 10.h,
                right: 10.w,
                child: Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildHeader(),
               SizedBox(height: 16.h),
              _buildImageSlider(),
               SizedBox(height: 24.h),
              _buildFormSection(),
               SizedBox(height: 24.h),
              _buildSectionHeader("Top Rated Host"),
               SizedBox(height: 16.h),
              _buildTopHostSlider(),
               SizedBox(height: 24.h), // Padding for bottom nav
            ],
          ),
        ),
      ),
      // The floating chat button from TouristDashboardScreen will be visible here
    );
  }

  // --- 1. Header (Matches UI) ---
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop(); // Go back to the Home screen
            },
            icon: Icon(FontAwesomeIcons.arrowLeft, color: AppColors.primaryBlack, size: 24.w),
          ),
          const Spacer(),
          Text(
            'Find a Host',
            style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          CustomIconButton(
            onPressed: () { /* TODO: Handle Search */ },
            icon: Icon(FontAwesomeIcons.magnifyingGlass, color: AppColors.primaryBlack, size: 24.w),
          ),
          SizedBox(width: 12.w),
          Stack(
            alignment: Alignment.center,
            children: [
              CustomIconButton(
                onPressed: () { /* TODO: Handle notification */ },
                icon: Icon(FontAwesomeIcons.bell, color: AppColors.primaryBlack, size: 24.w),
              ),
              Positioned(
                top: 10.h,
                right: 10.w,
                child: Container(
                  width: 8.w,
                  height: 8.h,
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
        SizedBox(
          height: 180.h,
          child: PageView.builder(
            controller: _sliderPageController,
            itemCount: sliderImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  image: DecorationImage(
                    image: sliderImages[index].startsWith('assets/')
                        ? AssetImage(sliderImages[index]) as ImageProvider
                        : NetworkImage(sliderImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        SmoothPageIndicator(
          controller: _sliderPageController,
          count: sliderImages.length,
          effect: WormEffect(
            dotHeight: 8.h,
            dotWidth: 8.w,
            activeDotColor: AppColors.primaryBlue,
            dotColor: AppColors.secondaryGray,
          ),
        ),
      ],
    );
  }

  // --- 3. Form Section (Matches UI) ---
  Widget _buildFormSection() {
    String dateRangeText = 'YYYY-MM-DD to YYYY-MM-DD';
    if (_selectedDateRange != null) {
      final start = _selectedDateRange!.start;
      final end = _selectedDateRange!.end;
      dateRangeText = "${start.year}-${start.month.toString().padLeft(2,'0')}-${start.day.toString().padLeft(2,'0')}  To  ${end.year}-${end.month.toString().padLeft(2,'0')}-${end.day.toString().padLeft(2,'0')}";
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book a Host Now!',
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          // City Field
          _buildFormLabel("City"),
          CustomTextField(
            controller: _cityController,
            hintText: 'e.g., Colombo',
            icon: FontAwesomeIcons.mapLocationDot, hint: '',
          ),
          SizedBox(height: 16.h),
          // Date Field
          _buildFormLabel("Date"),
          CustomPickerButton(
            hint: 'Select Date Range',
            icon: FontAwesomeIcons.calendarDay,
            value: _selectedDateRange == null ? null : dateRangeText,
            onTap: _showDateRangePicker,
          ),
          SizedBox(height: 16.h),
          // Guests/Rooms Field
          _buildFormLabel("Guests/Rooms"),
          CustomPickerButton(
            hint: 'Select Guests & Rooms',
            icon: FontAwesomeIcons.userGroup,
            value: '$_guestCount Guests | $_roomCount Room',
            onTap: _showGuestRoomPicker,
          ),
          SizedBox(height: 24.h),
          // Search Button
          ElevatedButton(
            onPressed: () {
              // TODO: Handle Search Logic
              Navigator.pushNamed(context, '/hostList');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: const StadiumBorder(),
              minimumSize: Size(double.infinity, 52.h),
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
      padding: EdgeInsets.only(bottom: 8.h, left: 16.w),
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

  // --- 4. Top Rated Host Slider ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 20.sp,
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

  Widget _buildTopHostSlider() {
    return SizedBox(
      height: 260.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: topHosts.length,
        itemBuilder: (context, index) {
          final host = topHosts[index];
          // Use the new HostListCard widget
          return ProfileListCard(
            name: host['name']!,
            location: host['location']!,
            rating: host['rating']!,
            imageUrl: host['image']!,
          );
        },
      ),
    );
  }

  // --- Action Handlers ---

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: _selectedDateRange,
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
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _showGuestRoomPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        // Use StatefulBuilder to manage the dialog's internal state
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Guests & Rooms',
                      style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 20.sp, fontWeight: FontWeight.bold)
                  ),
                  SizedBox(height: 24.h),
                  _buildCounterRow("Guests", _guestCount, (newCount) {
                    setModalState(() { _guestCount = newCount; });
                  }),
                  SizedBox(height: 16.h),
                  _buildCounterRow("Rooms", _roomCount, (newCount) {
                    setModalState(() { _roomCount = newCount; });
                  }),
                  SizedBox(height: 24.h),
                  CustomPrimaryButton(
                    text: 'Apply',
                    onPressed: () {
                      setState(() {}); // Update the main page UI
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCounterRow(String label, int count, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyLarge.copyWith(fontSize: 18.sp)),
        Row(
          children: [
            IconButton(
              icon: Icon(FontAwesomeIcons.circleMinus, color: AppColors.primaryGray),
              onPressed: count > 1 ? () => onChanged(count - 1) : null,
            ),
            Text(count.toString(), style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 20.sp)),
            IconButton(
              icon: Icon(FontAwesomeIcons.circlePlus, color: AppColors.primaryBlue),
              onPressed: () => onChanged(count + 1),
            ),
          ],
        ),
      ],
    );
  }
}