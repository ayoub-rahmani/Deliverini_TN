import 'package:app3/device/deviceutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';

class RecomCard extends StatelessWidget {
  const RecomCard({
    super.key,
    this.liked = false,
    required this.title,
    this.isfreeDel = false,
    required this.price,
    required this.rating,
    required this.resto,
    required this.imgUrl,
  });

  final String imgUrl;
  final bool liked;
  final String title;
  final double price;
  final double rating;
  final bool isfreeDel;
  final String resto;

  // Static decorations to prevent rebuilds
  static const _cardDecoration = BoxDecoration(
    border: Border.fromBorderSide(BorderSide(color: Colors.black, width: 0.7)),
    borderRadius: BorderRadius.all(Radius.circular(15)),
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        blurRadius: 10,
        color: Color.fromARGB(60, 0, 0, 0),
        spreadRadius: 0.5,
      ),
    ],
  );

  static const _ratingDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(15)),
    color: Colors.white,
  );

  static const _freeDeliveryDecoration = BoxDecoration(
    color: Colors.orange,
    borderRadius: BorderRadius.all(Radius.circular(15)),
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = DeviceUtils.width(context);
    final screenHeight = DeviceUtils.height(context);

    return Container(
      height: 290,
      margin: const EdgeInsets.only(bottom: 30),
      width: screenWidth * 0.9,
      decoration: _cardDecoration,
      child: Column(
        children: [
          // Optimized image section
          SizedBox(
            height: screenHeight * 0.2,
            child: Stack(
              children: [
                // Main image with ClipRRect for performance
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 0.7),
                        ),
                      ),
                      child: RepaintBoundary(
                        child: Image.asset(
                          imgUrl,
                          width: screenWidth * 0.9,
                          height: screenHeight * 0.2,
                          fit: BoxFit.cover,
                          cacheWidth: (screenWidth * 0.9 * 2).round(),
                          cacheHeight: (screenHeight * 0.2 * 2).round(),
                        ),
                      ),
                    ),
                  ),
                ),

                // Rating badge
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 80,
                    height: 30,
                    decoration: _ratingDecoration,
                    margin: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.yellow,
                          shadows: [
                            Shadow(
                              color: Color.fromARGB(80, 0, 0, 0),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        const SizedBox(width: 7),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            fontFamily: "NotoSansArabic_Condensed",
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Heart icon
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Icon(
                      liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: liked ? Colors.orange : Colors.white,
                      size: 40,
                      shadows: const [
                        Shadow(
                          blurRadius: 15,
                          color: Color.fromRGBO(255, 255, 255, 1),
                          offset: Offset(-1, -1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content section
          Container(
            height: 110,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: "NotoSansArabic_Condensed",
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Text(
                      resto,
                      style: const TextStyle(
                        fontFamily: "NotoSansArabic_Condensed",
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: Color(0xFF6D6D6D),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RepaintBoundary(
                            child: InnerShadow(
                              shadows: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.2),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                              child: Visibility(
                                visible: isfreeDel,
                                child: Container(
                                  height: 30,
                                  width: 120,
                                  decoration: _freeDeliveryDecoration,
                                  child: const Center(
                                    child: Text(
                                      "التوصيل بلاش",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "NotoSansArabic_Condensed",
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            "$price DT",
                            style: const TextStyle(
                              fontFamily: "NotoSansArabic_Condensed",
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
