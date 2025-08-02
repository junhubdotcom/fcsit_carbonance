import 'package:flutter/material.dart';
import '../../common/constants.dart';

class ProjectTextBlockComponent extends StatelessWidget {
  final String title;
  final String content;

  const ProjectTextBlockComponent({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            content,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              fontWeight: FontWeight.normal,
              color: AppConstants.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
} 