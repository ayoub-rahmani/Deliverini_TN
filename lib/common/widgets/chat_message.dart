import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    super.key,
    required this.message,
    required this.time,
    required this.isFromMe,
    this.isRead = false, // Ensure this parameter is defined
  });

  final String message;
  final String time;
  final bool isFromMe;
  final bool isRead; // Ensure this field is defined

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: Row(
          mainAxisAlignment: isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isFromMe) ...[
              // Read status indicators for sent messages
              Container(
                margin: const EdgeInsets.only(right: 8, bottom: 4),
                child: Icon(
                  isRead ? Icons.done_all : Icons.done,
                  size: 16,
                  color: isRead ? Colors.blue : Colors.grey[600],
                ),
              ),
            ],

            // Message bubble
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isFromMe ? Colors.orange : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: isFromMe ? const Radius.circular(20) : const Radius.circular(4),
                    bottomRight: isFromMe ? const Radius.circular(4) : const Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        color: isFromMe ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontFamily: 'NotoSansArabic',
                        fontWeight: FontWeight.w500,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: isFromMe ? Colors.white70 : Colors.grey[600],
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
