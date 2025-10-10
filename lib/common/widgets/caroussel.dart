
import 'package:app3/common/widgets/circular_container.dart';
import 'package:app3/common/widgets/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import '../home_controller.dart';

class Caroussel extends StatelessWidget {
  const Caroussel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.only(top: 10),
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                pauseAutoPlayOnTouch: true,
                aspectRatio: 16/9,
                onPageChanged: (index, reason) {
                  controller.updatePageIndicator(index);
                },
                viewportFraction: 1.0,
                enableInfiniteScroll: true,
                scrollPhysics: const BouncingScrollPhysics(),
              ),
              items: [
                _buildCarouselItem("images/image1.png", () {
                  print("Image 1 pressed");
                }),
                _buildCarouselItem("images/image2.jpg", () {
                  print("Image 2 pressed");
                }),
                _buildCarouselItem("images/image1.png", () {
                  print("Image 3 pressed");
                }),
                _buildCarouselItem("images/image1.png", () {
                  print("Image 3 pressed");
                }),
              ],
            ),

            const SizedBox(height: 15),

            // Page indicators
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4, // Number of carousel items
                    (index) => RoundedContainer(
                  width: controller.carousalCurrentIndex.value == index ? 20 : 10,
                  height: 10,
                  radius: 5,
                  bgcolor: controller.carousalCurrentIndex.value == index
                      ? Colors.orange[900]!
                      : Colors.grey[300]!,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselItem(String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: RoundedImage(
          imgURL: imagePath,
          width: double.infinity,
          borderRadius: 15,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}