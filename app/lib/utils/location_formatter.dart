import 'package:geocoding/geocoding.dart';

String? buildAddressFromPlacemark(Placemark? place) {
  final address = place?.street?.trim() ?? '';
  final number = place?.subThoroughfare?.trim() ?? '';

  if (address.isEmpty && number.isEmpty) return null;
  if (address.isEmpty) return number;
  if (number.isEmpty) return address;

  final alreadyHasNumber = address.contains(
    RegExp(r'(^|[\s,])' + RegExp.escape(number) + r'($|[\s,])'),
  );

  if (alreadyHasNumber) return address;

  return '$address, $number';
}

String? buildCityFromPlacemark(Placemark? place) {
  final candidates =
      <String?>[
            place?.locality,
            place?.subAdministrativeArea,
            place?.administrativeArea,
          ]
          .where((value) => value != null && value.trim().isNotEmpty)
          .cast<String>()
          .toList();

  return candidates.isEmpty ? null : candidates.first.trim();
}

String? buildCountryFromPlacemark(Placemark? place) {
  final country = place?.country?.trim() ?? '';
  return country.isEmpty ? null : country;
}
