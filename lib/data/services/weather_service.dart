import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  static Future<WeatherData?> getWeatherData(Position location) async {
    try {
      final locationName = await _getLocationName(location);
      final apiUrl = '$_baseUrl?latitude=${location.latitude}&longitude=${location.longitude}&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&timezone=auto';
      
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromOpenMeteo(data, locationName);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String> _getLocationName(Position location) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${location.latitude}&longitude=${location.longitude}&localityLanguage=en'),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final city = data['city'] ?? data['locality'] ?? '';
        final countryCode = data['countryCode'] ?? '';
        
        if (city.isNotEmpty && countryCode.isNotEmpty) {
          return '$city, $countryCode';
        } else if (city.isNotEmpty) {
          return city;
        }
      }
    } catch (e) {}

    return '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}';
  }

  static bool get isApiKeyConfigured => true;
}

class WeatherData {
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String condition;
  final String description;
  final String location;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.description,
    required this.location,
  });

  factory WeatherData.fromOpenMeteo(Map<String, dynamic> json, String location) {
    final current = json['current'] as Map<String, dynamic>;
    
    final temperature = current['temperature_2m']?.toDouble() ?? 20.0;
    final humidity = current['relative_humidity_2m']?.toInt() ?? 50;
    final windSpeed = current['wind_speed_10m']?.toDouble() ?? 0.0;
    final weatherCode = current['weather_code']?.toInt() ?? 0;
    
    return WeatherData(
      temperature: temperature,
      humidity: humidity,
      windSpeed: windSpeed,
      condition: _mapOpenMeteoWeatherCode(weatherCode),
      description: _getOpenMeteoWeatherDescription(weatherCode),
      location: location,
    );
  }

  static String _mapOpenMeteoWeatherCode(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Clear';
      case 1:
      case 2:
      case 3:
        return 'Partly Cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 56:
      case 57:
        return 'Freezing Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 66:
      case 67:
        return 'Freezing Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 77:
        return 'Snow Grains';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 85:
      case 86:
        return 'Snow Showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Clear';
    }
  }
  static String _getOpenMeteoWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
        return 'Fog';
      case 48:
        return 'Depositing rime fog';
      case 51:
        return 'Light drizzle';
      case 53:
        return 'Moderate drizzle';
      case 55:
        return 'Dense drizzle';
      case 56:
        return 'Light freezing drizzle';
      case 57:
        return 'Dense freezing drizzle';
      case 61:
        return 'Slight rain';
      case 63:
        return 'Moderate rain';
      case 65:
        return 'Heavy rain';
      case 66:
        return 'Light freezing rain';
      case 67:
        return 'Heavy freezing rain';
      case 71:
        return 'Slight snow fall';
      case 73:
        return 'Moderate snow fall';
      case 75:
        return 'Heavy snow fall';
      case 77:
        return 'Snow grains';
      case 80:
        return 'Slight rain showers';
      case 81:
        return 'Moderate rain showers';
      case 82:
        return 'Violent rain showers';
      case 85:
        return 'Slight snow showers';
      case 86:
        return 'Heavy snow showers';
      case 95:
        return 'Thunderstorm';
      case 96:
        return 'Thunderstorm';
      case 99:
        return 'Thunderstorm';
      default:
        return 'Clear sky';
    }
  }
}
