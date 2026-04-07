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