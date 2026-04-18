class ReportData {
  const ReportData({
    required this.category,
    this.title = '',
    this.description = '',
    this.photos = const <String>[],
    this.latitude,
    this.longitude,
  });

  final String category;
  final String title;
  final String description;
  final List<String> photos;
  final double? latitude;
  final double? longitude;

  factory ReportData.fromMap(Map<String, dynamic> map) {
    return ReportData(
      category: map['category'] ?? 'Geral',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      // Como na DB tens 'photo_url' (String) e no modelo tens 'photos' (List),
      // metemos a URL dentro de uma lista
      photos: map['photo_url'] != null ? [map['photo_url']] : [],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  ReportData copyWith({
    String? category,
    String? title,
    String? description,
    List<String>? photos,
    double? latitude,
    double? longitude,
    bool clearLatitude = false,
    bool clearLongitude = false,
  }) {
    return ReportData(
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      latitude: clearLatitude ? null : (latitude ?? this.latitude),
      longitude: clearLongitude ? null : (longitude ?? this.longitude),
    );
  }
}