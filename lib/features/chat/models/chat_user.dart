class ChatUser {
  final String id;
  final String name;
  final String imageUrl;
  final bool isOnline;

  const ChatUser({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.isOnline = false,
  });
}