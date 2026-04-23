import 'package:flutter_test/flutter_test.dart';
import 'package:app/services/recycling_service.dart';
import 'package:app/models/recycling_bin.dart';

void main() {
  group('RecyclingService - Proximidade de Ecopontos', () {
    late RecyclingService recyclingService;

    setUp(() {
      recyclingService = RecyclingService();
    });

    test('Deve ordenar ecopontos do mais próximo para o mais longe', () {
      // Simular utilizador na Avenida dos Aliados, Porto
      final results = recyclingService.getNearestBins(
        userLat: 41.1496,
        userLon: -8.6109,
      );

      expect(results.length, 3);

      // O primeiro da lista deve ser o mais perto (distância menor)
      final firstDist = results[0]['distanceKm'] as double;
      final secondDist = results[1]['distanceKm'] as double;

      expect(firstDist < secondDist, isTrue);

      // Com base nos nossos mocks, o E1 (Amarelo) é o mais próximo dos Aliados
      final nearestBin = results.first['bin'] as RecyclingBin;
      expect(nearestBin.id, 'E1');
      expect(nearestBin.type, 'Amarelo');
    });

    test('Deve filtrar ecopontos apenas por tipo (ex: Azul)', () {
      final results = recyclingService.getNearestBins(
        userLat: 41.1496,
        userLon: -8.6109,
        typeFilter: 'Azul',
      );

      // Só deve devolver o ecoponto azul
      expect(results.length, 1);
      final bin = results.first['bin'] as RecyclingBin;
      expect(bin.type, 'Azul');
      expect(bin.address, contains('Gaia'));
    });

    test('A distância calculada deve ser matematicamente plausível', () {
      final results = recyclingService.getNearestBins(
        userLat: 41.1496,
        userLon: -8.6109,
      );

      // O ecoponto mais próximo (E1) está a cerca de 0.4 - 0.5 km
      final distance = results.first['distanceKm'] as double;

      expect(distance, greaterThan(0.1));
      expect(distance, lessThan(1.0));
    });
  });
}
