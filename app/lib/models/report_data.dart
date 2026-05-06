class ReportData {
  const ReportData({
    this.id = '',
    required this.category,
    this.title = '',
    this.description = '',
    this.photos = const <String>[],
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.country,
    this.score = 0, // <-- NOVO
  });

  final String id;
  final String category;
  final String title;
  final String description;
  final List<String> photos;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? country;
  final int score; // <-- NOVO

  factory ReportData.fromMap(Map<String, dynamic> map) {
    return ReportData(
      id: map['id']?.toString() ?? '',
      category: map['category'] ?? 'Geral',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      photos: map['photo_url'] != null ? [map['photo_url']] : [],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      address: map['address'] as String?,
      score: map['score'] as int? ?? 0, // <-- NOVO LÊ DIRETAMENTE DO SUPABASE
    );
  }

  ReportData copyWith({
    String? id,
    String? category,
    String? title,
    String? description,
    List<String>? photos,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? country,
    int? score, // <-- NOVO
    bool clearLatitude = false,
    bool clearLongitude = false,
  }) {
    return ReportData(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      latitude: clearLatitude ? null : (latitude ?? this.latitude),
      longitude: clearLongitude ? null : (longitude ?? this.longitude),
      address: address ?? this.address,
      city: city ?? city,
      country: country ?? country,
      score: score ?? this.score, // <-- NOVO
    );
  }
}
