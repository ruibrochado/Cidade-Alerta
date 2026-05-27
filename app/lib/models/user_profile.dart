class UserProfile {
  final String id;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? municipalityId;
  final String? municipalityName;
  final String? municipalityCity;

  const UserProfile({
    required this.id,
    required this.role,
    this.firstName,
    this.lastName,
    this.municipalityId,
    this.municipalityName,
    this.municipalityCity,
  });

  bool get isMunicipalityWorker => role == 'municipality_worker';

  bool get hasAssignedMunicipality =>
      municipalityId != null && municipalityId!.isNotEmpty;

  String get fullName {
    final name = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return name.isEmpty ? 'Municipality Worker' : name;
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'].toString(),
      role: map['role']?.toString() ?? 'citizen',
      firstName: map['first_name']?.toString(),
      lastName: map['last_name']?.toString(),
      municipalityId: map['municipality_id']?.toString(),
      municipalityName: map['municipality_name']?.toString(),
      municipalityCity: map['municipality_city']?.toString(),
    );
  }
}
