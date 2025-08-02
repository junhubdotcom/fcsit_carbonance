import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../mission/mission_tab1.dart';

class PersonalOffsetScreen extends StatelessWidget {
  const PersonalOffsetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Personal Offset Header
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
                      "Personal Offset",
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Mission Tab1 Content
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                child: MissionTab1(),
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