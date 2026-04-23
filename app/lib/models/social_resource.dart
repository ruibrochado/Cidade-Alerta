class SocialResource {
  final String id;
  final String name;
  final String category;
  final double latitude;
  final double longitude;
  final String address;
  final String contact;
  final bool isEmergency;

  const SocialResource({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.contact,
    required this.isEmergency,
  });
}