import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class AddressResult {
  const AddressResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
  final String displayName;
  final double latitude;
  final double longitude;
  LatLng get point => LatLng(latitude, longitude);
}

class GpsService {
  static Future<Position> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError(
        'Location services are turned off. Enable GPS and try again.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw StateError('Location permission was denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw StateError(
        'Location permission is permanently denied. Open device settings to allow it.',
      );
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 20),
    );
  }

  static Stream<Position> positionStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }

  static Future<AddressResult> geocodeAddress(String address) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) throw ArgumentError('Enter a customer address.');

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': trimmed,
      'format': 'jsonv2',
      'limit': '1',
      'countrycodes': 'us',
      'addressdetails': '1',
    });

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'JiffyRoadsidePhase4/4.1 (313-952-5266)',
          },
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw StateError(
        'Address lookup failed with code ${response.statusCode}.',
      );
    }

    final data = jsonDecode(response.body);
    if (data is! List || data.isEmpty) {
      throw StateError(
        'No map location was found for that address. Add the city, state, and ZIP code.',
      );
    }

    final first = data.first as Map<String, dynamic>;
    final lat = double.tryParse(first['lat']?.toString() ?? '');
    final lon = double.tryParse(first['lon']?.toString() ?? '');
    if (lat == null || lon == null)
      throw StateError('The map service returned invalid coordinates.');

    return AddressResult(
      displayName: first['display_name']?.toString() ?? trimmed,
      latitude: lat,
      longitude: lon,
    );
  }

  static Future<void> openNavigation({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final destination =
        '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw StateError('Could not open navigation.');
    }
  }
}
