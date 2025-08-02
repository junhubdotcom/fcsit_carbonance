import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../models/eco_business_model.dart';
import '../../widgets/offset_widgets/search_filter_bar_component.dart';
import '../../widgets/offset_widgets/discovery_card_component.dart';
import '../../widgets/offset_widgets/map_location_card_component.dart';
import '../../widgets/offset_widgets/google_maps_component.dart';

class GreenFinanceDiscoveryScreen extends StatefulWidget {
  const GreenFinanceDiscoveryScreen({super.key});

  @override
  State<GreenFinanceDiscoveryScreen> createState() =>
      _GreenFinanceDiscoveryScreenState();
}

class _GreenFinanceDiscoveryScreenState
    extends State<GreenFinanceDiscoveryScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedFilter = 'All';

  // Mock data for daily highlights
  final List<Map<String, dynamic>> _dailyHighlights = [
    {
      'title': 'Eco-Friendly Cafe',
      'subtitle': 'Supporting local farmers with organic ingredients',
      'imageUrl': 'assets/images/offset/greencafe.png',
      'tag': 'Accessible Business',
      'actions': [
        ActionButton(label: 'Visit', action: 'visit', isPrimary: true),
        ActionButton(label: 'Support', action: 'support'),
      ],
    },
    {
      'title': 'Green Tech Startup',
      'subtitle': 'Innovative solutions for renewable energy',
      'imageUrl': 'assets/images/offset/greenoffice.png',
      'tag': 'Youth Business',
      'actions': [
        ActionButton(label: 'Visit', action: 'visit', isPrimary: true),
        ActionButton(label: 'Support', action: 'support'),
      ],
    },
    {
      'title': 'Sustainable Fashion',
      'subtitle': 'Ethical clothing made from recycled materials',
      'imageUrl': 'assets/images/offset/greenfashion.png',
      'tag': 'Women Business',
      'actions': [
        ActionButton(label: 'Visit', action: 'visit', isPrimary: true),
        ActionButton(label: 'Support', action: 'support'),
      ],
    },
  ];

  // Mock data for eco businesses
  final List<EcoBusinessModel> _ecoBusinesses = [
    const EcoBusinessModel(
      title: 'Green Grocer',
      subtitle: 'Fresh organic produce from local farms',
      imageUrl: 'assets/images/offset/greengrocer.png',
      location: 'Kuala Lumpur, Malaysia',
      tags: ['Organic', 'Local'],
      latitude: 3.1390,
      longitude: 101.6869,
    ),
    const EcoBusinessModel(
      title: 'Eco Workshop',
      subtitle: 'Handcrafted sustainable home goods',
      imageUrl: 'assets/images/offset/ecoworkshop.png',
      location: 'Petaling Jaya, Malaysia',
      tags: ['Handmade', 'Sustainable'],
      latitude: 3.0738,
      longitude: 101.5183,
    ),
    const EcoBusinessModel(
      title: 'Solar Solutions',
      subtitle: 'Renewable energy for homes and businesses',
      imageUrl: 'assets/images/offset/mangrove.jpg',
      location: 'Shah Alam, Malaysia',
      tags: ['Renewable', 'Energy'],
      latitude: 3.0738,
      longitude: 101.5183,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    // Handle search functionality
    print('Searching for: $query');
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    // Handle filter functionality
    print('Filter selected: $filter');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                      "Green Finance Discovery",
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Search & Filter Bar
              SearchFilterBarComponent(
                onSearch: _onSearch,
                filters: ['All', 'Women', 'Eco', 'Youth'],
                onFilterSelected: _onFilterSelected,
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Daily Highlights Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium),
                    child: Text(
                      'Daily Highlights',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _dailyHighlights.length,
                      itemBuilder: (context, index) {
                        final highlight = _dailyHighlights[index];
                        return DiscoveryCardComponent(
                          title: highlight['title'],
                          subtitle: highlight['subtitle'],
                          imageUrl: highlight['imageUrl'],
                          tag: highlight['tag'],
                          actions: highlight['actions'],
                        );
                      },
                    ),
                  ),
                  // Page Indicator
                  const SizedBox(height: AppConstants.paddingMedium),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _dailyHighlights.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? AppConstants.primaryColor
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Map Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kuala Lumpur, Malaysia',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimary,
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.all(AppConstants.paddingSmall),
                          decoration: BoxDecoration(
                            color: Colors.pink[100],
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusSmall),
                          ),
                          child: const Icon(
                            Icons.filter_alt_outlined,
                            color: Colors.pink,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  // Google Maps Component
                  GoogleMapsComponent(
                    businesses: _ecoBusinesses,
                    initialLatitude: 3.1390, // Kuala Lumpur
                    initialLongitude: 101.6869,
                    initialZoom: 12.0,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  // Featured Eco Merchants
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium),
                    child: Text(
                      'Featured Eco Merchants',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMedium),
                      itemCount: _ecoBusinesses.length,
                      itemBuilder: (context, index) {
                        return MapLocationCardComponent(
                          business: _ecoBusinesses[index],
                        );
                      },
                    ),
                  ),
                ],
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
