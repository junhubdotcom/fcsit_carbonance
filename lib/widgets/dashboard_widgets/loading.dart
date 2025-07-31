import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:steadypunpipi_vhack/widgets/dashboard_widgets/expandable_card.dart';

Widget loading() {
  return LoadingAnimationWidget.staggeredDotsWave(
    color: const Color.fromARGB(255, 179, 179, 179),
    size: 100,
  );
}

Widget loadingTips() {
  return ExpandableCard(
    title: "Tips",
    subtitle: "Smart moves for a better future",
    icon: Icons.tips_and_updates,
    tabs: const [
      Tab(text: "temp"),
    ],
    tabViews: [
      Padding(padding: EdgeInsets.all(36), child: Center(child: loading()))
    ],
  );
}

Widget loadingSummary() {
  return ExpandableCard(
    title: "Summary",
    subtitle: "A big picture",
    icon: Icons.tips_and_updates,
    tabs: const [
      Tab(text: "Overall"),
    ],
    tabViews: [
      Padding(padding: EdgeInsets.all(36), child: Center(child: loading()))
    ],
  );
}
