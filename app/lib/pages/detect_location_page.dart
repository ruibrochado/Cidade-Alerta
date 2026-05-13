import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/report_data.dart';
import '../widgets/primary_button.dart';
import '../utils/location_formatter.dart';

class DetectLocationPage extends StatefulWidget {
  const DetectLocationPage({super.key, required this.report});

  final ReportData report;

  @override
  State<DetectLocationPage> createState() => _DetectLocationPageState();
}

class _DetectLocationPageState extends State<DetectLocationPage> {
  bool _detecting = true;
  String _error = '';
  double? _latitude;
  double? _longitude;

  String? _address;
  String? _city;
  String? _country;

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    setState(() {
      _detecting = true;
      _error = '';
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
          'Permissão de localização negada permanentemente. Ative-a nas definições do dispositivo.',
        );
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final Placemark? place = placemarks.isNotEmpty ? placemarks.first : null;

      final String? address = buildAddressFromPlacemark(place);
      final String? city = buildCityFromPlacemark(place);
      final String? country = buildCountryFromPlacemark(place);

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _address = address;
        _city = city;
        _country = country;
        _detecting = false;
        _error = '';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _latitude = null;
        _longitude = null;
        _address = null;
        _city = null;
        _country = null;
        _detecting = false;
      });
    }
  }

  void _handleContinue() {
    final bool hasLocation = _latitude != null && _longitude != null;

    if (!hasLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível obter a sua localização. Escolha no mapa.',
          ),
        ),
      );
    }

    Navigator.pushNamed(
      context,
      '/adjust-location',
      arguments: widget.report.copyWith(
        latitude: _latitude,
        longitude: _longitude,
        address: _address,
        city: _city,
        country: _country,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color headerGreen = Color(0xFFCDE5CB);

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
                          'Localização',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Detectando sua localização',
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
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 8),
                          Container(
                            width: 96,
                            height: 96,
                            decoration: const BoxDecoration(
                              color: Color(0xFFDCFCE7),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: _detecting
                                  ? const SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Color(0xFF16A34A),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.location_on,
                                      size: 42,
                                      color: Color(0xFF16A34A),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_detecting)
                            const Text(
                              'Detectando sua localização...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF4B5563),
                              ),
                            )
                          else if (_error.isNotEmpty)
                            Column(
                              children: <Widget>[
                                const Text(
                                  'Não foi possível obter sua localização',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _error,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Usando escolha manual no mapa',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            )
                          else
                            const Text(
                              'Localização detectada!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          if (_latitude != null &&
                              _longitude != null) ...<Widget>[
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  if (_address != null &&
                                      _address!.isNotEmpty) ...<Widget>[
                                    const Text(
                                      'Rua:',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _address!,
                                      style: const TextStyle(
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                  ],
                                  if (_city != null &&
                                      _city!.isNotEmpty) ...<Widget>[
                                    if (_address != null &&
                                        _address!.isNotEmpty)
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
                                      _country!.isNotEmpty) ...<Widget>[
                                    if ((_address != null &&
                                            _address!.isNotEmpty) ||
                                        (_city != null && _city!.isNotEmpty))
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
                                ],
                              ),
                            ),
                          ],
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: PrimaryButton(
                              label: _latitude != null && _longitude != null
                                  ? 'Continuar'
                                  : 'Escolher no mapa',
                              enabled: !_detecting,
                              onPressed: _handleContinue,
                            ),
                          ),
                        ],
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
