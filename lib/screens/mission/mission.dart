import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/screens/mission/mission_tab1.dart';
import 'package:steadypunpipi_vhack/screens/mission/mission_tab2.dart';
import 'package:steadypunpipi_vhack/screens/mission/mission_tab3.dart';

class MissionPage extends StatelessWidget {
  const MissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Mission and Rewards',
            style: GoogleFonts.quicksand(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(dividerColor: Colors.transparent, tabs: [
            Tab(
                child: Text('Missions',
                    style: TextStyle(fontWeight: FontWeight.normal))),
            Tab(
                child: Text('Redeem',
                    style: TextStyle(fontWeight: FontWeight.normal))),
            Tab(
                child: Text('Rewards',
                    style: TextStyle(fontWeight: FontWeight.normal))),
          ]),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(child: MissionTab1()),
                  ],
                ),
              ),
            ),
            MissionTab2(),
            MissionTab3(),
          ],
        ),
      ),
    );
  }
}
