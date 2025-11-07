import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

// Import the screens for each tab
import 'home_screen.dart';
import 'chat_screen.dart';
import 'tourist_bookings_screen.dart';
import 'tourist_profile_screen.dart';

class TouristDashboardScreen extends StatefulWidget {
  const TouristDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TouristDashboardScreen> createState() => _TouristDashboardScreenState();
}

class _TouristDashboardScreenState extends State<TouristDashboardScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    HomeScreen(),
    ChatScreen(),
    BookingsScreen(),
    ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: _pages,
          ),
          Positioned(
            bottom: 30,
            right: 24,
            child: _buildChatBubble(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        // --- UPDATED ICONS ---
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.messageCircle),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.calendar),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
        // --- END OF UPDATE ---
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.primaryGray,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTextStyles.textSmall.copyWith(fontSize: 12),
        unselectedLabelStyle: AppTextStyles.textSmall.copyWith(fontSize: 12),
        elevation: 8.0,
      ),
    );
  }

  Widget _buildChatBubble() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withAlpha(100),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          // TODO: Open Chat AI
        },
        // --- UPDATED ICON ---
        icon: Icon(LucideIcons.bot, color: Colors.white, size: 32),
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}