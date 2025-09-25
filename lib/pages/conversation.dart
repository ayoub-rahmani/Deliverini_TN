import 'package:app3/device/deviceutils.dart';
import 'package:app3/common/widgets/chat_message.dart';
import 'package:app3/services/chat_service.dart';
import 'package:app3/services/notification_service.dart';
import 'package:app3/models/chat_message.dart';
import 'package:app3/models/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart'; // Added lottie import
import 'dart:async';

class Conversation extends StatefulWidget {
  final String chatId;
  final ChatUser otherUser;

  const Conversation({
    super.key,
    required this.chatId,
    required this.otherUser,
  });

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  late final TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();

  StreamSubscription<List<Message>>? _messageSubscription;
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();

    // Initialize immediately
    _initializeChat();
  }

  void _initializeChat() async {
    print('🚀 Initializing chat: ${widget.chatId}');

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // 🔥 CRITICAL: Cancel any existing subscription first
      await _messageSubscription?.cancel();

      // Start fresh message stream
      _messageSubscription = _chatService.getMessages(widget.chatId).listen(
            (messages) {
          print('📱 RECEIVED ${messages.length} messages in conversation UI');

          if (mounted) {
            setState(() {
              _messages = messages;
              _isLoading = false;
              _hasError = false;
            });

            // Auto-scroll to bottom for new messages
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottomInstantly();
            });
          }
        },
        onError: (error) {
          print('❌ Stream error in conversation: $error');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        },
      );

      // Initialize background services (non-blocking)
      _initializeBackgroundServices();

    } catch (e) {
      print('❌ Init error in conversation: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _initializeBackgroundServices() async {
    try {
      // Run in background without blocking UI
      unawaited(_chatService.markMessagesAsRead(widget.chatId));
      unawaited(NotificationService.initialize());
    } catch (e) {
      print('⚠️ Background services error: $e');
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_textController.text.trim().isNotEmpty) {
      final message = _textController.text.trim();
      _textController.clear();

      HapticFeedback.lightImpact();

      try {
        await _chatService.sendMessage(
          widget.chatId,
          widget.otherUser.id,
          message,
        );

        // Scroll to bottom after sending
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottomSmooth();
        });
      } catch (e) {
        HapticFeedback.heavyImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في إرسال الرسالة'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _scrollToBottomInstantly() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _scrollToBottomSmooth() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = DeviceUtils.statusBarHeight(context);
    final isTablet = DeviceUtils.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Profile picture
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange[100],
                border: Border.all(color: Colors.orange!, width: 2),
              ),
              child: Icon(
                Icons.person,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // User name and status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUser.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                  Text(
                    'متصل الآن',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'NotoSansArabic',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: _buildMessagesArea(),
          ),
          // Input area
          _buildInputArea(isTablet),
        ],
      ),
    );
  }

  Widget _buildMessagesArea() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'خطأ في تحميل الرسائل',
              style: TextStyle(
                fontFamily: 'NotoSansArabic',
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeChat,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'ابدأ المحادثة',
          style: TextStyle(
            fontFamily: 'NotoSansArabic',
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isFromMe = message.senderId == ChatService.currentUserId;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: ChatMessage(
            key: ValueKey('msg_${message.id}_$index'),
            message: message.message,
            time: message.formattedTime,
            isFromMe: isFromMe,
            isRead: message.isRead,
          ),
        );
      },
    );
  }

  Widget _buildInputArea(bool isTablet) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  textDirection: TextDirection.rtl,
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالة...',
                    hintStyle: TextStyle(
                      color: const Color(0xFF999999),
                      fontSize: isTablet ? 18 : 16,
                      fontFamily: 'NotoSansArabic',
                    ),
                    border: InputBorder.none,
                    hintTextDirection: TextDirection.rtl,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: TextStyle(
                    fontFamily: 'NotoSansArabic',
                    fontSize: isTablet ? 18 : 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function for unawaited futures
void unawaited(Future<void> future) {
  // Intentionally ignore the future
}
