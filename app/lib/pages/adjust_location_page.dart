import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

import '../models/report_data.dart';
import '../widgets/primary_button.dart';

class AdjustLocationPage extends StatefulWidget {
  const AdjustLocationPage({super.key, required this.report});

  final ReportData report;

  @override
  State<AdjustLocationPage> createState() => _AdjustLocationPageState();
}

class _AdjustLocationPageState extends State<AdjustLocationPage> {
  late final MapController _mapController;
  late LatLng _selectedLocation;

  bool _loadingAddress = true;
  String _error = '';

  String? _street;
  String? _city;
  String? _country;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _selectedLocation = LatLng(
      widget.report.latitude ?? 38.7223,
      widget.report.longitude ?? -9.1393,
    );

    _loadAddressForSelectedLocation();
  }

  Future<void> _loadAddressForSelectedLocation() async {
    setState(() {
      _loadingAddress = true;
      _error = '';
    });

    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        _selectedLocation.latitude,
        _selectedLocation.longitude,
      );

      final Placemark? place = placemarks.isNotEmpty ? placemarks.first : null;

      final String street = <String?>[place?.street, place?.subThoroughfare]
          .where((String? value) => value != null && value.trim().isNotEmpty)
          .cast<String>()
          .join(', ');

      final List<String> cityCandidates =
          <String?>[
                place?.locality,
                place?.subAdministrativeArea,
                place?.administrativeArea,
              ]
              .where(
                (String? value) => value != null && value.trim().isNotEmpty,
              )
              .cast<String>()
              .toList();

      if (!mounted) return;

      setState(() {
        _street = street.isEmpty ? null : street;
        _city = cityCandidates.isEmpty ? null : cityCandidates.first;
        _country = place?.country;
        _loadingAddress = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _street = null;
        _city = null;
        _country = null;
        _loadingAddress = false;
        _error = 'Não foi possível obter a morada desta localização.';
      });
    }
  }

  Future<void> _updateSelectedLocation(LatLng newLocation) async {
    setState(() {
      _selectedLocation = newLocation;
    });

    await _loadAddressForSelectedLocation();
  }

  void _confirmLocation() {
    final ReportData updatedReport = widget.report.copyWith(
      latitude: _selectedLocation.latitude,
      longitude: _selectedLocation.longitude,
    );

    Navigator.pushNamed(
      context,
      '/confirm', // Usa a rota definida no AppRoutes
      arguments: updatedReport,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color headerGreen = Color(0xFFCDE5CB);
    final String stadiaApiKey = dotenv.env['STADIA_MAPS_API_KEY'] ?? '';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: headerGreen,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: headerGreen,
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 300,
                  width: double.infinity,
                  color: headerGreen,
                ),
                Expanded(child: Container(color: const Color(0xFFF8F8F8))),
              ],
            ),
            SafeArea(
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 74,
                    left: 24,
                    right: 24,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Ajustar Localização',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Confirme ou ajuste o ponto no mapa',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 175,
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 24,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          return SingleChildScrollView(
                            key: const Key('mainScroll'),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: IntrinsicHeight(
                                child: Column(
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: SizedBox(
                                        height: 280,
                                        width: double.infinity,
                                        child: stadiaApiKey.isEmpty
                                            ? Container(
                                                color: const Color(0xFFF3F4F6),
                                                child: const Center(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(24),
                                                    child: Text(
                                                      'STADIA_MAPS_API_KEY não encontrada no .env',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : FlutterMap(
                                                mapController: _mapController,
                                                options: MapOptions(
                                                  initialCenter:
                                                      _selectedLocation,
                                                  initialZoom: 17,
                                                  onTap:
                                                      (
                                                        TapPosition _,
                                                        LatLng point,
                                                      ) {
                                                        _updateSelectedLocation(
                                                          point,
                                                        );
                                                      },
                                                ),
                                                children: <Widget>[
                                                  TileLayer(
                                                    urlTemplate:
                                                        'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key=$stadiaApiKey',
                                                    userAgentPackageName:
                                                        'com.example.app',
                                                    retinaMode:
                                                        MediaQuery.of(
                                                          context,
                                                        ).devicePixelRatio >
                                                        1.0,
                                                  ),
                                                  MarkerLayer(
                                                    markers: <Marker>[
                                                      Marker(
                                                        point:
                                                            _selectedLocation,
                                                        width: 46,
                                                        height: 46,
                                                        child: const Icon(
                                                          Icons.location_on,
                                                          size: 42,
                                                          color: Color(
                                                            0xFF16A34A,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Toque no mapa para ajustar a localização.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          if (_loadingAddress) ...<Widget>[
                                            const Text(
                                              'A obter morada...',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ] else ...<Widget>[
                                            if (_street != null &&
                                                _street!
                                                    .isNotEmpty) ...<Widget>[
                                              const Text(
                                                'Rua:',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _street!,
                                                style: const TextStyle(
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                            ],
                                            if (_city != null &&
                                                _city!.isNotEmpty) ...<Widget>[
                                              const SizedBox(height: 12),
                                              const Text(
                                                'Cidade:',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _city!,
                                                style: const TextStyle(
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                            ],
                                            if (_country != null &&
                                                _country!
                                                    .isNotEmpty) ...<Widget>[
                                              const SizedBox(height: 12),
                                              const Text(
                                                'País:',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _country!,
                                                style: const TextStyle(
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                            ],
                                            if (_error.isNotEmpty) ...<Widget>[
                                              const SizedBox(height: 12),
                                              Text(
                                                _error,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: PrimaryButton(
                                        label: 'Confirmar localização',
                                        onPressed: _confirmLocation,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
