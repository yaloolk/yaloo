import 'package:yaloo/features/chat/models/chat_user.dart';

enum MessageType { text, image, location, action }

class Message {
  final String id;
  final ChatUser sender;
  final String content; // Text content or image URL
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;
  final Map<String, dynamic>? metadata; // For location lat/long or action button data

  const Message({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
    this.metadata,
  });
}