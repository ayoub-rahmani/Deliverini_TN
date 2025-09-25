import 'package:app3/device/deviceutils.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.txtdir = TextDirection.rtl,
    this.gifurl,
    this.size = 24,
  });

  final String title;
  final double size;
  final String? gifurl;
  final TextDirection? txtdir;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DeviceUtils.width(context) * 0.07,
          vertical: 11,
        ),
        child: Row(
          mainAxisAlignment: txtdir == TextDirection.rtl
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (gifurl != null) ...[
              RepaintBoundary(
                child: Image.asset(
                  gifurl!,
                  width: 35,
                  height: 35,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to a simple icon if GIF doesn't exist
                    return Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.star,
                        color: Colors.orange[800],
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
            ],
            Text(
              title,
              style: TextStyle(
                fontFamily: "NotoSansArabic_Condensed",
                fontWeight: FontWeight.w900,
                fontSize: size,
              ),
              textDirection: txtdir,
            ),
          ],
        ),
      ),
    );
  }
}