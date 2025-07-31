import 'package:flutter/material.dart';
import 'package:steadypunpipi_vhack/widgets/pet_widget/row_category.dart';

class WardrobePet extends StatefulWidget {
  final Function(String) onHatSelected;
  final Function(String) onShirtSelected;

  const WardrobePet({super.key, required this.onHatSelected, required this.onShirtSelected});

  @override
  State<WardrobePet> createState() => _WardrobePetState();
}

class _WardrobePetState extends State<WardrobePet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> backgroundItems1 = [
    {
      'imageUrl': "assets/images/backgrounds/background1.png",
      'isUnlock': true,
    },
    {
      'imageUrl': "assets/images/backgrounds/background2.png",
      'isUnlock': false,
    },
    {
      'imageUrl': "assets/images/backgrounds/background3.png",
      'isUnlock': false,
    },
  ];

  final List<Map<String, dynamic>> backgroundItems2 = [
    {
      'imageUrl': "assets/images/backgrounds/background1.png",
      'isUnlock': false,
    },
    {
      'imageUrl': "assets/images/backgrounds/background2.png",
      'isUnlock': false,
    },
    {
      'imageUrl': "assets/images/backgrounds/background3.png",
      'isUnlock': false,
    },
  ];

  final List<Map<String, dynamic>> shirtItems1 = [
    {
      'imageUrl': "assets/images/shirts/shirt1.png",
      'isUnlock': true,
    },
    {
      'imageUrl': "assets/images/shirts/shirt2.png",
      'isUnlock': false,
    },
    {
      'imageUrl': "assets/images/shirts/shirt3.png",
      'isUnlock': false,
    },
  ];

  final List<Map<String, dynamic>> shirtItems2 = [
    {
      'imageUrl': "assets/images/shirts/shirt4.png",
      'isUnlock': false,
    },
    {
      'imageUrl': "assets/images/shirts/shirt5.png",
      'isUnlock': false,
    },
    {
      'imageUrl': "assets/images/shirts/shirt3.png",
      'isUnlock': false,
    },
  ];

  final List<Map<String, dynamic>> hatItems1 = [
    {
      'imageUrl': "assets/images/hats/hat1.png",
      'isUnlock': true,
    },
    {
      'imageUrl': "assets/images/hats/hat2.png",
      'isUnlock': false,
    },
    {
      'imageUrl': "assets/images/hats/hat3.png",
      'isUnlock': false,
    },
  ];

  final List<Map<String, dynamic>> hatItems2 = [
    {
      'imageUrl': "assets/images/hats/hat3.png",
      'isUnlock': false,
    },
    {
      'imageUrl': "assets/images/hats/hat4.png",
      'isUnlock': false,
    },
    {
      'imageUrl': "assets/images/hats/hat5.png",
      'isUnlock': false,
    },
  ];

  final List<Map<String, dynamic>> catItems1 = [
    {
      'imageUrl': "assets/images/cats/cat1.png",
      'isUnlock': true,
    },
    {
      'imageUrl': "assets/images/cats/cat2.png",
      'isUnlock': false,
    },
    {
      'imageUrl': "assets/images/cats/cat3.png",
      'isUnlock': false,
    },
  ];

  final List<Map<String, dynamic>> catItems2 = [
    {
      'imageUrl': "assets/images/cats/cat3.png",
      'isUnlock': false,
    },
    {
      'imageUrl': "assets/images/cats/cat4.png",
      'isUnlock': false,
    },
    {
      'imageUrl': "assets/images/cats/cat5.png",
      'isUnlock': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const SizedBox(); // Return an empty widget if not initialized
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.shopping_cart)),
            Tab(icon: Icon(Icons.headset)),
            Tab(icon: Icon(Icons.settings)),
          ],
          onTap: (index) {
            setState(() {});
          },
        ),
        Expanded(
          child: TabBarView(controller: _tabController, children: [
            TabPage(
                title: "Home",
                row1Name: "Hots",
                row2Name: "New",
                row1: backgroundItems1,
                row2: backgroundItems2,
                onItemSelected: widget.onHatSelected),
            TabPage(
                title: "Shirts",
                row1Name: "Hots",
                row2Name: "New",
                row1: shirtItems1,
                row2: shirtItems2,
                onItemSelected: widget.onShirtSelected),
            TabPage(
                title: "Hats",
                row1Name: "Hots",
                row2Name: "New",
                row1: hatItems1,
                row2: hatItems2,
                onItemSelected: widget.onHatSelected),
            TabPage(
                title: "Pets",
                row1Name: "Hots",
                row2Name: "New",
                row1: catItems1,
                row2: catItems2,
                onItemSelected: widget.onHatSelected),
          ]),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class TabPage extends StatelessWidget {
  const TabPage({
    super.key,
    required this.title,
    required this.row1Name,
    required this.row2Name,
    required this.row1,
    required this.row2,
    required this.onItemSelected,
  });

  final String title;
  final String row1Name;
  final String row2Name;
  final List<Map<String, dynamic>> row1;
  final List<Map<String, dynamic>> row2;
  final Function(String) onItemSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          RowCategory(
            rowTitle: row1Name,
            items: row1,
            onItemSelected: onItemSelected,
          ),
          RowCategory(
            rowTitle: row2Name,
            items: row2,
            onItemSelected: onItemSelected,
          ),
        ],
      ),
    );
  }
}
