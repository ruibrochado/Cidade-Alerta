import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

import '../models/report_data.dart';
import '../pages/report_detail_page.dart';
import '../services/issue_service.dart';

class MapPage extends StatefulWidget {
  final IssueService? issueService;

  const MapPage({super.key, this.issueService});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final IssueService _issueService;
  final MapController _mapController = MapController();

  LatLng? _currentLocation;
  List<Map<String, dynamic>> _issues = [];
  bool _isLoading = true;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _issueService = widget.issueService ?? IssueService();
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
    // Initial issue fetch runs after the map has rendered and
    // _mapController.camera is available, so we wait one frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchIssuesByCurrentBounds();
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

  /// Called whenever the map camera moves. Debounced by 400 ms to avoid
  /// hammering the database while the user is still panning or zooming.
  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchIssuesByCurrentBounds();
    });
  }

  Future<void> _fetchIssuesByCurrentBounds() async {
    try {
      final bounds = _mapController.camera.visibleBounds;
      final issues = await _issueService.fetchIssuesByBounds(
        minLat: bounds.south,
        maxLat: bounds.north,
        minLng: bounds.west,
        maxLng: bounds.east,
      );
      if (!mounted) return;
      setState(() => _issues = issues);
    } catch (_) {
      // Silently fail — map still works without issue markers
    }
  }

  void _openReportDetails(Map<String, dynamic> issue) {
    final report = ReportData.fromMap(issue);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        maxWidth: double.infinity,
      ),
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.88,
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ReportDetailSheet(report: report),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _openReportDetails(issue),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.report_problem,
                color: Colors.red,
                size: 24,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final String stadiaApiKey = dotenv.env['STADIA_MAPS_API_KEY'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
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
          : FlutterMap(
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
                    // Issue markers (red)
                    ..._buildIssueMarkers(),
                    // User location marker (blue)
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
