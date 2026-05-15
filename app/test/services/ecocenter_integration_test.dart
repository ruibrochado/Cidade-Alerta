import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/models/ecocenter_data.dart';
import 'package:app/services/ecocenter_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

// ignore: must_be_immutable
class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  List<Map<String, dynamic>> _data = [];

  void respondWith(List<Map<String, dynamic>> data) => _data = data;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<Map<String, dynamic>>) onValue, {
    Function? onError,
  }) => Future.value(_data).then(onValue, onError: onError);
}

void main() {
  group('EcocenterService Integration Tests', () {
    late EcocenterService ecocenterService;
    late MockSupabaseClient mockSupabaseClient;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockFilterBuilder;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder();

      ecocenterService = EcocenterService(client: mockSupabaseClient);

      when(
        () => mockSupabaseClient.from('ecocenters'),
      ).thenAnswer((_) => mockQueryBuilder);

      when(
        () => mockQueryBuilder.select(),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () => mockFilterBuilder.gte(any(), any()),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () => mockFilterBuilder.lte(any(), any()),
      ).thenAnswer((_) => mockFilterBuilder);
    });

    test(
      'fetchEcocentersByBounds: envia os filtros corretos e mapeia os dados',
      () async {
        mockFilterBuilder.respondWith([
          {
            'id': 10,
            'name': 'EcoPorto',
            'latitude': 41.0,
            'longitude': -8.0,
            'city': 'Porto',
          },
          {
            'id': 11,
            'name': 'EcoMaia',
            'latitude': 41.2,
            'longitude': -8.6,
            'city': 'Maia',
          },
        ]);

        final result = await ecocenterService.fetchEcocentersByBounds(
          minLat: 40.0,
          maxLat: 42.0,
          minLng: -9.0,
          maxLng: -7.0,
        );

        expect(result.length, 2);
        expect(result[0].name, 'EcoPorto');
        expect(result[0].city, 'Porto');
        expect(result[1].name, 'EcoMaia');
        expect(result[1].city, 'Maia');

        verify(() => mockFilterBuilder.gte('latitude', 40.0)).called(1);

        verify(() => mockFilterBuilder.lte('latitude', 42.0)).called(1);

        verify(() => mockFilterBuilder.gte('longitude', -9.0)).called(1);

        verify(() => mockFilterBuilder.lte('longitude', -7.0)).called(1);
      },
    );

    test(
      'fetchEcocentersByBounds: devolve lista vazia quando não há ecocentros na área',
      () async {
        mockFilterBuilder.respondWith([]);

        final result = await ecocenterService.fetchEcocentersByBounds(
          minLat: 0.0,
          maxLat: 1.0,
          minLng: 0.0,
          maxLng: 1.0,
        );

        expect(result, isEmpty);
      },
    );

    test('EcocenterData.fromMap: mapeia todos os campos corretamente', () {
      final json = {
        'id': 1,
        'name': 'Maia Ecocenter',
        'latitude': 41.2,
        'longitude': -8.6,
        'city': 'Maia',
      };

      final ecocenter = EcocenterData.fromMap(json);

      expect(ecocenter.name, 'Maia Ecocenter');
      expect(ecocenter.city, 'Maia');
      expect(ecocenter.latitude, 41.2);
      expect(ecocenter.longitude, -8.6);
    });
  });
}
