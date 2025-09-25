import 'package:app3/common/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({super.key, required this.town, required this.location});
  final String town;
  final String location;

  void _showSideMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Side Menu',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            // Optimized background - simple tap to close
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            // Side menu with optimized animation
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.fastOutSlowIn,
                )),
                child: const SideMenu(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: SizedBox(
        height: 70,
        child: ListTile(
          leading: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showSideMenu(context);
                },
                child: const Icon(
                  Icons.menu_rounded,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                town,
                style: TextStyle(
                  fontFamily: 'NotoSansArabic',
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage('images/location.png'),
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      location,
                      style: const TextStyle(
                        fontFamily: 'NotoSansArabic',
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.account_circle,
                size: 30,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}