import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

import '../models/report_data.dart';
import '../services/issue_service.dart';
import '../pages/report_detail_page.dart';

import '../models/ecocenter_data.dart';
import '../services/ecocenter_service.dart';
import '../pages/ecocenter_detail_page.dart'; // Mantém o teu nome limpo!

class MapPage extends StatefulWidget {
  final IssueService? issueService;

  const MapPage({super.key, this.issueService});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final IssueService _issueService;
  late final EcocenterService _ecocenterService;

  final MapController _mapController = MapController();

  LatLng? _currentLocation;
  List<Map<String, dynamic>> _issues = [];
  List<EcocenterData> _ecocenters = [];
  bool _isLoading = true;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _issueService = widget.issueService ?? IssueService();
    _ecocenterService = EcocenterService();
    _loadMapData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadMapData() async {
    await _getUserLocation();
    if (mounted) {
      setState(() => _isLoading = false);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMapData();
    });
  }

  Future<void> _getUserLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização desativado.');
      }

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

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;
      setState(
        () => _currentLocation = LatLng(position.latitude, position.longitude),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _currentLocation = const LatLng(38.7223, -9.1393));
    }
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchMapData();
    });
  }

  Future<void> _fetchMapData() async {
    try {
      final bounds = _mapController.camera.visibleBounds;

      final issuesFuture = _issueService.fetchIssuesByBounds(
        minLat: bounds.south,
        maxLat: bounds.north,
        minLng: bounds.west,
        maxLng: bounds.east,
      );

      final ecocentersFuture = _ecocenterService.fetchEcocentersByBounds(
        minLat: bounds.south,
        maxLat: bounds.north,
        minLng: bounds.west,
        maxLng: bounds.east,
      );

      final results = await Future.wait([issuesFuture, ecocentersFuture]);

      if (!mounted) return;
      setState(() {
        _issues = results[0] as List<Map<String, dynamic>>;
        _ecocenters = results[1] as List<EcocenterData>;
      });
    } catch (e) {
      debugPrint("Erro a carregar dados do mapa: $e");
    }
  }

  void _openReportDetails(Map<String, dynamic> issue) {
    final report = ReportData.fromMap(issue);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildBottomSheetContainer(ReportDetailSheet(report: report));
      },
    );
  }

  void _openEcocenterDetails(EcocenterData ecocenter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // Usa o MESMO contentor que a denúncia, mas passa-lhe a EcocenterDetailPage
        return _buildBottomSheetContainer(
          EcocenterDetailPage(ecocenter: ecocenter),
          heightRatio:
              0.75, // Ajustei um bocadinho a altura porque não tem comentários
        );
      },
    );
  }

  Widget _buildBottomSheetContainer(Widget child, {double heightRatio = 0.88}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Container(
        height: MediaQuery.of(context).size.height * heightRatio,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildIssueMarkers() {
    final List<Marker> markers = [];
    for (final issue in _issues) {
      final lat = (issue['latitude'] as num?)?.toDouble();
      final lng = (issue['longitude'] as num?)?.toDouble();

      if (lat == null || lng == null) continue;

      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: 44,
          height: 52,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            key: const Key('issue_marker'),
            onTap: () => _openReportDetails(issue),
            child: const _IssuePin(),
          ),
        ),
      );
    }
    return markers;
  }

  List<Marker> _buildEcocenterMarkers() {
    return _ecocenters.map((eco) {
      return Marker(
        point: LatLng(eco.latitude, eco.longitude),
        width: 44,
        height: 52,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => _openEcocenterDetails(eco),
          child: const _EcocenterPin(),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final String stadiaApiKey = dotenv.env['STADIA_MAPS_API_KEY'] ?? '';

    return Scaffold(
      body: _isLoading
          ? const Center(
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
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation!,
                    initialZoom: 15,
                    onPositionChanged: _onMapPositionChanged,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key=$stadiaApiKey',
                      userAgentPackageName: 'com.example.app',
                      retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
                    ),
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
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 60,
                        size: const Size(44, 44),
                        alignment: Alignment.bottomCenter,
                        markers: _buildIssueMarkers(),
                        builder: (context, markers) =>
                            _buildCluster(markers, const Color(0xFFEF4444)),
                      ),
                    ),
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 60,
                        size: const Size(44, 44),
                        alignment: Alignment.bottomCenter,
                        markers: _buildEcocenterMarkers(),
                        builder: (context, markers) =>
                            _buildCluster(markers, const Color(0xFF16A34A)),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: _RecenterButton(
                    onTap: () {
                      if (_currentLocation != null) {
                        _mapController.move(_currentLocation!, 15);
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCluster(List<Marker> markers, Color color) {
    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        markers.length.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// PIN VERMELHO (Issues)
class _IssuePin extends StatelessWidget {
  const _IssuePin();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(44, 52),
      painter: _PinPainter(const Color(0xFFEF4444), isIssue: true),
    );
  }
}

// PIN VERDE (Ecocentros) - BEM CENTRADO
class _EcocenterPin extends StatelessWidget {
  const _EcocenterPin();
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(44, 52),
          painter: _PinPainter(const Color(0xFF16A34A)),
        ),
        const Positioned(
          top: 11, // Centrado perfeitamente na bola!
          child: Icon(Icons.recycling, color: Colors.white, size: 22),
        ),
      ],
    );
  }
}

class _PinPainter extends CustomPainter {
  final Color color;
  final bool isIssue;
  _PinPainter(this.color, {this.isIssue = false});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double r = w / 2;
    final paint = Paint()..color = color;

    canvas.drawOval(Rect.fromCircle(center: Offset(cx, r), radius: r), paint);
    final tipPath = Path()
      ..moveTo(cx - r * 0.52, r + r * 0.45)
      ..lineTo(cx, h)
      ..lineTo(cx + r * 0.52, r + r * 0.45)
      ..close();
    canvas.drawPath(tipPath, paint);

    if (isIssue) {
      final triPath = Path()
        ..moveTo(cx, r - r * 0.40)
        ..lineTo(cx - r * 0.36, r + r * 0.26)
        ..lineTo(cx + r * 0.36, r + r * 0.26)
        ..close();
      canvas.drawPath(triPath, Paint()..color = Colors.white);
      final excl = Paint()..color = color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - r * 0.065, r - r * 0.26, r * 0.13, r * 0.32),
          const Radius.circular(2),
        ),
        excl,
      );
      canvas.drawCircle(Offset(cx, r + r * 0.14), r * 0.075, excl);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RecenterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RecenterButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.my_location,
          color: Color(0xFF16A34A),
          size: 24,
        ),
      ),
    );
  }
}
