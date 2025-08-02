import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../widgets/offset_widgets/offset_banner_component.dart';
import '../../widgets/offset_widgets/stat_card_component.dart';
import 'offset_screen.dart';
import 'personal_offset_screen.dart';
import 'green_finance_discovery_screen.dart';
import '../pet/pet.dart';

class OffsetCategoriesScreen extends StatelessWidget {
  const OffsetCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hi Sze Kai,",
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeTitle,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          "Choose your carbon offset journey",
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeMedium,
                            fontWeight: FontWeight.normal,
                            color: AppConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.pets,
                          color: AppConstants.textPrimary),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PetPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium),
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

              // Campaign Offset Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingMedium,
                ),
                child: Text(
                  "Campaign Offset",
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
              ),
              OffsetBannerComponent(
                title: "Community Projects",
                subtitle:
                    "Join community-driven reforestation and conservation projects",
                imageUrl: "assets/images/offset/amazon_rainforest.jpg",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OffsetScreen(),
                    ),
                  );
                },
              ),

              // Personal Offset Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingMedium,
                ),
                child: Text(
                  "Personal Offset",
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
              ),
              OffsetBannerComponent(
                title: "Individual Impact",
                subtitle:
                    "Offset your personal carbon footprint with verified projects",
                imageUrl: "assets/images/offset/personaloffset.jpg",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalOffsetScreen(),
                    ),
                  );
                },
              ),

              // Discovery Green Finance Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingMedium,
                ),
                child: Text(
                  "Discovery Green Finance",
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
              ),
              OffsetBannerComponent(
                title: "Green Businesses",
                subtitle: "Explore businesses that support green finance",
                imageUrl: "assets/images/offset/greenfinance.png",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GreenFinanceDiscoveryScreen(),
                    ),
                  );
                },
              ),

              // Green Energy Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingMedium,
                ),
                child: Text(
                  "Green Energy",
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
              ),
              OffsetBannerComponent(
                title: "Renewable Projects",
                subtitle:
                    "Support renewable energy projects and clean technology",
                imageUrl: "assets/images/offset/greenenergy.png",
                onTap: () {
                  // TODO: Navigate to Green Energy screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Green Energy - Coming Soon!'),
                      backgroundColor: AppConstants.successColor,
                    ),
                  );
                },
              ),

              // Bottom padding
              const SizedBox(height: AppConstants.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }
}
