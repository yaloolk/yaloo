import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/features/chat/models/chat_user.dart';
import 'package:yaloo/features/chat/models/message_model.dart';
import 'package:yaloo/features/chat/data/chat_dummy_data.dart';
import 'package:intl/intl.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = []; // Local state for messages

  @override
  void initState() {
    super.initState();
    // Initialize with dummy data
    _messages = List.from(dummyMessages);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = Message(
      id: DateTime.now().toString(),
      sender: currentUser,
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(newMessage);
    });
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100, // Add some buffer
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the user we are chatting with
    final ChatUser chatUser = ModalRoute.of(context)!.settings.arguments as ChatUser;

    // Scroll to bottom on first load
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1, // Slight elevation for separation
        shadowColor: Colors.grey.withOpacity(0.1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundImage: chatUser.imageUrl.startsWith('http')
                  ? NetworkImage(chatUser.imageUrl)
                  : AssetImage(chatUser.imageUrl) as ImageProvider,
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chatUser.name,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
                if (chatUser.isOnline)
                  Text(
                    'Online',
                    style: TextStyle(color: Colors.green, fontSize: 12.sp),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert, color: AppColors.primaryBlack),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Chat List ---
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.sender.id == currentUser.id;
                final isNextMessageSameSender = index + 1 < _messages.length && _messages[index + 1].sender.id == message.sender.id;

                return Padding(
                  padding: EdgeInsets.only(bottom: isNextMessageSameSender ? 4.h : 16.h),
                  child: _buildMessageBubble(message, isMe),
                );
              },
            ),
          ),

          // --- Input Area ---
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    if (message.type == MessageType.action) {
      return _buildActionBubble(message);
    }

    if (message.type == MessageType.location) {
      return _buildLocationBubble(message, isMe);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryBlue : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
            bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15.sp,
                height: 1.4,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('h:mm a').format(message.timestamp),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.black45,
                    fontSize: 10.sp,
                  ),
                ),
                if (isMe) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14.w,
                    color: Colors.white70,
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Custom Bubble for Actions (e.g. Confirm Pickup)
  Widget _buildActionBubble(Message message) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.secondaryGray.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 24.w),
            SizedBox(height: 8.h),
            Text(message.content, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: () { /* TODO: Confirm Action */ },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: Size(120.w, 36.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              child: const Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Bubble for Location
  Widget _buildLocationBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 200.w,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryBlue.withOpacity(0.1) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isMe ? AppColors.primaryBlue : Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                height: 100.h,
                color: Colors.grey[300],
                child: Center(child: Icon(Icons.map, size: 40.w, color: Colors.grey[500])), // Placeholder for map image
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.primaryRed, size: 16.w),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      message.content,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // AI Chatbot Button (Optional requirement)
            // IconButton(
            //   onPressed: () { /* TODO: AI Magic */ },
            //   icon: Icon(FontAwesomeIcons.wandMagicSparkles, color: AppColors.primaryBlue, size: 20.w),
            // ),

            // Attachment
            IconButton(
              onPressed: () { /* TODO: Attach */ },
              icon: Icon(Icons.add_circle_outline, color: AppColors.primaryGray, size: 24.w),
            ),

            // Text Field
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 5,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.primaryGray),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.w),

            // Send Button
            GestureDetector(
              onTap: _sendMessage,
              child: CircleAvatar(
                backgroundColor: AppColors.primaryBlue,
                radius: 20.r,
                child: Icon(Icons.send, color: Colors.white, size: 18.w),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
