import 'package:flutter/material.dart';
import '../../common/constants.dart';

class EducationInfoCardComponent extends StatefulWidget {
  final String title;
  final String content;

  const EducationInfoCardComponent({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<EducationInfoCardComponent> createState() => _EducationInfoCardComponentState();
}

class _EducationInfoCardComponentState extends State<EducationInfoCardComponent> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [AppConstants.boxShadow],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppConstants.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(
                left: AppConstants.paddingMedium,
                right: AppConstants.paddingMedium,
                bottom: AppConstants.paddingMedium,
              ),
              child: Text(
                widget.content,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.normal,
                  color: AppConstants.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 