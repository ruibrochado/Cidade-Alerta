import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart'; // Necessário para obter a localização

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _currentLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      // 1. Verificar se o serviço de localização está ativo
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização desativado.');
      }

      // 2. Verificar permissões
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão negada.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão negada permanentemente.');
      }

      // 3. Obter a localização exata
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      // 4. Atualizar o estado com as coordenadas
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Fallback: Se falhar (ex: recusou permissões), abre em Lisboa por defeito
      setState(() {
        _currentLocation = const LatLng(38.7223, -9.1393);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Vai buscar a chave do Stadia Maps ao .env
    final String stadiaApiKey = dotenv.env['STADIA_MAPS_API_KEY'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: _isLoading
          ? const Center(
              // Mostra um loading enquanto procura a localização
              child: CircularProgressIndicator(color: Color(0xFF16A34A)),
            )
          : stadiaApiKey.isEmpty
          ? const Center(
              child: Text(
                'STADIA_MAPS_API_KEY não encontrada no .env',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : FlutterMap(
              options: MapOptions(
                // Centraliza o mapa na localização descoberta
                initialCenter: _currentLocation!,
                initialZoom: 15, // Zoom mais próximo (estava 13 antes)
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key=$stadiaApiKey',
                  userAgentPackageName: 'com.example.app',
                  retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
                ),
                // Opcional: Adiciona um marcador azul na tua posição!
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
