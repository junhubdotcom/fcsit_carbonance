class EcoBusinessModel {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String location;
  final List<String> tags;
  final double latitude;
  final double longitude;

  const EcoBusinessModel({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.location,
    required this.tags,
    required this.latitude,
    required this.longitude,
  });
}

class ActionButton {
  final String label;
  final String action;
  final bool isPrimary;

  const ActionButton({
    required this.label,
    required this.action,
    this.isPrimary = false,
  });
} 