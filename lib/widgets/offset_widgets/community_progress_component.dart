import 'package:flutter/material.dart';
import '../../common/constants.dart';

class CommunityProgressComponent extends StatelessWidget {
  final int currentParticipants;
  final int targetParticipants;

  const CommunityProgressComponent({
    super.key,
    required this.currentParticipants,
    required this.targetParticipants,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentParticipants / targetParticipants;
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [AppConstants.boxShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '👥 ',
                style: TextStyle(fontSize: AppConstants.fontSizeLarge),
              ),
              Text(
                '${currentParticipants.toStringAsFixed(0)} people joined',
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 8,
                width: MediaQuery.of(context).size.width * 0.8 * progress,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            '$percentage% of target reached',
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