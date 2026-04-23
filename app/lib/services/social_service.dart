import 'dart:math';
import '../models/social_resource.dart';

class SocialService {
  final List<SocialResource> _mockDatabase = const [
    SocialResource(
      id: '1',
      name: 'Abrigo Noturno do Porto',
      category: 'Abrigo',
      latitude: 41.1539,
      longitude: -8.6111,
      address: 'Rua do Bonjardim, Porto',
      contact: '222333444',
      isEmergency: true,
    ),
    SocialResource(
      id: '2',
      name: 'Clínica Solidária de Gaia',
      category: 'Saúde',
      latitude: 41.1305,
      longitude: -8.6186,
      address: 'Avenida da República, Gaia',
      contact: '223444555',
      isEmergency: false,
    ),
    SocialResource(
      id: '3',
      name: 'Cantina Social da Boavista',
      category: 'Alimentação',
      latitude: 41.1578,
      longitude: -8.6290,
      address: 'Praça Mouzinho de Albuquerque',
      contact: '224555666',
      isEmergency: false,
    ),
    SocialResource(
      id: '4',
      name: 'Centro de Acolhimento de Emergência',
      category: 'Abrigo',
      latitude: 41.1456,
      longitude: -8.6150,
      address: 'Rua das Flores, Porto',
      contact: '112',
      isEmergency: true,
    ),
  ];

  double _calculateHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  List<Map<String, dynamic>> getNearestResources({
    required double userLat,
    required double userLon,
    double maxDistanceKm = 10.0,
    String? categoryFilter,
    bool onlyEmergencies = false,
  }) {
    List<Map<String, dynamic>> results = [];

    for (final resource in _mockDatabase) {
      if (categoryFilter != null && resource.category != categoryFilter) {
        continue;
      }

      if (onlyEmergencies && !resource.isEmergency) {
        continue;
      }

      final double distance = _calculateHaversineDistance(
        userLat,
        userLon,
        resource.latitude,
        resource.longitude,
      );

      if (distance <= maxDistanceKm) {
        results.add({
          'resource': resource,
          'distanceKm': distance,
        });
      }
    }

    results.sort((a, b) => (a['distanceKm'] as double).compareTo(b['distanceKm'] as double));

    return results;
  }
}