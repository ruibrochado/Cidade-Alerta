import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ecocenter_data.dart';

class EcocenterService {
  final SupabaseClient _client;

  EcocenterService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<List<EcocenterData>> fetchEcocentersByBounds({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
  }) async {
    final response = await _client
        .from('ecocenters')
        .select()
        .gte('latitude', minLat)
        .lte('latitude', maxLat)
        .gte('longitude', minLng)
        .lte('longitude', maxLng);

    return (response as List<dynamic>)
        .map((row) => EcocenterData.fromMap(row as Map<String, dynamic>))
        .toList();
  }
}
