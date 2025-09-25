import 'package:app3/common/navigation_controller.dart';
import 'package:app3/common/widgets/caroussel.dart';
import 'package:app3/common/widgets/category_unit.dart';
import 'package:app3/common/widgets/my_app_bar.dart';
import 'package:app3/common/widgets/my_search_bar.dart';
import 'package:app3/common/widgets/recommendations.dart';
import 'package:app3/common/widgets/section_title.dart';
import 'package:app3/common/widgets/trending_section.dart';
import 'package:app3/common/scroll_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with AutomaticKeepAliveClientMixin, ScrollHelper {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView(
      controller: scrollController, // Use mixin's controller
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      cacheExtent: 2000,
      children: const [
        RepaintBoundary(child: MyAppBar(town: "مدنين", location: "طريق بنقردان")),
        RepaintBoundary(child: MySearchBar()),
        RepaintBoundary(child: Caroussel()),
        RepaintBoundary(child: SectionTitle(title: "شنوا تحب تاكل ؟")),
        RepaintBoundary(child: CategoryUnit()),
        RepaintBoundary(child: SectionTitle(title: "حاجة ضاربة", gifurl: "images/fire.gif")),
        RepaintBoundary(child: TrendingSection()),
        RepaintBoundary(child: SectionTitle(title: "اقتراحات", gifurl: "images/recom.gif")),
        RepaintBoundary(child: Recommendations()),
      ],
    );
  }
}
