/*import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/report_data.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';

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

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('Não foi possível obter sua localização');
      }

      final Position position = await Geolocator.getCurrentPosition();
      if (!mounted) {
        return;
      }

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _detecting = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = 'Não foi possível obter sua localização';
        _latitude = 38.7223;
        _longitude = -9.1393;
        _detecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Localização',
      subtitle: 'Detectando sua localização',
      showBackButton: true,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),
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
                      child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF16A34A)),
                    )
                  : const Icon(Icons.location_on, size: 42, color: Color(0xFF16A34A)),
            ),
          ),
          const SizedBox(height: 24),
          if (_detecting)
            const Text(
              'Detectando sua localização...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF4B5563)),
            )
          else if (_error.isNotEmpty)
            const Column(
              children: <Widget>[
                Text(
                  'Não foi possível obter sua localização',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 6),
                Text(
                  'Usando localização padrão',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ],
            )
          else
            const Text(
              'Localização detectada!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF16A34A)),
            ),
          if (_latitude != null && _longitude != null) ...<Widget>[
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
                  const Text('Coordenadas:', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  const SizedBox(height: 4),
                  Text(
                    '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                    style: const TextStyle(fontFamily: 'monospace', color: Color(0xFF1F2937)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Continuar',
            enabled: !_detecting && _latitude != null && _longitude != null,
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/adjust-location',
                arguments: widget.report.copyWith(latitude: _latitude, longitude: _longitude),
              );
            },
          ),
        ],
      ),
    );
  }
}
*/