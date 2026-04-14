import 'dart:convert';
import 'dart:math' show cos, sin;
import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'package:yaloo/core/constants/colors.dart';

// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────

enum MessageRole { user, assistant }

class ChatMessage {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isLoading;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isLoading = false,
  });

  ChatMessage copyWith({String? content, bool? isLoading}) => ChatMessage(
    id: id,
    content: content ?? this.content,
    role: role,
    timestamp: timestamp,
    isLoading: isLoading ?? this.isLoading,
  );
}

// ─────────────────────────────────────────────
// Chat Screen (modal sheet entry-point)
// ─────────────────────────────────────────────

class AIChatScreen extends StatelessWidget {
  const AIChatScreen({super.key});

  /// Call this from FloatingChatButton's _animateTap()
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => const AIChatScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (_, scrollController) => const _ChatSheetBody(),
    );
  }
}

// ─────────────────────────────────────────────
// Sheet body
// ─────────────────────────────────────────────

class _ChatSheetBody extends StatefulWidget {
  const _ChatSheetBody();

  @override
  State<_ChatSheetBody> createState() => _ChatSheetBodyState();
}

class _ChatSheetBodyState extends State<_ChatSheetBody>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<ChatMessage> _messages = [];
  bool _isSending = false;

  static String get _baseUrl => dotenv.env['_aiBaseUrl'] ?? '';

  late AnimationController _headerPulse;
  late Animation<double> _headerPulseAnim;

  @override
  void initState() {
    super.initState();
    _headerPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _headerPulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _headerPulse, curve: Curves.easeInOut),
    );

    // Welcome message
    _addAssistantMessage(
      "Hi! I'm Yaloo AI 👋  I can help you discover guides, stays, activities, "
          "and answer any questions about the platform. What are you looking for today?",
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _headerPulse.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────

  String _newId() =>
      DateTime.now().millisecondsSinceEpoch.toString() +
          (1000 + (999 * (DateTime.now().microsecond / 1000000)).toInt())
              .toString();

  void _addAssistantMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        id: _newId(),
        content: text,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── send message ─────────────────────────────

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) return;

    HapticFeedback.lightImpact();
    _inputController.clear();

    final userMsg = ChatMessage(
      id: _newId(),
      content: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    final loadingId = _newId();
    final loadingMsg = ChatMessage(
      id: loadingId,
      content: '',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    setState(() {
      _messages.add(userMsg);
      _messages.add(loadingMsg);
      _isSending = true;
    });
    _scrollToBottom();

    try {
      // Build conversation history for context
      final history = _messages
          .where((m) => !m.isLoading && m.id != loadingId)
          .map((m) => {
        'role': m.role == MessageRole.user ? 'user' : 'assistant',
        'content': m.content,
      })
          .toList();

      final response = await http
          .post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': text,
          'history': history,
        }),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final reply = (data['reply'] as String?) ??
            (data['response'] as String?) ??
            (data['message'] as String?) ??
            'Sorry, I didn\'t get a response. Please try again.';

        setState(() {
          final idx = _messages.indexWhere((m) => m.id == loadingId);
          if (idx != -1) {
            _messages[idx] = _messages[idx].copyWith(
              content: reply,
              isLoading: false,
            );
          }
        });
      } else {
        _replaceLoadingWithError(loadingId);
      }
    } catch (_) {
      _replaceLoadingWithError(loadingId);
    } finally {
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _replaceLoadingWithError(String loadingId) {
    setState(() {
      final idx = _messages.indexWhere((m) => m.id == loadingId);
      if (idx != -1) {
        _messages[idx] = _messages[idx].copyWith(
          content:
          'Oops! Something went wrong. Please check your connection and try again.',
          isLoading: false,
        );
      }
    });
  }

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D1117),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            const _GradientDivider(),
            Expanded(child: _buildMessageList()),
            _buildSuggestedChips(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ── drag handle ──────────────────────────────

  Widget _buildHandle() => Center(
    child: Container(
      margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2.r),
      ),
    ),
  );

  // ── header ───────────────────────────────────

  Widget _buildHeader() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
    child: Row(
      children: [
        // Animated AI avatar
        AnimatedBuilder(
          animation: _headerPulse,
          builder: (_, __) => Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlue,
                  AppColors.primaryBlue.withBlue(200),
                  const Color(0xFF1E40AF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue
                      .withOpacity(0.4 * _headerPulseAnim.value),
                  blurRadius: 16.r,
                  spreadRadius: 2.r,
                ),
              ],
            ),
            child: Icon(LucideIcons.bot,
                color: Colors.white, size: 22.w),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yaloo AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    'Online · Yaloo Assistant',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Clear chat
        GestureDetector(
          onTap: () {
            setState(() {
              _messages.clear();
              _addAssistantMessage(
                "Chat cleared! How can I help you?",
              );
            });
          },
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(LucideIcons.trash2,
                color: Colors.white.withOpacity(0.5), size: 18.w),
          ),
        ),
        SizedBox(width: 8.w),
        // Close
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(LucideIcons.x,
                color: Colors.white.withOpacity(0.5), size: 18.w),
          ),
        ),
      ],
    ),
  );

  // ── messages list ────────────────────────────

  Widget _buildMessageList() => ListView.builder(
    controller: _scrollController,
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    itemCount: _messages.length,
    itemBuilder: (_, i) => _MessageBubble(
      message: _messages[i],
      isLast: i == _messages.length - 1,
    ),
  );

  // ── suggested chips ──────────────────────────

  Widget _buildSuggestedChips() {
    if (_isSending || _messages.length > 3) return const SizedBox.shrink();
    final chips = [
      '🏕️  Find stays',
      '🗺️  Recommend guides',
      '🎯  Popular activities',
      '📋  Booking help',
    ];
    return Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
      child: SizedBox(
        height: 36.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: chips.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, i) => GestureDetector(
            onTap: () {
              _inputController.text = chips[i].substring(3).trim();
              _sendMessage();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                ),
              ),
              child: Text(
                chips[i],
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── input bar ────────────────────────────────

  Widget _buildInputBar() => Container(
    padding: EdgeInsets.fromLTRB(
        16.w, 12.h, 16.w, MediaQuery.of(context).viewInsets.bottom + 16.h),
    decoration: BoxDecoration(
      color: const Color(0xFF161B22),
      border: Border(
        top: BorderSide(color: Colors.white.withOpacity(0.07)),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? AppColors.primaryBlue.withOpacity(0.5)
                    : Colors.white.withOpacity(0.08),
              ),
            ),
            child: TextField(
              controller: _inputController,
              focusNode: _focusNode,
              style: TextStyle(color: Colors.white, fontSize: 15.sp),
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Ask Yaloo AI anything…',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 15.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 18.w, vertical: 12.h),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        // Send button
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 46.w,
          height: 46.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _inputController.text.trim().isNotEmpty && !_isSending
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                const Color(0xFF1E40AF),
              ],
            )
                : null,
            color: _inputController.text.trim().isEmpty || _isSending
                ? Colors.white.withOpacity(0.08)
                : null,
            boxShadow: _inputController.text.trim().isNotEmpty && !_isSending
                ? [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.4),
                blurRadius: 12.r,
                spreadRadius: 1.r,
              )
            ]
                : null,
          ),
          child: GestureDetector(
            onTap: _sendMessage,
            child: _isSending
                ? Padding(
              padding: EdgeInsets.all(12.w),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                AlwaysStoppedAnimation(AppColors.primaryBlue),
              ),
            )
                : Icon(
              LucideIcons.sendHorizontal,
              color: _inputController.text.trim().isNotEmpty
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
              size: 20.w,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
// Message Bubble
// ─────────────────────────────────────────────

class _MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isLast;

  const _MessageBubble({required this.message, required this.isLast});

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideIn;
  late Animation<Offset> _offset;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _slideIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    final isUser = widget.message.role == MessageRole.user;
    _offset = Tween<Offset>(
      begin: Offset(isUser ? 0.3 : -0.3, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideIn, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _slideIn, curve: Curves.easeOut));
    _slideIn.forward();
  }

  @override
  void dispose() {
    _slideIn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == MessageRole.user;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _offset,
        child: Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                _AvatarDot(),
                SizedBox(width: 8.w),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 0.72 * MediaQuery.of(context).size.width,
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        gradient: isUser
                            ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryBlue,
                            const Color(0xFF1E40AF),
                          ],
                        )
                            : null,
                        color: isUser ? null : const Color(0xFF21262D),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18.r),
                          topRight: Radius.circular(18.r),
                          bottomLeft: Radius.circular(isUser ? 18.r : 4.r),
                          bottomRight: Radius.circular(isUser ? 4.r : 18.r),
                        ),
                        border: isUser
                            ? null
                            : Border.all(
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                      child: widget.message.isLoading
                          ? _TypingIndicator()
                          : Text(
                        widget.message.content,
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : Colors.white.withOpacity(0.9),
                          fontSize: 14.sp,
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatTime(widget.message.timestamp),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.25),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUser) ...[
                SizedBox(width: 8.w),
                _UserAvatar(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─────────────────────────────────────────────
// Typing indicator — cycling status phrases
// ─────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  static const _phrases = [
    'Fetching your data',
    'Analyzing request',
    'Searching knowledge base',
    'Crafting response',
    'Almost there',
  ];

  int _phraseIndex = 0;
  int _dotCount = 1;
  bool _alive = true;

  late AnimationController _dotController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..value = 1.0;

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _startDotCycle();
    _startPhraseCycle();
  }

  void _startDotCycle() async {
    while (_alive && mounted) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted || !_alive) break;
      setState(() => _dotCount = (_dotCount % 3) + 1);
    }
  }

  void _startPhraseCycle() async {
    while (_alive && mounted) {
      await Future.delayed(const Duration(milliseconds: 2200));
      if (!mounted || !_alive) break;
      await _fadeController.reverse();
      if (!mounted || !_alive) break;
      setState(() => _phraseIndex = (_phraseIndex + 1) % _phrases.length);
      await _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _alive = false;
    _dotController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _dotController,
          builder: (_, __) => Opacity(
            opacity: 0.5 + 0.5 * _dotController.value,
            child: Icon(
              LucideIcons.sparkles,
              color: AppColors.primaryBlue,
              size: 13.w,
            ),
          ),
        ),
        SizedBox(width: 7.w),
        FadeTransition(
          opacity: _fadeAnim,
          child: Text(
            '${_phrases[_phraseIndex]}$dots',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 13.sp,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Small widgets
// ─────────────────────────────────────────────

class _AvatarDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 28.w,
    height: 28.w,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [AppColors.primaryBlue, const Color(0xFF1E40AF)],
      ),
    ),
    child: Icon(LucideIcons.bot, color: Colors.white, size: 14.w),
  );
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 28.w,
    height: 28.w,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.12),
    ),
    child: Icon(LucideIcons.user,
        color: Colors.white.withOpacity(0.7), size: 14.w),
  );
}

class _GradientDivider extends StatelessWidget {
  const _GradientDivider();

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.08),
          Colors.transparent,
        ],
      ),
    ),
  );
}