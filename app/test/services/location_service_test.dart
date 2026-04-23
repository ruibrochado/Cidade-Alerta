import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:app/services/location_service.dart';

class MockLocationWrapper extends Mock implements LocationWrapper {}

class FakePosition extends Fake implements Position {
  @override
  final double latitude;
  @override
  final double longitude;

  FakePosition({required this.latitude, required this.longitude});
}

void main() {
  group('LocationService Tests', () {
    late LocationService locationService;
    late MockLocationWrapper mockWrapper;

    setUp(() {
      mockWrapper = MockLocationWrapper();
      locationService = LocationService(locationWrapper: mockWrapper);
    });

    test('Should throw exception if location services are disabled', () async {
      when(
        () => mockWrapper.isLocationServiceEnabled(),
      ).thenAnswer((_) async => false);

      await expectLater(
        locationService.detectLocation(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Os serviços de localização estão desativados.'),
          ),
        ),
      );
    });

    test(
      'Should throw exception if permission is permanently denied',
      () async {
        when(
          () => mockWrapper.isLocationServiceEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => mockWrapper.checkPermission(),
        ).thenAnswer((_) async => LocationPermission.deniedForever);

        await expectLater(
          locationService.detectLocation(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Permissão de localização negada permanentemente.'),
            ),
          ),
        );
      },
    );

    test(
      'Should request permission if initially denied and throw if denied again',
      () async {
        when(
          () => mockWrapper.isLocationServiceEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => mockWrapper.checkPermission(),
        ).thenAnswer((_) async => LocationPermission.denied);
        when(
          () => mockWrapper.requestPermission(),
        ).thenAnswer((_) async => LocationPermission.denied);

        await expectLater(
          locationService.detectLocation(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Permissão de localização negada.'),
            ),
          ),
        );

        verify(() => mockWrapper.requestPermission()).called(1);
      },
    );

    test(
      'Should return correct location data on successful geocoding',
      () async {
        when(
          () => mockWrapper.isLocationServiceEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => mockWrapper.checkPermission(),
        ).thenAnswer((_) async => LocationPermission.whileInUse);

        final fakePos = FakePosition(latitude: 41.1496, longitude: -8.6109);
        when(
          () => mockWrapper.getCurrentPosition(),
        ).thenAnswer((_) async => fakePos);

        final placemark = Placemark(
          street: 'Avenida dos Aliados',
          locality: 'Porto',
          country: 'Portugal',
        );
        when(
          () => mockWrapper.getPlacemarks(41.1496, -8.6109),
        ).thenAnswer((_) async => [placemark]);

        final result = await locationService.detectLocation();

        expect(result['latitude'], 41.1496);
        expect(result['longitude'], -8.6109);
        expect(result['street'], 'Avenida dos Aliados');
        expect(result['city'], 'Porto');
        expect(result['country'], 'Portugal');
      },
    );

    test('Should handle empty placemarks gracefully', () async {
      when(
        () => mockWrapper.isLocationServiceEnabled(),
      ).thenAnswer((_) async => true);
      when(
        () => mockWrapper.checkPermission(),
      ).thenAnswer((_) async => LocationPermission.always);

      final fakePos = FakePosition(latitude: 38.7223, longitude: -9.1393);
      when(
        () => mockWrapper.getCurrentPosition(),
      ).thenAnswer((_) async => fakePos);

      when(
        () => mockWrapper.getPlacemarks(38.7223, -9.1393),
      ).thenAnswer((_) async => []);

      final result = await locationService.detectLocation();

      expect(result['latitude'], 38.7223);
      expect(result['longitude'], -9.1393);
      expect(result['street'], isNull);
      expect(result['city'], isNull);
      expect(result['country'], isNull);
    });
  });
}
