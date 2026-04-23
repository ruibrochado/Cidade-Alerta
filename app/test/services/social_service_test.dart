import 'package:flutter_test/flutter_test.dart';
import 'package:app/services/social_service.dart';
import 'package:app/models/social_resource.dart';

void main() {
  group('SocialService Resource Navigator Tests', () {
    late SocialService socialService;

    setUp(() {
      socialService = SocialService();
    });

    test('Should return resources sorted by nearest distance', () {
      final results = socialService.getNearestResources(
        userLat: 41.1496,
        userLon: -8.6109,
        maxDistanceKm: 50.0,
      );

      expect(results.length, 4);

      final firstDistance = results[0]['distanceKm'] as double;
      final secondDistance = results[1]['distanceKm'] as double;

      expect(firstDistance < secondDistance, isTrue);

      final nearestResource = results.first['resource'] as SocialResource;
      expect(nearestResource.name, 'Abrigo Noturno do Porto');
    });

    test('Should filter out resources beyond maxDistanceKm', () {
      final results = socialService.getNearestResources(
        userLat: 41.1496,
        userLon: -8.6109,
        maxDistanceKm: 1.0,
      );

      expect(results.length, 2);

      for (final item in results) {
        expect((item['distanceKm'] as double) <= 1.0, isTrue);
      }
    });

    test('Should filter resources by category', () {
      final results = socialService.getNearestResources(
        userLat: 41.1496,
        userLon: -8.6109,
        categoryFilter: 'Saúde',
      );

      expect(results.length, 1);
      final resource = results.first['resource'] as SocialResource;
      expect(resource.name, 'Clínica Solidária de Gaia');
      expect(resource.category, 'Saúde');
    });

    test('Should filter resources by emergency flag', () {
      final results = socialService.getNearestResources(
        userLat: 41.1496,
        userLon: -8.6109,
        onlyEmergencies: true,
      );

      expect(results.length, 2);

      for (final item in results) {
        final resource = item['resource'] as SocialResource;
        expect(resource.isEmergency, isTrue);
        expect(resource.category, 'Abrigo');
      }
    });
  });
}