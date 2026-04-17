import 'dart:convert';
import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Map<String, String> toApiMap() => {
    'role': role == MessageRole.user ? 'user' : 'assistant',
    'content': content,
  };
}

// ─────────────────────────────────────────────
// Markdown Text Renderer
// Parses *bold, *italic, code, bullet lists, numbered lists
// ─────────────────────────────────────────────

class _MarkdownText extends StatelessWidget {
  final String text;
  final Color baseColor;
  final double fontSize;

  const _MarkdownText({
    required this.text,
    required this.baseColor,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Blank line → small spacer
      if (line.trim().isEmpty) {
        widgets.add(SizedBox(height: 6.h));
        continue;
      }

      // Bullet list: "- item" or "• item"
      final bulletMatch = RegExp(r'^[-•*]\s+(.+)$').firstMatch(line.trim());
      if (bulletMatch != null) {
        widgets.add(_buildBulletLine(bulletMatch.group(1)!));
        continue;
      }

      // Numbered list: "1. item"
      final numberedMatch =
      RegExp(r'^(\d+)\.\s+(.+)$').firstMatch(line.trim());
      if (numberedMatch != null) {
        widgets.add(
            _buildNumberedLine(numberedMatch.group(1)!, numberedMatch.group(2)!));
        continue;
      }

      // Heading: "### text" or "## text" or "# text"
      final headingMatch = RegExp(r'^(#{1,3})\s+(.+)$').firstMatch(line.trim());
      if (headingMatch != null) {
        final level = headingMatch.group(1)!.length;
        final headingText = headingMatch.group(2)!;
        final headingSize = level == 1
            ? fontSize + 4
            : level == 2
            ? fontSize + 2
            : fontSize + 1;
        widgets.add(Padding(
          padding: EdgeInsets.only(top: 6.h, bottom: 2.h),
          child: _buildInlineSpans(
            headingText,
            baseStyle: TextStyle(
              color: baseColor,
              fontSize: headingSize.sp,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ));
        continue;
      }

      // Normal line with inline markdown
      widgets.add(_buildInlineSpans(
        line,
        baseStyle: TextStyle(
          color: baseColor,
          fontSize: fontSize.sp,
          height: 1.55,
        ),
      ));

      // Add small gap between consecutive normal lines
      if (i < lines.length - 1 && lines[i + 1].trim().isNotEmpty) {
        widgets.add(SizedBox(height: 1.h));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  Widget _buildBulletLine(String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h, right: 8.w),
            child: Container(
              width: 5.w,
              height: 5.w,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: _buildInlineSpans(
              content,
              baseStyle: TextStyle(
                color: baseColor,
                fontSize: fontSize.sp,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedLine(String number, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Text(
              '$number.',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: fontSize.sp,
                fontWeight: FontWeight.w700,
                height: 1.55,
              ),
            ),
          ),
          Expanded(
            child: _buildInlineSpans(
              content,
              baseStyle: TextStyle(
                color: baseColor,
                fontSize: fontSize.sp,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Parses inline markdown: *bold, *italic, code
  Widget _buildInlineSpans(String text, {required TextStyle baseStyle}) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`');
    int lastEnd = 0;

    for (final match in pattern.allMatches(text)) {
      // Text before this match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      if (match.group(1) != null) {
        // **bold**
        spans.add(TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(fontWeight: FontWeight.w700),
        ));
      } else if (match.group(2) != null) {
        // *italic*
        spans.add(TextSpan(
          text: match.group(2),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(3) != null) {
        // `code`
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            child: Text(
              match.group(3)!,
              style: baseStyle.copyWith(
                fontFamily: 'monospace',
                fontSize: (fontSize - 1).sp,
                color: const Color(0xFF7DD3FC),
              ),
            ),
          ),
        ));
      }

      lastEnd = match.end;
    }

    // Remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: baseStyle));
    }

    return RichText(text: TextSpan(children: spans));
  }
}

// ─────────────────────────────────────────────
// Chat Screen (modal sheet entry-point)
// ─────────────────────────────────────────────

class AIChatScreen extends StatelessWidget {
  const AIChatScreen({super.key});

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
  // FIX: Use empty string as default instead of null.
  // The backend requires tourist_id to always be present in the request body.
  // An empty string signals "not logged in" and the backend handles it gracefully.
  String _touristId = '';

  static String get _baseUrl => dotenv.env['_aiBaseUrl'] ?? '';

  late AnimationController _headerPulse;
  late Animation<double> _headerPulseAnim;

  int _idCounter = 0;
  String _newId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}';

  // ── lifecycle ─────────────────────────────────

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

    // FIX: was calling resolveTouristId() (missing underscore) — method didn't exist,
    // so _touristId was never populated, causing silent null in the request body.
    _resolveTouristId().then((_) {
      _addAssistantMessage(
        "Hi! I'm **Yaloo AI** 👋\n\nI can help you discover guides, stays, and activities, and answer any questions about the platform.\n\nWhat are you looking for today?",
      );
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _headerPulse.dispose();
    super.dispose();
  }

  // ── tourist_id resolution ─────────────────────

  Future<void> _resolveTouristId() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        debugPrint('🛑 AIChatScreen: User is not logged in.');
        return;
      }

      debugPrint('✅ AIChatScreen: Auth UUID: ${user.id}');

      // STEP 1: Find the User Profile using the Auth ID
      final userProfile = await Supabase.instance.client
          .from('user_profile')
          .select('id')
          .eq('auth_user_id', user.id)
          .maybeSingle();

      if (userProfile == null) {
        debugPrint('⚠️ AIChatScreen: No user_profile found for auth_user_id = ${user.id}');
        return;
      }

      final userProfileId = userProfile['id'];
      debugPrint('✅ AIChatScreen: Found user_profile_id: $userProfileId');

      // STEP 2: Find the Tourist Profile using the User Profile ID
      final touristProfile = await Supabase.instance.client
          .from('tourist_profile')
          .select('id')
          .eq('user_profile_id', userProfileId)
          .maybeSingle();

      if (touristProfile != null && mounted) {
        setState(() => _touristId = touristProfile['id'] as String? ?? '');
        debugPrint('🚀 AIChatScreen: SUCCESS! Tourist ID attached to chat: $_touristId');
      } else {
        debugPrint('⚠️ AIChatScreen: No tourist_profile found for user_profile_id = $userProfileId');
      }
    } catch (e) {
      debugPrint('❌ AIChatScreen: CRITICAL ERROR fetching tourist_id: $e');
    }
  }

  // ── helpers ──────────────────────────────────

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
      final apiMessages = _messages
          .where((m) => !m.isLoading)
          .map((m) => m.toApiMap())
          .toList();

      // FIX: Always include tourist_id in the request body.
      // Previously used `if (_touristId != null)` which omitted the field entirely
      // when not logged in, causing FastAPI to return 422 Unprocessable Entity
      // because tourist_id is a required field in ChatRequest.
      final body = <String, dynamic>{
        'messages': apiMessages,
        'tourist_id': _touristId, // always sent; empty string = not logged in
      };

      final response = await http
          .post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final reply = (data['reply'] as String?)?.trim() ??
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

  Widget _buildHeader() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
    child: Row(
      children: [
        AnimatedBuilder(
          animation: _headerPulse,
          builder: (context, _) => Container(
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
            child: Icon(LucideIcons.bot, color: Colors.white, size: 22.w),
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
        GestureDetector(
          onTap: () {
            setState(() {
              _messages.clear();
              _addAssistantMessage("Chat cleared! How can I help you?");
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

  Widget _buildMessageList() => ListView.builder(
    controller: _scrollController,
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    itemCount: _messages.length,
    itemBuilder: (_, i) => _MessageBubble(
      key: ValueKey(_messages[i].id),
      message: _messages[i],
      isLast: i == _messages.length - 1,
    ),
  );

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
          separatorBuilder: (context, _) => SizedBox(width: 8.w),
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

  Widget _buildInputBar() => Container(
    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w,
        MediaQuery.of(context).viewInsets.bottom + 16.h),
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
            boxShadow:
            _inputController.text.trim().isNotEmpty && !_isSending
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

  const _MessageBubble(
      {super.key, required this.message, required this.isLast});

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
          padding: EdgeInsets.only(bottom: 16.h),
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
                    // ── Bubble ───────────────────────────────
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 0.78 * MediaQuery.of(context).size.width,
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 13.h),
                      decoration: BoxDecoration(
                        gradient: isUser
                            ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2563EB),
                            Color(0xFF1E40AF),
                          ],
                        )
                            : null,
                        color: isUser ? null : const Color(0xFF161B22),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                          bottomLeft: Radius.circular(isUser ? 20.r : 4.r),
                          bottomRight: Radius.circular(isUser ? 4.r : 20.r),
                        ),
                        border: isUser
                            ? null
                            : Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8.r,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: widget.message.isLoading
                          ? _TypingIndicator(key: ValueKey('typing'))
                          : isUser
                      // User messages: plain white text (no markdown needed)
                          ? Text(
                        widget.message.content,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          height: 1.55,
                        ),
                      )
                      // Assistant messages: full markdown rendering
                          : _MarkdownText(
                        text: widget.message.content,
                        baseColor: Colors.white.withOpacity(0.92),
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(height: 5.h),

                    // ── Timestamp ────────────────────────────
                    Text(
                      _formatTime(widget.message.timestamp),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.22),
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
  const _TypingIndicator({super.key});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  static const _phrases = [
    'Waking up AI...',
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
          builder: (context, _) => Opacity(
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