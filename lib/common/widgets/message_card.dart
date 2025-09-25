import 'package:app3/models/chat_user.dart';
import 'package:app3/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.user,
    required this.onTap,
  });

  final ChatUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          height: 90,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            color: Colors.white,
            border: const Border.fromBorderSide(
              BorderSide(color: Colors.black, width: 0.7),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar with online indicator
              RepaintBoundary(
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.black, width: 0.5),
                          ),
                        ),
                        child: InnerShadow(
                          shadows: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.15),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            radius: 32,
                            backgroundImage: AssetImage(user.profileImage),
                          ),
                        ),
                      ),
                      // Online indicator
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: user.isOnline ? Colors.green : const Color(0xFF424242),
                            shape: BoxShape.circle,
                            border: const Border.fromBorderSide(
                              BorderSide(color: Colors.white, width: 2),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x40000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Text content with last message preview
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // User name
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: "NotoSansArabic",
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Last message preview with StreamBuilder
                      StreamBuilder<String>(
                        stream: _getLastMessageStream(user.id),
                        builder: (context, snapshot) {
                          final lastMessage = snapshot.data ?? 'اضغط للمحادثة';
                          final isOnline = user.isOnline;

                          return Text(
                            isOnline && lastMessage == 'اضغط للمحادثة'
                                ? "متصل الآن"
                                : lastMessage,
                            style: TextStyle(
                              color: isOnline && lastMessage == 'اضغط للمحادثة'
                                  ? Colors.green
                                  : const Color(0xFF666666),
                              fontFamily: "NotoSansArabic",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Unread count badge
              StreamBuilder<int>(
                stream: _getUnreadCountStream(user.id),
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data ?? 0;

                  if (unreadCount == 0) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Get last message stream for preview
  Stream<String> _getLastMessageStream(String otherUserId) {
    final chatId = _generateChatId(ChatService.currentUserId, otherUserId);

    return ChatService().getMessages(chatId).map((messages) {
      if (messages.isEmpty) return 'ابدأ المحادثة';

      final lastMessage = messages.last;
      return lastMessage.message.length > 30
          ? '${lastMessage.message.substring(0, 30)}...'
          : lastMessage.message;
    });
  }

  // Get unread count stream
  Stream<int> _getUnreadCountStream(String otherUserId) {
    final chatId = _generateChatId(ChatService.currentUserId, otherUserId);

    return ChatService().getMessages(chatId).map((messages) {
      return messages.where((message) =>
      message.receiverId == ChatService.currentUserId && !message.isRead
      ).length;
    });
  }

  String _generateChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }
}