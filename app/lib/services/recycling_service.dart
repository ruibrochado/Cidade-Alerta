import 'dart:math';
import '../models/recycling_bin.dart';

class RecyclingService {
  // Dados de teste (Ecopontos reais no Porto/Gaia)
  final List<RecyclingBin> _binsDatabase = const [
    RecyclingBin(
      id: 'E1',
      type: 'Amarelo',
      latitude: 41.1539,
      longitude: -8.6111,
      address: 'Rua do Bonjardim, Porto',
    ),
    RecyclingBin(
      id: 'E2',
      type: 'Azul',
      latitude: 41.1305,
      longitude: -8.6186,
      address: 'Avenida da República, Gaia',
    ),
    RecyclingBin(
      id: 'E3',
      type: 'Verde',
      latitude: 41.1578,
      longitude: -8.6290,
      address: 'Boavista, Porto',
    ),
  ];

  // A fórmula matemática permanece porque é a forma correta de medir distância no mapa
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371.0;
    final double dLat = (lat2 - lat1) * pi / 180;
    final double dLon = (lon2 - lon1) * pi / 180;

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
        sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  List<Map<String, dynamic>> getNearestBins({
    required double userLat,
    required double userLon,
    String? typeFilter, // Para procurar só ecopontos "Azuis", por exemplo
  }) {
    List<Map<String, dynamic>> results = [];

    for (final bin in _binsDatabase) {
      if (typeFilter != null && bin.type != typeFilter) continue;

      final distance = _calculateDistance(userLat, userLon, bin.latitude, bin.longitude);

      results.add({
        'bin': bin,
        'distanceKm': distance,
      });
    }

    // Ordena do mais próximo para o mais longe
    results.sort((a, b) => (a['distanceKm'] as double).compareTo(b['distanceKm'] as double));
    return results;
  }
}