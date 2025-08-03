import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../models/offset_project_model.dart';
import '../../widgets/offset_widgets/stat_card_component.dart';
import '../../widgets/offset_widgets/category_section_component.dart';
import 'offset_project_detail_screen.dart';

class OffsetScreen extends StatefulWidget {
  const OffsetScreen({super.key});

  @override
  State<OffsetScreen> createState() => _OffsetScreenState();
}

class _OffsetScreenState extends State<OffsetScreen> {
  // Mock data for offset projects
  List<OffsetProjectModel> _getReforestationProjects() {
    return [
      OffsetProjectModel(
        title: "Amazon Rainforest",
        description: "Plant trees in the world's largest rainforest to restore biodiversity",
        co2Value: "Offset 50kg CO2",
        imageUrl: "assets/images/offset/amazon_rainforest.jpg",
        currentParticipants: 1234,
        targetParticipants: 2000,
        cost: "1000 pts",
        projectType: "Reforestation",
      ),
      OffsetProjectModel(
        title: "Borneo Reforestation",
        description: "Restore degraded lands in Borneo with native tree species",
        co2Value: "Offset 75kg CO2",
        imageUrl: "assets/images/offset/borneo.jpg",
        currentParticipants: 856,
        targetParticipants: 1500,
        cost: "1500 pts",
        projectType: "Reforestation",
      ),
      OffsetProjectModel(
        title: "Urban Forest Initiative",
        description: "Create green spaces in cities to improve air quality",
        co2Value: "Offset 30kg CO2",
        imageUrl: "assets/images/offset/urban_forest.jpeg",
        currentParticipants: 2341,
        targetParticipants: 3000,
        cost: "800 pts",
        projectType: "Reforestation",
      ),
    ];
  }

  List<OffsetProjectModel> _getForestConservationProjects() {
    return [
      OffsetProjectModel(
        title: "Protected Areas",
        description: "Support conservation of existing forest ecosystems",
        co2Value: "Offset 60kg CO2",
        imageUrl: "assets/images/offset/protected.jpg",
        currentParticipants: 567,
        targetParticipants: 1000,
        cost: "1200 pts",
        projectType: "Forest Conservation",
      ),
      OffsetProjectModel(
        title: "Wildlife Corridors",
        description: "Connect fragmented habitats for wildlife movement",
        co2Value: "Offset 45kg CO2",
        imageUrl: "assets/images/offset/wildlife.jpeg",
        currentParticipants: 789,
        targetParticipants: 1200,
        cost: "900 pts",
        projectType: "Forest Conservation",
      ),
    ];
  }

  List<OffsetProjectModel> _getBlueCarbonProjects() {
    return [
      OffsetProjectModel(
        title: "Mangrove Restoration",
        description: "Restore coastal mangrove forests for carbon sequestration",
        co2Value: "Offset 80kg CO2",
        imageUrl: "assets/images/offset/mangrove.jpg",
        currentParticipants: 432,
        targetParticipants: 800,
        cost: "2000 pts",
        projectType: "Blue Carbon",
      ),
      OffsetProjectModel(
        title: "Seagrass Meadows",
        description: "Protect underwater seagrass ecosystems",
        co2Value: "Offset 55kg CO2",
        imageUrl: "assets/images/offset/seagrass.jpg",
        currentParticipants: 654,
        targetParticipants: 1000,
        cost: "1500 pts",
        projectType: "Blue Carbon",
      ),
    ];
  }

  // List<OffsetProjectModel> _getRegenerativeAgricultureProjects() {
  //   return [
  //     OffsetProjectModel(
  //       title: "Soil Health",
  //       description: "Improve soil carbon through regenerative farming practices",
  //       co2Value: "Offset 40kg CO2",
  //       imageUrl: "assets/images/forest.png",
  //     ),
  //     OffsetProjectModel(
  //       title: "Organic Farming",
  //       description: "Support farmers transitioning to sustainable practices",
  //       co2Value: "Offset 35kg CO2",
  //       imageUrl: "assets/images/green_tree.png",
  //     ),
  //   ];
  // }

  // List<OffsetProjectModel> _getGrasslandManagementProjects() {
  //   return [
  //     OffsetProjectModel(
  //       title: "Prairie Restoration",
  //       description: "Restore native grasslands for carbon storage",
  //       co2Value: "Offset 65kg CO2",
  //       imageUrl: "assets/images/forest.png",
  //     ),
  //     OffsetProjectModel(
  //       title: "Grazing Management",
  //       description: "Implement sustainable grazing practices",
  //       co2Value: "Offset 50kg CO2",
  //       imageUrl: "assets/images/green_tree.png",
  //     ),
  //   ];
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign Offset Header
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    const Text(
                      "Campaign Offset",
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                child: Row(
                  children: [
                    StatCardComponent(
                      value: "11 ",
                      label: "Achievements",
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    StatCardComponent(
                      value: "200 kg",
                      label: "CO2 Offset",
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    StatCardComponent(
                      value: "5000 pts",
                      label: "Green Points",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Offset Categories
              CategorySectionComponent(
                title: "Reforestation",
                projects: _getReforestationProjects(),
              ),

              CategorySectionComponent(
                title: "Forest Conservation",
                projects: _getForestConservationProjects(),
              ),

              CategorySectionComponent(
                title: "Blue Carbon",
                projects: _getBlueCarbonProjects(),
              ),

              // CategorySectionComponent(
              //   title: "Regenerative Agriculture",
              //   projects: _getRegenerativeAgricultureProjects(),
              // ),

              // CategorySectionComponent(
              //   title: "Grassland Management",
              //   projects: _getGrasslandManagementProjects(),
              // ),

              // Bottom padding
              const SizedBox(height: AppConstants.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }
}