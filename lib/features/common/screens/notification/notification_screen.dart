import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/features/common/models/notification_model.dart';

// --- MOCK DATA ---
final List<NotificationModel> mockNotifications = [
  NotificationModel(
    id: '1',
    title: 'Booking Confirmed!',
    description: 'Your tour with Silva\'s Village Home has been confirmed for Oct 25.',
    time: '2m ago',
    isRead: false,
    type: NotificationType.booking,
  ),
  NotificationModel(
    id: '2',
    title: 'Payment Successful',
    description: 'We have received your payment of \$36.00 for Booking #BK9823.',
    time: '1h ago',
    isRead: false,
    type: NotificationType.payment,
  ),
  NotificationModel(
    id: '3',
    title: 'New Message from Guide',
    description: 'Hadhi: "Hi! I am looking forward to meeting you tomorrow..."',
    time: '3h ago',
    isRead: true,
    type: NotificationType.message,
  ),
  NotificationModel(
    id: '4',
    title: 'Welcome to Yaloo! 🎉',
    description: 'Explore the beauty of Sri Lanka with our top-rated guides.',
    time: '1d ago',
    isRead: true,
    type: NotificationType.system,
  ),
  NotificationModel(
    id: '5',
    title: '10% Off on your next trip',
    description: 'Use code YALOO10 to get a discount on your next booking.',
    time: '2d ago',
    isRead: true,
    type: NotificationType.offer,
  ),
];
// -----------------

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if we have notifications
    final bool hasNotifications = mockNotifications.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          if (hasNotifications)
            TextButton(
              onPressed: () {
                // TODO: Mark all as read logic
              },
              child: Text(
                "Mark all read",
                style: AppTextStyles.textSmall.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          SizedBox(width: 8.w),
        ],
      ),
      body: hasNotifications
          ? ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        itemCount: mockNotifications.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppColors.secondaryGray.withOpacity(0.3),
          indent: 84.w, // Indent to match text alignment
          endIndent: 24.w,
        ),
        itemBuilder: (context, index) {
          final notification = mockNotifications[index];
          return NotificationTile(notification: notification);
        },
      )
          : _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.secondaryGray.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.bellSlash,
              size: 48.w,
              color: AppColors.primaryGray,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Notifications Yet',
            style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'We will let you know when something\nimportant happens.',
            textAlign: TextAlign.center,
            style: AppTextStyles.textSmall.copyWith(
              color: AppColors.primaryGray,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to details based on notification type
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        color: notification.isRead ? Colors.white : const Color(0xFFF0F9FF), // Light blue tint for unread
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Icon ---
            _buildIcon(),
            SizedBox(width: 16.w),

            // --- Content ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: AppColors.primaryBlack,
                            fontSize: 16.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        notification.time,
                        style: AppTextStyles.textSmall.copyWith(
                          color: AppColors.primaryGray,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    notification.description,
                    style: AppTextStyles.textSmall.copyWith(
                      color: notification.isRead ? AppColors.primaryGray : const Color(0xFF374151),
                      fontSize: 14.sp,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // --- Unread Dot ---
            if (!notification.isRead) ...[
              SizedBox(width: 12.w),
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color color;
    Color bgColor;

    switch (notification.type) {
      case NotificationType.booking:
        iconData = FontAwesomeIcons.calendarCheck;
        color = const Color(0xFF0056D2); // Blue
        bgColor = const Color(0xFFEBF2FA);
        break;
      case NotificationType.payment:
        iconData = FontAwesomeIcons.creditCard;
        color = const Color(0xFF166534); // Green
        bgColor = const Color(0xFFDCFCE7);
        break;
      case NotificationType.message:
        iconData = FontAwesomeIcons.solidCommentDots;
        color = const Color(0xFF9333EA); // Purple
        bgColor = const Color(0xFFF3E8FF);
        break;
      case NotificationType.offer:
        iconData = FontAwesomeIcons.tag;
        color = const Color(0xFFB45309); // Orange
        bgColor = const Color(0xFFFEF3C7);
        break;
      case NotificationType.system:
      default:
        iconData = FontAwesomeIcons.bell;
        color = AppColors.primaryGray;
        bgColor = AppColors.secondaryGray.withOpacity(0.2);
        break;
    }

    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(iconData, color: color, size: 20.w),
      ),
    );
  }
}