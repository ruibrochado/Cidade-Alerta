class ReportData {
  const ReportData({
    required this.category,
    this.title = '',
    this.description = '',
    this.photos = const <String>[],
    this.latitude,
    this.longitude,
    this.address,
  });

  final String category;
  final String title;
  final String description;
  final List<String> photos;
  final double? latitude;
  final double? longitude;
  final String? address;

  factory ReportData.fromMap(Map<String, dynamic> map) {
    return ReportData(
      category: map['category'] ?? 'Geral',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      photos: map['photo_url'] != null ? [map['photo_url']] : [],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      address: map['address'] as String?,
    );
  }

  ReportData copyWith({
    String? category,
    String? title,
    String? description,
    List<String>? photos,
    double? latitude,
    double? longitude,
    String? address,
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
      address: address ?? this.address,
    );
  }
}
