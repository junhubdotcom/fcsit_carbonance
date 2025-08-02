import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../models/eco_business_model.dart';

class DiscoveryCardComponent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final List<ActionButton> actions;
  final String tag;

  const DiscoveryCardComponent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.actions,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Stack(
          children: [
            // Background Image
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient Overlay
            Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Content
            Container(
              height: 300,
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag Badge
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium,
                        vertical: AppConstants.paddingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppConstants.fontSizeSmall,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Title and Subtitle
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppConstants.fontSizeMedium,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  // Action Buttons
                  Row(
                    children: actions.map((action) {
                      return Padding(
                        padding: const EdgeInsets.only(right: AppConstants.paddingSmall),
                        child: OutlinedButton(
                          onPressed: () {
                            // Handle action
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${action.label} action triggered'),
                                backgroundColor: AppConstants.primaryColor,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: action.isPrimary 
                                ? AppConstants.primaryColor 
                                : AppConstants.secondaryColor,
                            side: BorderSide(
                              color: action.isPrimary 
                                  ? AppConstants.primaryColor 
                                  : AppConstants.secondaryColor,
                            ),
                            backgroundColor: Colors.white.withOpacity(0.9),
                          ),
                          child: Text(
                            action.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 