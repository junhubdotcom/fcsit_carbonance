import 'package:flutter/material.dart';
import '../../common/constants.dart';

class StatCardComponent extends StatelessWidget {
  final String value;
  final String label;

  const StatCardComponent({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _extractValue(value),
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeExtraLarge,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  if (_extractUnit(value) != null)
                    TextSpan(
                      text: _extractUnit(value),
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                fontWeight: FontWeight.normal,
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _extractValue(String fullValue) {
    // Extract the numeric part (e.g., "200" from "200 kg")
    final regex = RegExp(r'^(\d+)');
    final match = regex.firstMatch(fullValue);
    return match?.group(1) ?? fullValue;
  }

  String? _extractUnit(String fullValue) {
    // Extract the unit part (e.g., " kg" from "200 kg")
    final regex = RegExp(r'^(\d+)\s*(.+)');
    final match = regex.firstMatch(fullValue);
    return match?.group(2) != null ? ' ${match!.group(2)}' : null;
  }
} 