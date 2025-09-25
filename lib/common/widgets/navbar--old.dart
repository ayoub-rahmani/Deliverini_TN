// import 'package:app3/common/navigation_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';

// class Navbar extends StatelessWidget {
//   const Navbar({super.key, required this.controller});
//   final NavigationController controller;
//   @override
//   Widget build(BuildContext context) {
//     double basicheight = 32;
//     double basicwidth = 32;
//     double selectedheight = 40;
//     double selectedwidth = 40;

//     return Obx(
//       () => Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(15),
//             topRight: Radius.circular(15),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: const Color.fromARGB(114, 0, 0, 0),
//               spreadRadius: 2,
//               blurRadius: 20,
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(30),
//             topRight: Radius.circular(30),
//           ),
//           child: NavigationBarTheme(
//             data: NavigationBarThemeData(
//               indicatorColor: Colors.white,
//               labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
//                 Set<WidgetState> states,
//               ) {
//                 if (states.contains(WidgetState.selected)) {
//                   return const TextStyle(
//                     fontFamily: 'NotoSansArabic',
//                     fontWeight: FontWeight.w600,
//                     fontSize: 15,
//                   );
//                 }
//                 return const TextStyle(
//                   fontFamily: 'NotoSansArabic',
//                   fontWeight: FontWeight.w400,
//                   fontSize: 13,
//                 );
//               }),
//             ),
//             child: NavigationBar(
//               backgroundColor: Colors.white,
//               height: 85,
//               selectedIndex: controller.selectedIndex.value,
//               onDestinationSelected: (index) => {
//                 controller.selectedIndex.value = index,
//               },
//               destinations: [
//                 NavigationDestination(
//                   icon: SvgPicture.asset(
//                     'images/notifications.svg',
//                     width: basicwidth,
//                     height: basicheight,
//                     colorFilter: ColorFilter.mode(
//                       Colors.black,
//                       BlendMode.srcIn,
//                     ),
//                   ),
//                   selectedIcon: SvgPicture.asset(
//                     'images/notifications.svg',
//                     width: selectedwidth,
//                     height: selectedheight,
//                     colorFilter: ColorFilter.mode(
//                       Color.fromARGB(255, 210, 102, 0),
//                       BlendMode.srcIn,
//                     ),
//                   ),
//                   label: 'تنبيهات',
//                 ),
//                 NavigationDestination(
//                   icon: SvgPicture.asset(
//                     'images/chat-dots.svg',
//                     width: basicwidth,
//                     height: basicheight,
//                     colorFilter: ColorFilter.mode(
//                       const Color.fromARGB(255, 0, 0, 0),
//                       BlendMode.srcIn,
//                     ),
//                   ),
//                   selectedIcon: SvgPicture.asset(
//                     'images/chat-dots.svg',
//                     width: selectedwidth,
//                     height: selectedheight,
//                     colorFilter: ColorFilter.mode(
//                       const Color.fromARGB(255, 210, 102, 0),
//                       BlendMode.srcIn,
//                     ),
//                   ),
//                   label: 'محادثة',
//                 ),
//                 NavigationDestination(
//                   icon: SvgPicture.asset(
//                     'images/home2.svg',
//                     width: basicwidth + 5,
//                     height: basicheight + 5,
//                     colorFilter: ColorFilter.mode(
//                       Colors.black,
//                       BlendMode.srcIn,
//                     ),
//                   ),
//                   selectedIcon: SvgPicture.asset(
//                     'images/home2.svg',
//                     width: selectedwidth + 5,
//                     height: selectedheight + 5,
//                     colorFilter: ColorFilter.mode(
//                       Colors.black,
//                       BlendMode.srcIn,
//                     ),
//                   ),
//                   label: '',
//                 ),
//                 NavigationDestination(
//                   icon: SvgPicture.asset(
//                     'images/delivery.svg',
//                     width: basicwidth,
//                     height: basicheight,
//                     colorFilter: ColorFilter.mode(
//                       Colors.black,
//                       BlendMode.srcIn,
//                     ),
//                   ),
//                   selectedIcon: SvgPicture.asset(
//                     'images/delivery.svg',
//                     width: selectedwidth,
//                     height: selectedheight,
//                     colorFilter: ColorFilter.mode(
//                       Color.fromARGB(255, 210, 102, 0),
//                       BlendMode.srcIn,
//                     ),
//                   ),
//                   label: 'في الثنية',
//                 ),
//                 NavigationDestination(
//                   icon: SvgPicture.asset(
//                     'images/cart.svg',
//                     width: basicwidth,
//                     height: basicheight,
//                     colorFilter: ColorFilter.mode(
//                       Colors.black,
//                       BlendMode.srcIn,
//                     ),
//                   ),
//                   selectedIcon: SvgPicture.asset(
//                     'images/cart.svg',
//                     width: selectedwidth,
//                     height: selectedheight,
//                     colorFilter: ColorFilter.mode(
//                       Color.fromARGB(255, 210, 102, 0),
//                       BlendMode.srcIn,
//                     ),
//                   ),
//                   label: 'القضية',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
