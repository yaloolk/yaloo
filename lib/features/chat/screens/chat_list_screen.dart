import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/features/chat/data/chat_dummy_data.dart';
import 'package:yaloo/features/chat/models/chat_user.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Chat',
        actions: [
          IconButton(
            onPressed: () { /* TODO: Filter Logic */ },
            icon: Icon(FontAwesomeIcons.sliders, color: AppColors.primaryBlack, size: 20.w),
          ),
          SizedBox(width: 12.w),
        ],
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  hintStyle: TextStyle(color: AppColors.primaryGray),
                  prefixIcon: Icon(Icons.search, color: AppColors.primaryGray, size: 20.w),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),

          // --- Chat List ---
          Expanded(
            child: ListView.separated(
              itemCount: chatList.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: AppColors.secondaryGray.withOpacity(0.3),
                indent: 84.w, // Indent to align with text
                endIndent: 24.w,
              ),
              itemBuilder: (context, index) {
                final chat = chatList[index];
                final ChatUser user = chat['user'];
                return _buildChatTile(context, user, chat['lastMessage'], chat['time'], chat['unreadCount']);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ChatUser user, String lastMessage, String time, int unreadCount) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      onTap: () {
        // Navigate to Message Screen
        Navigator.pushNamed(
            context,
            '/messageScreen',
            arguments: user
        );
      },
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundImage: user.imageUrl.startsWith('http')
                ? NetworkImage(user.imageUrl)
                : AssetImage(user.imageUrl) as ImageProvider,
            onBackgroundImageError: (_, __) => Icon(Icons.person),
          ),
          if (user.isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        user.name,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: Text(
          lastMessage,
          style: AppTextStyles.textSmall.copyWith(
            color: unreadCount > 0 ? AppColors.primaryBlack : AppColors.primaryGray,
            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 12.sp,
              color: unreadCount > 0 ? AppColors.primaryBlue : AppColors.primaryGray,
              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (unreadCount > 0) ...[
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}