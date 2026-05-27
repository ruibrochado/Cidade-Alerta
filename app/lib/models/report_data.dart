class ReportData {
  ReportData({
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
    this.status = 'Pendente',
    this.score = 0,
  });

  String id;
  String category;
  String title;
  String description;
  List<String> photos;
  double? latitude;
  double? longitude;
  String? address;
  String? city;
  String? country;
  String status;
  int score;

  factory ReportData.fromMap(Map<String, dynamic> map) {
    return ReportData(
      id: map['id']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Geral',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      photos: map['photo_url'] != null ? [map['photo_url'].toString()] : [],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      address: map['address']?.toString(),
      city: map['city']?.toString(),
      country: map['country']?.toString(),
      status: map['status']?.toString() ?? 'Pendente',
      score: map['score'] as int? ?? 0,
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
    String? status,
    int? score,
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
      city: city ?? this.city,
      country: country ?? this.country,
      status: status ?? this.status,
      score: score ?? this.score,
    );
  }
}
