import 'dart:io'; // Required for File handling
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart'; // Required for picking images
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/custom_icon_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- Profile Image State ---
  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();

  // --- Gallery State ---
  final List<File> _galleryImages = [];

  // --- About Me State ---
  bool _isEditingAbout = false;
  late TextEditingController _aboutController;
  final FocusNode _aboutFocusNode = FocusNode();

  // --- Travel Preferences State ---
  bool _isEditingPreferences = false;
  final List<String> _selectedPreferences = [
    "Adventure",
    "Relaxation",
    "Culture",
    "Family Friendly"
  ];
  late TextEditingController _preferenceController;

  @override
  void initState() {
    super.initState();
    _aboutController = TextEditingController(
      text:
      "Passionate explorer with a love for hidden gems and local cuisine. Always on the lookout for the next adventure, whether it's hiking a mountain or wandering through a historic city. Let's share stories!",
    );
    _preferenceController = TextEditingController();
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _aboutFocusNode.dispose();
    _preferenceController.dispose();
    super.dispose();
  }

  // --- Image Picker Logic ---

  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _profileImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking profile image: $e");
    }
  }

  Future<void> _pickGalleryImage() async {
    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _galleryImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      debugPrint("Error picking gallery image: $e");
    }
  }

  void _showProfilePhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickProfileImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickProfileImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Edit Toggles ---

  void _toggleAboutEdit() {
    setState(() {
      _isEditingAbout = !_isEditingAbout;
    });
    if (_isEditingAbout) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _aboutFocusNode.requestFocus();
      });
    }
  }

  void _togglePreferencesEdit() {
    setState(() {
      _isEditingPreferences = !_isEditingPreferences;
    });
  }

  void _addPreference() {
    if (_preferenceController.text.trim().isNotEmpty) {
      setState(() {
        _selectedPreferences.add(_preferenceController.text.trim());
        _preferenceController.clear();
      });
    }
  }

  void _removePreference(String pref) {
    setState(() {
      _selectedPreferences.remove(pref);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'My Profile',
        actions: [
          CustomIconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: Icon(CupertinoIcons.gear,
                color: AppColors.primaryBlack, size: 24.w),
          ),
          SizedBox(width: 12.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),

            // --- 1. Profile Header ---
            _buildProfileHeader(),
            SizedBox(height: 24.h),

            // --- 2. Stats Grid ---
            _buildStatsGrid(),
            SizedBox(height: 32.h),

            // --- 3. About Me (Editable) ---
            _buildSectionHeader(
              'About Me',
              onEdit: _toggleAboutEdit,
              icon: _isEditingAbout
                  ? FontAwesomeIcons.check
                  : FontAwesomeIcons.pen,
              iconColor: _isEditingAbout
                  ? AppColors.primaryGreen
                  : AppColors.primaryBlue,
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16.r),
                border: _isEditingAbout
                    ? Border.all(color: AppColors.primaryBlue, width: 1.5)
                    : null,
              ),
              child: _isEditingAbout
                  ? TextField(
                controller: _aboutController,
                focusNode: _aboutFocusNode,
                maxLines: null,
                style: AppTextStyles.textSmall.copyWith(
                  color: AppColors.primaryBlack,
                  height: 1.5,
                  fontSize: 14.sp,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              )
                  : Text(
                _aboutController.text,
                style: AppTextStyles.textSmall.copyWith(
                    color: AppColors.primaryGray,
                    height: 1.5,
                    fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 32.h),

            // --- 4. Gallery ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gallery',
                style: AppTextStyles.headlineLargeBlack
                    .copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16.h),
            _buildGalleryGrid(),
            SizedBox(height: 16.h),
            _buildUploadButton(),
            SizedBox(height: 32.h),

            // --- 5. Personal Information ---
            _buildSectionHeader('Personal Information', onEdit: () {
              Navigator.pushNamed(context, '/personalInformation');
            }),
            SizedBox(height: 12.h),
            _buildPersonalInfoList(),
            SizedBox(height: 32.h),

            // --- 6. Travel Preferences ---
            _buildSectionHeader(
              'Travel Preferences',
              onEdit: _togglePreferencesEdit,
              icon: _isEditingPreferences
                  ? FontAwesomeIcons.check
                  : FontAwesomeIcons.pen,
              iconColor: _isEditingPreferences
                  ? AppColors.primaryGreen
                  : AppColors.primaryBlue,
            ),
            SizedBox(height: 12.h),
            _buildPreferencesWrap(),
            SizedBox(height: 32.h),

            // --- 7. Menu Items ---
            _buildMenuItem(CupertinoIcons.heart, "Saved", () {}),
            SizedBox(height: 12.h),
            _buildMenuItem(
                CupertinoIcons.question_circle, "Help & Support", () {}),

            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundColor: Colors.grey.shade200,
                  // Use FileImage if available, otherwise NetworkImage
                  backgroundImage: _profileImageFile != null
                      ? FileImage(_profileImageFile!)
                      : const NetworkImage(
                      'https://placehold.co/200x200/png?text=Cora')
                  as ImageProvider,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showProfilePhotoOptions,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16.w,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Cora Hayes',
          style: AppTextStyles.headlineLargeBlack
              .copyWith(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("United States", "assets/icons/flag_us.png",
                  isIcon: false),
              _buildStatItem("Member since 2022", FontAwesomeIcons.calendar),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("12 Trips Completed", FontAwesomeIcons.suitcase),
              _buildStatItem("English, Spanish", FontAwesomeIcons.language),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String text, dynamic iconOrAsset,
      {bool isIcon = true}) {
    return Expanded(
      child: Row(
        children: [
          isIcon
              ? Icon(iconOrAsset as IconData,
              size: 16.w, color: AppColors.primaryGray)
              : Icon(FontAwesomeIcons.flag,
              size: 16.w, color: AppColors.primaryGray),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.textSmall
                  .copyWith(color: AppColors.primaryGray, fontSize: 13.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title,
      {required VoidCallback onEdit,
        IconData icon = FontAwesomeIcons.pen,
        Color? iconColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineLargeBlack
              .copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: onEdit,
          icon: Icon(icon,
              size: 16.w, color: iconColor ?? AppColors.primaryBlue),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildGalleryGrid() {
    // If no images are uploaded, show placeholders to maintain design layout
    final bool hasImages = _galleryImages.isNotEmpty;
    final int itemCount = hasImages ? _galleryImages.length : 6;

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (hasImages) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.file(
              _galleryImages[index],
              fit: BoxFit.cover,
            ),
          );
        } else {
          // Placeholder styling
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: Icon(CupertinoIcons.photo,
                  color: Colors.grey.shade300, size: 24.w),
            ),
          );
        }
      },
    );
  }

  Widget _buildUploadButton() {
    return ElevatedButton(
      onPressed: _pickGalleryImage, // Calls the picker
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF3F8FF),
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        minimumSize: Size(double.infinity, 52.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.photo_camera,
              size: 20.w, color: const Color(0xFF1F2937)),
          SizedBox(width: 8.w),
          Text(
            'Upload Photo',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoList() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildInfoRow(CupertinoIcons.mail, "cora***@email.com"),
          SizedBox(height: 16.h),
          _buildInfoRow(CupertinoIcons.phone, "+1 (***) ***-1234"),
          SizedBox(height: 16.h),
          _buildInfoRow(CupertinoIcons.globe, "United States"),
          SizedBox(height: 16.h),
          _buildInfoRow(CupertinoIcons.calendar, "October 26"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6B7280), size: 20.w),
        SizedBox(width: 16.w),
        Text(
          text,
          style: TextStyle(
            color: const Color(0xFF374151),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesWrap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: List.generate(_selectedPreferences.length, (index) {
            final pref = _selectedPreferences[index];
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pref,
                    style: TextStyle(
                      color: const Color(0xFF0284C7),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                  if (_isEditingPreferences) ...[
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => _removePreference(pref),
                      child: Icon(Icons.close,
                          size: 14.w, color: const Color(0xFF0284C7)),
                    )
                  ]
                ],
              ),
            );
          }),
        ),
        if (_isEditingPreferences) ...[
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _preferenceController,
                    decoration: InputDecoration(
                      hintText: "Add new...",
                      border: InputBorder.none,
                      hintStyle:
                      TextStyle(fontSize: 12.sp, color: Colors.grey),
                      contentPadding: EdgeInsets.only(bottom: 8.h),
                    ),
                    style: TextStyle(fontSize: 12.sp),
                    onSubmitted: (_) => _addPreference(),
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: _addPreference,
                icon: Icon(Icons.add_circle,
                    color: AppColors.primaryBlue, size: 30.w),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ]
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF4B5563), size: 22.w),
        title: Text(title,
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937))),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 16.w, color: const Color(0xFF9CA3AF)),
      ),
    );
  }
}