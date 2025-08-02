import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../models/offset_project_model.dart';
import '../../screens/offset/offset_project_detail_screen.dart';
import 'offset_project_card_component.dart';

class CategorySectionComponent extends StatelessWidget {
  final String title;
  final List<OffsetProjectModel> projects;

  const CategorySectionComponent({
    super.key,
    required this.title,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingMedium,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            scrollDirection: Axis.horizontal,
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return OffsetProjectCardComponent(
                title: project.title,
                description: project.description,
                co2Value: project.co2Value,
                imageUrl: project.imageUrl,
                onTap: () {
                  // Navigate to project detail screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OffsetProjectDetailScreen(project: project),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
} 