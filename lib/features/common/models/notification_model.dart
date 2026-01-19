enum NotificationType { booking, payment, message, system, offer }

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final bool isRead;
  final NotificationType type;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
    required this.type,
  });
}