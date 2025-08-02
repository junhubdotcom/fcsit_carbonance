import 'package:flutter/material.dart';
import '../../common/constants.dart';
import 'offset_info_tag_component.dart';

class ContributionCardComponent extends StatelessWidget {
  final String cost;
  final String offsetValue;
  final VoidCallback onOffset;

  const ContributionCardComponent({
    super.key,
    required this.cost,
    required this.offsetValue,
    required this.onOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.borderRadiusMedium),
          topRight: Radius.circular(AppConstants.borderRadiusMedium),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
             child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               // Offset Info Tag
               OffsetInfoTagComponent(
                 value: offsetValue,
                 label: "Your Offset",
               ),
               // Cost and Button
               Column(
                 crossAxisAlignment: CrossAxisAlignment.end,
                 children: [
                   const Text(
                     'Contribution Cost',
                     style: TextStyle(
                       fontSize: AppConstants.fontSizeSmall,
                       fontWeight: FontWeight.normal,
                       color: AppConstants.textSecondary,
                     ),
                   ),
                   const SizedBox(height: AppConstants.paddingExtraSmall),
                   Text(
                     cost,
                     style: const TextStyle(
                       fontSize: AppConstants.fontSizeLarge,
                       fontWeight: FontWeight.bold,
                       color: AppConstants.textPrimary,
                     ),
                   ),
                   const SizedBox(height: AppConstants.paddingMedium),
                   ElevatedButton(
                     onPressed: onOffset,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppConstants.primaryColor,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(
                         horizontal: AppConstants.paddingLarge,
                         vertical: AppConstants.paddingMedium,
                       ),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                       ),
                     ),
                     child: const Text(
                       'Offset Now',
                       style: TextStyle(
                         fontSize: AppConstants.fontSizeMedium,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   ),
                 ],
               ),
             ],
           ),
         ],
       ),
    );
  }
} 