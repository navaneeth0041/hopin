import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static Future<String> getAddressFromCoordinates(
    double lat,
    double lng,
  ) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?'
        'format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'HopInApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          String locationName = '';

          if (address['road'] != null) {
            locationName = address['road'];
          } else if (address['building'] != null) {
            locationName = address['building'];
          } else if (address['suburb'] != null) {
            locationName = address['suburb'];
          } else if (address['neighbourhood'] != null) {
            locationName = address['neighbourhood'];
          } else if (address['city'] != null) {
            locationName = address['city'];
          }

          if (locationName.isNotEmpty &&
              address['city'] != null &&
              !locationName.contains(address['city'])) {
            locationName += ', ${address['city']}';
          }

          if (locationName.isNotEmpty) {
            return locationName;
          }
        }

        if (data['display_name'] != null) {
          final parts = (data['display_name'] as String).split(',');
          if (parts.length >= 2) {
            return '${parts[0].trim()}, ${parts[1].trim()}';
          }
          return parts[0].trim();
        }
      }

      return 'Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
    } catch (e) {
      print('Geocoding error: $e');
      return 'Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
    }
  }

  static Future<List<SearchResult>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'format=json&q=$query&limit=10&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'HopInApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => SearchResult.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }
}

class SearchResult {
  final String displayName;
  final double lat;
  final double lon;
  final String type;

  SearchResult({
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.type,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      displayName: json['display_name'] ?? '',
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      type: json['type'] ?? '',
    );
  }

  LatLng get location => LatLng(lat, lon);
}
