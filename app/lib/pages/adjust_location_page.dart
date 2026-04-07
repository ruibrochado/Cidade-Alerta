import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/report_data.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
import 'confirm_report_page.dart';

class AdjustLocationPage extends StatefulWidget {
  const AdjustLocationPage({super.key, required this.report});

  final ReportData report;

  @override
  State<AdjustLocationPage> createState() => _AdjustLocationPageState();
}

class _AdjustLocationPageState extends State<AdjustLocationPage> {
  static const LatLng _defaultCenter = LatLng(41.1579, -8.6291); // Porto
  static const String _appPackageName = 'com.example.app';

  late final MapController _mapController;

  LatLng? _selectedLocation;
  bool _isGettingCurrentLocation = false;
  String? _errorMessage;

  String get _stadiaApiKey => dotenv.env['STADIA_MAPS_API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    if (widget.report.latitude != null && widget.report.longitude != null) {
      _selectedLocation = LatLng(
        widget.report.latitude!,
        widget.report.longitude!,
      );
    }
  }

  LatLng get _initialCenter => _selectedLocation ?? _defaultCenter;

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isGettingCurrentLocation = true;
      _errorMessage = null;
    });

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Os serviços de localização estão desativados.');
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Permissão negada permanentemente. Ative-a nas definições do dispositivo.',
        );
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final LatLng currentLatLng = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _selectedLocation = currentLatLng;
        _isGettingCurrentLocation = false;
      });

      _mapController.move(currentLatLng, 17);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isGettingCurrentLocation = false;
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
      _errorMessage = null;
    });
  }

  Future<void> _openOsmCopyright() async {
    final Uri uri = Uri.parse('https://www.openstreetmap.org/copyright');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmLocation() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escolha uma localização no mapa primeiro.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmPage(
          report: widget.report.copyWith(
            latitude: _selectedLocation!.latitude,
            longitude: _selectedLocation!.longitude,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool missingApiKey = _stadiaApiKey.isEmpty;

    return AppScaffold(
      title: 'Ajustar Localização',
      subtitle: 'Toque no mapa para escolher o local exato',
      showBackButton: true,
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 360,
              width: double.infinity,
              child: missingApiKey
                  ? Container(
                      color: const Color(0xFFF3F4F6),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(24),
                      child: const Text(
                        'A chave STADIA_MAPS_API_KEY não foi encontrada no ficheiro .env.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _initialCenter,
                        initialZoom: 16,
                        onTap: _onMapTap,
                      ),
                      children: <Widget>[
                        TileLayer(
                          urlTemplate:
                              'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key=$_stadiaApiKey',
                          userAgentPackageName: _appPackageName,
                        ),
                        MarkerLayer(
                          markers: _selectedLocation == null
                              ? <Marker>[]
                              : <Marker>[
                                  Marker(
                                    point: _selectedLocation!,
                                    width: 50,
                                    height: 50,
                                    child: const Icon(
                                      Icons.location_pin,
                                      size: 50,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                        ),
                        RichAttributionWidget(
                          attributions: <SourceAttribution>[
                            TextSourceAttribution(
                              '© OpenStreetMap contributors',
                              onTap: _openOsmCopyright,
                            ),
                            const TextSourceAttribution('© Stadia Maps'),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _selectedLocation == null
                ? const Text(
                    'Nenhuma localização selecionada.',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Coordenadas selecionadas:',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                        '${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
          ),
          if (_errorMessage != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isGettingCurrentLocation || missingApiKey
                      ? null
                      : _useCurrentLocation,
                  icon: _isGettingCurrentLocation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(
                    _isGettingCurrentLocation
                        ? 'A obter...'
                        : 'Usar localização atual',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Confirmar Localização',
            onPressed: _confirmLocation,
          ),
        ],
      ),
    );
  }
}