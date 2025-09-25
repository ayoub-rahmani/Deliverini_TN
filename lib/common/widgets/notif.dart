import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Notif extends StatelessWidget {
  const Notif({
    super.key,
    this.title = "إشعار جديد",
    this.content = "لديك طلب جديد في انتظار التأكيد",
    this.dateTime = "2024/01/15 - 14:30",
    this.isRead = false,
  });

  final String title;
  final String content;
  final String dateTime; // Exact date and time
  final bool isRead; // Read/unread state

  // Reduced spacing values
  static const EdgeInsets _notifMargin = EdgeInsets.symmetric(horizontal: 15, vertical: 4);
  static const EdgeInsets _notifPadding = EdgeInsets.all(12);

  void _showNotificationPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: "NotoSansArabic",
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 15),

                // Content
                Text(
                  content,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontFamily: "NotoSansArabic",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),

                const SizedBox(height: 20),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'تأكيد',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "NotoSansArabic",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => _showNotificationPopup(context),
        child: Container(
          margin: _notifMargin,
          padding: _notifPadding,
          decoration: BoxDecoration(
            color: isRead ? Colors.white : Colors.grey[100], // Different background based on read state
          ),
          child: Row(
            children: [
              // Bell SVG icon with error handling
              Container(
                width: 40,
                height: 40,
                child: SvgPicture.asset(
                  'images/bell.svg',
                  width: 40,
                  height: 40,
                  colorFilter: ColorFilter.mode(
                    isRead ? Colors.black : Colors.grey[600]!, // Different icon color based on read state
                    BlendMode.srcIn,
                  ),
                  // Add error handling
                  placeholderBuilder: (BuildContext context) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isRead ? Colors.grey : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 15),

              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isRead ? Colors.black : Colors.grey[700], // Different text color based on read state
                        fontFamily: "NotoSansArabic",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.right,
                    ),

                    const SizedBox(height: 3),

                    Text(
                      content,
                      style: TextStyle(
                        color: isRead ? Colors.grey[600] : Colors.grey[500], // Different content color based on read state
                        fontFamily: "NotoSansArabic",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 3),

                    Text(
                      dateTime, // Using exact date and time
                      style: TextStyle(
                        color: isRead
                            ? Colors.grey[400]!.withOpacity(0.7) // More opacity for read notifications
                            : Colors.grey[400]!.withOpacity(0.5), // Even more opacity for unread
                        fontFamily: "Poppins", // Using Poppins for date/time for better readability
                        fontSize: 11, // Slightly smaller font
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}