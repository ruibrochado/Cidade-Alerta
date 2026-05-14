class EcocenterData {
  final int id;
  final String name;
  final String? entity;
  final String? city;
  final String? address;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? email;
  final String? website;
  final String? schedule;

  const EcocenterData({
    required this.id,
    required this.name,
    this.entity,
    this.city,
    this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.email,
    this.website,
    this.schedule,
  });

  factory EcocenterData.fromMap(Map<String, dynamic> map) {
    return EcocenterData(
      id: map['id'] as int,
      name: map['name'] as String,
      entity: map['entity'] as String?,
      city: map['city'] as String?,
      address: map['address'] as String?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      website: map['website'] as String?,
      schedule: map['schedule'] as String?,
    );
  }
}
