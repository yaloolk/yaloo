import 'package:yaloo/features/chat/models/chat_user.dart';
import 'package:yaloo/features/chat/models/message_model.dart';

// --- Users ---
final ChatUser currentUser = ChatUser(
  id: 'u1',
  name: 'Me',
  imageUrl: 'https://placehold.co/100x100/png?text=Me',
);

final ChatUser guide1 = ChatUser(
  id: 'g1',
  name: 'Hadhi Ahamed',
  imageUrl: 'assets/images/guide_1.jpg', // Use asset from your project
  isOnline: true,
);

final ChatUser guide2 = ChatUser(
  id: 'g2',
  name: 'Sarah Johnson',
  imageUrl: 'assets/images/guide_2.jpg',
  isOnline: false,
);

// --- Chats (Last Message) ---
final List<Map<String, dynamic>> chatList = [
  {
    "user": guide1,
    "lastMessage": "I will be at the station by 10 AM.",
    "time": "10:30 AM",
    "unreadCount": 0,
  },
  {
    "user": guide2,
    "lastMessage": "Thank you for the booking!",
    "time": "Yesterday",
    "unreadCount": 1,
  },
];

// --- Messages for Chat with Guide 1 ---
final List<Message> dummyMessages = [
  Message(
    id: 'm1',
    sender: guide1,
    content: "Hello! I saw your booking request.",
    timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    isRead: true,
  ),
  Message(
    id: 'm2',
    sender: currentUser,
    content: "Hi Hadhi, yes! I'm excited to visit Ella.",
    timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
    isRead: true,
  ),
  Message(
    id: 'm3',
    sender: guide1,
    content: "Great! I have a few spots in mind. Do you prefer hiking or sightseeing?",
    timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
    isRead: true,
  ),
  Message(
    id: 'm4',
    sender: currentUser,
    content: "Definitely hiking. I love nature.",
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    isRead: true,
  ),
  Message(
    id: 'm5',
    sender: guide1,
    content: "Perfect. We can do Little Adam's Peak.",
    timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    isRead: true,
  ),
  Message(
    id: 'm6',
    sender: guide1,
    content: "Please confirm the pickup location.",
    timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    type: MessageType.action,
    metadata: {'action': 'Confirm Pickup', 'status': 'pending'},
  ),
  Message(
    id: 'm7',
    sender: currentUser,
    content: "Is this location correct?",
    timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
  ),
  Message(
    id: 'm8',
    sender: currentUser,
    content: "Ella Train Station",
    timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    type: MessageType.location,
  ),
  Message(
    id: 'm9',
    sender: guide1,
    content: "Sure, I will be at the station by 10 AM.",
    timestamp: DateTime.now(),
    isRead: false,
  ),
];