import 'package:flutter/material.dart';
import 'package:steadypunpipi_vhack/widgets/pet_widget/circularButton.dart';
import 'chatpet.dart';
import 'package:steadypunpipi_vhack/screens/pet/wardrobe.dart';
import 'package:steadypunpipi_vhack/screens/pet/calendar.dart';

class PetPage extends StatefulWidget {
  @override
  _PetPageState createState() => _PetPageState();
}

class _PetPageState extends State<PetPage> {
  int currentState = 1;

  String? _selectedHat;
  String? _selectedShirt;

  void _updateHatSelection(String imageUrl) {
    setState(() {
      _selectedHat = imageUrl;
      print("Selected Hat: $_selectedHat");
    });
  }

  void _updateShirtSelection(String imageUrl) {
    setState(() {
      _selectedShirt = imageUrl;
      print("Selected Shirt: $_selectedShirt");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Stack(
                        children: [
                          // Background image (most bottom)
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/backgrounds/background1.png', // Replace with your background image path
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Floor image (middle layer)
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/backgrounds/floor1.png', // Replace with your floor image path
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Foreground image (top layer)
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/cats/cat1.png', // Replace with your top image path
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Enabled when selected
                          if (_selectedHat == 'assets/images/hats/hat1.png')
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/hats/hatwear1.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          // Enabled when selected
                          if (_selectedShirt ==
                              'assets/images/shirts/shirt1.png')
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/shirts/shirtwear1.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 10,
                      right: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              CircularButton(
                                icon: Icons.chat_bubble_outline,
                                onPressed: () {
                                  setState(() {
                                    currentState = 1; // Show ChatPet
                                  });
                                },
                              ),
                              SizedBox(width: 10),
                              CircularButton(
                                icon: Icons.shopping_bag_outlined,
                                onPressed: () {
                                  setState(() {
                                    currentState = 2; // Show WardrobePet
                                  });
                                },
                              ),
                              SizedBox(width: 10),
                              CircularButton(
                                icon: Icons.event_note_outlined,
                                onPressed: () {
                                  setState(() {
                                    currentState = 3; // Show CalendarPet
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: _getCurrentWidget(), // Dynamically display the widget
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Method to return the current widget based on the state
  Widget _getCurrentWidget() {
    switch (currentState) {
      case 1:
        return ChatPet();
      case 2:
        return WardrobePet(
          onHatSelected: _updateHatSelection,
          onShirtSelected: _updateShirtSelection,
        );
      case 3:
        return CalendarPet();
      default:
        return ChatPet();
    }
  }
}
