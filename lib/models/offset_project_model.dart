class OffsetProjectModel {
  final String title;
  final String description;
  final String co2Value;
  final String imageUrl;
  final int currentParticipants;
  final int targetParticipants;
  final String cost;
  final String projectType;

  OffsetProjectModel({
    required this.title,
    required this.description,
    required this.co2Value,
    required this.imageUrl,
    this.currentParticipants = 0,
    this.targetParticipants = 1000,
    this.cost = "1000 pts",
    this.projectType = "Reforestation",
  });
} 