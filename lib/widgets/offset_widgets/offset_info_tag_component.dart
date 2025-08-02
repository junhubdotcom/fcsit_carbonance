import 'package:flutter/material.dart';
import '../../common/constants.dart';

class OffsetInfoTagComponent extends StatelessWidget {
  final String value;
  final String label;

  const OffsetInfoTagComponent({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: AppConstants.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.paddingExtraSmall),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              fontWeight: FontWeight.normal,
              color: AppConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
} 