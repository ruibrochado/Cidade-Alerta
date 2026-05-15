import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/models/ecocenter_data.dart';
import 'package:app/services/ecocenter_service.dart';

// Fakes the entire SupabaseClient — no mocktail at all.
class FakeSupabaseClient extends Fake implements SupabaseClient {
  final FakeQueryBuilder queryBuilder;
  FakeSupabaseClient(this.queryBuilder);

  @override
  FakeQueryBuilder from(String table) => queryBuilder;
}

class FakeQueryBuilder extends SupabaseQueryBuilder {
  final FakeFilterBuilder filterBuilder;

  FakeQueryBuilder(this.filterBuilder)
    : super(
        'http://localhost',
        RealtimeClient('http://localhost'),
        schema: 'public',
        table: 'ecocenters',
        incrementId: 0,
        isolate: null,
      );

  @override
  FakeFilterBuilder select([String columns = '*']) => filterBuilder;
}

// ignore: must_be_immutable
class FakeFilterBuilder extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  List<Map<String, dynamic>> _data = [];

  void respondWith(List<Map<String, dynamic>> data) => _data = data;

  @override
  FakeFilterBuilder gte(String column, Object value) => this;

  @override
  FakeFilterBuilder lte(String column, Object value) => this;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<Map<String, dynamic>>) onValue, {
    Function? onError,
  }) => Future.value(_data).then(onValue, onError: onError);
}

void main() {
  group('EcocenterService Tests', () {
    late EcocenterService service;
    late FakeFilterBuilder filterBuilder;

    setUp(() {
      filterBuilder = FakeFilterBuilder();
      final queryBuilder = FakeQueryBuilder(filterBuilder);
      final client = FakeSupabaseClient(queryBuilder);
      service = EcocenterService(client: client);
    });

    test('EcocenterData.fromMap maps fields correctly', () {
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
    });

    test('fetchEcocentersByBounds returns data on success', () async {
      filterBuilder.respondWith([
        {
          'id': 10,
          'name': 'EcoPorto',
          'latitude': 41.0,
          'longitude': -8.0,
          'city': 'Porto',
        },
      ]);

      final result = await service.fetchEcocentersByBounds(
        minLat: 40,
        maxLat: 42,
        minLng: -9,
        maxLng: -7,
      );

      expect(result.length, 1);
      expect(result.first.name, 'EcoPorto');
    });
  });
}
