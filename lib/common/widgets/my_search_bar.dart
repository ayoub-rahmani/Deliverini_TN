import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  const MySearchBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),

      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: const Color.fromARGB(44, 0, 0, 0),
            spreadRadius: 1,
          ),
        ],
        border: BoxBorder.all(
          width: 1,
          color: Color.fromARGB(120, 165, 165, 165),
        ),
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Container(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.search_rounded),
            SizedBox(width: 20),
            Expanded(
              child: TextField(
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: "شاهي حاجة ؟",
                  hintStyle: TextStyle(
                    fontFamily: "NotoSansArabic",
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                  hintTextDirection: TextDirection.rtl,
                ),
                style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
