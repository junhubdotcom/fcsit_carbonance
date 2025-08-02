import 'package:flutter/material.dart';
import '../../common/constants.dart';
import 'category_chip_component.dart';

class SearchFilterBarComponent extends StatefulWidget {
  final Function(String) onSearch;
  final List<String> filters;
  final Function(String) onFilterSelected;

  const SearchFilterBarComponent({
    super.key,
    required this.onSearch,
    required this.filters,
    required this.onFilterSelected,
  });

  @override
  State<SearchFilterBarComponent> createState() => _SearchFilterBarComponentState();
}

class _SearchFilterBarComponentState extends State<SearchFilterBarComponent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.filters.first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: widget.onSearch,
            decoration: InputDecoration(
              hintText: "Find merchants, stories, heritage...",
              hintStyle: TextStyle(
                color: AppConstants.textSecondary,
                fontSize: AppConstants.fontSizeMedium,
              ),
              prefixIcon: const Icon(Icons.search, color: AppConstants.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        // Filter Chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            itemCount: widget.filters.length,
            itemBuilder: (context, index) {
              final filter = widget.filters[index];
              return Padding(
                padding: const EdgeInsets.only(right: AppConstants.paddingSmall),
                child: CategoryChipComponent(
                  label: filter,
                  isSelected: _selectedFilter == filter,
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                    widget.onFilterSelected(filter);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 