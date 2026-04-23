import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationWrapper {
  Future<bool> isLocationServiceEnabled() => Geolocator.isLocationServiceEnabled();

  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  Future<LocationPermission> requestPermission() => Geolocator.requestPermission();

  Future<Position> getCurrentPosition() => Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

  Future<List<Placemark>> getPlacemarks(double lat, double lng) =>
      placemarkFromCoordinates(lat, lng);
}

class LocationService {
  final LocationWrapper wrapper;

  LocationService({LocationWrapper? locationWrapper})
      : wrapper = locationWrapper ?? LocationWrapper();

  Future<Map<String, dynamic>> detectLocation() async {
    final bool serviceEnabled = await wrapper.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Os serviços de localização estão desativados.');
    }

    LocationPermission permission = await wrapper.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await wrapper.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Permissão de localização negada.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão de localização negada permanentemente. Ative-a nas definições do dispositivo.',
      );
    }

    final Position position = await wrapper.getCurrentPosition();
    final List<Placemark> placemarks = await wrapper.getPlacemarks(
      position.latitude,
      position.longitude,
    );

    final Placemark? place = placemarks.isNotEmpty ? placemarks.first : null;

    final String street = <String?>[place?.street, place?.subThoroughfare]
        .where((String? value) => value != null && value.trim().isNotEmpty)
        .cast<String>()
        .join(', ');

    final List<String> cityCandidates = <String?>[
      place?.locality,
      place?.subAdministrativeArea,
      place?.administrativeArea,
    ].where((String? value) => value != null && value.trim().isNotEmpty).cast<String>().toList();

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'street': street.isEmpty ? null : street,
      'city': cityCandidates.isEmpty ? null : cityCandidates.first,
      'country': place?.country,
    };
  }
}