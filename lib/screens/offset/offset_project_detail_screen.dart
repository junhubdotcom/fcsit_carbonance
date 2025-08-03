import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../models/offset_project_model.dart';
import '../../widgets/offset_widgets/project_text_block_component.dart';
import '../../widgets/offset_widgets/offset_info_tag_component.dart';
import '../../widgets/offset_widgets/community_progress_component.dart';
import '../../widgets/offset_widgets/contribution_card_component.dart';
import '../../widgets/offset_widgets/education_info_card_component.dart';

class OffsetProjectDetailScreen extends StatelessWidget {
  final OffsetProjectModel project;

  const OffsetProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            slivers: [
              // Top Banner with Hero Image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: AppConstants.primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'project_${project.title}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          project.imageUrl,
                          fit: BoxFit.cover,
                        ),
                        // Dark gradient overlay (bottom-up)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        // Project title overlay
                        Positioned(
                          bottom: AppConstants.paddingLarge,
                          left: AppConstants.paddingMedium,
                          right: AppConstants.paddingMedium,
                          child: Text(
                            project.title,
                            style: const TextStyle(
                              fontSize: AppConstants.fontSizeTitle,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // Content sections
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project Description
                      ProjectTextBlockComponent(
                        title: "What is this project?",
                        content: project.description,
                      ),

                      ProjectTextBlockComponent(
                        title: "Why does it matter?",
                        content:
                            "This project helps combat climate change by ${project.projectType.toLowerCase()}. Every contribution directly supports environmental conservation efforts and helps create a sustainable future for our planet.",
                      ),

                      const SizedBox(height: AppConstants.paddingLarge),

                      // Community Progress
                      CommunityProgressComponent(
                        currentParticipants: project.currentParticipants,
                        targetParticipants: project.targetParticipants,
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),

                      // Educational Section
                      const Text(
                        "Learn More",
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      EducationInfoCardComponent(
                        title: "What is ${project.projectType}?",
                        content:
                            "${project.projectType} is a natural climate solution that helps remove carbon dioxide from the atmosphere. It's one of the most effective ways to combat climate change while preserving biodiversity and supporting local communities.",
                      ),

                      EducationInfoCardComponent(
                        title: "How does carbon offsetting work?",
                        content:
                            "When you contribute to a carbon offset project, you're funding activities that reduce or remove greenhouse gas emissions. This helps balance out your own carbon footprint and supports environmental conservation efforts worldwide.",
                      ),

                      EducationInfoCardComponent(
                        title: "What happens after I contribute?",
                        content:
                            "Your contribution will be used to fund the project activities. You'll receive updates on the project's progress and the environmental impact of your contribution. The carbon offset will be verified and certified by independent third parties.",
                      ),

                      // Bottom padding for contribution card
                      const SizedBox(height: 150),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Contribution Card at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ContributionCardComponent(
              cost: project.cost,
              offsetValue: project.co2Value.replaceAll('Offset ', ''),
              onOffset: () {
                // Handle offset action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Successfully contributed to ${project.title}!'),
                    backgroundColor: AppConstants.successColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
                // Navigate back to offset screen after a short delay
                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.of(context).pop();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
