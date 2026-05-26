class UserProfile {
  final String id;
  final String role;
  final String? municipalityId;
  final String? municipalityName;
  final String? municipalityCity;

  const UserProfile({
    required this.id,
    required this.role,
    this.municipalityId,
    this.municipalityName,
    this.municipalityCity,
  });

  bool get isMunicipalityWorker => role == 'municipality_worker';

  bool get hasAssignedMunicipality =>
      municipalityId != null && municipalityId!.isNotEmpty;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final municipality = map['municipalities'] as Map<String, dynamic>?;

    return UserProfile(
      id: map['id'].toString(),
      role: map['role']?.toString() ?? 'citizen',
      municipalityId: map['municipality_id']?.toString(),
      municipalityName: municipality?['name']?.toString(),
      municipalityCity: municipality?['city']?.toString(),
    );
  }
}
