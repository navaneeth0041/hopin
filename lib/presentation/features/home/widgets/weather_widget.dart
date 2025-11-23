import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hopin/core/constants/app_colors.dart';
import '../../../../data/services/weather_service.dart';

class WeatherWidget extends StatefulWidget {
  final Position? userLocation;

  const WeatherWidget({
    super.key,
    this.userLocation,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.userLocation != null) {
      _fetchWeather();
    }
  }

  @override
  void didUpdateWidget(WeatherWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userLocation != oldWidget.userLocation && widget.userLocation != null) {
      _fetchWeather();
    }
  }

  Future<void> _fetchWeather() async {
    if (widget.userLocation == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weatherData = await WeatherService.getWeatherData(widget.userLocation!);
      
      if (weatherData != null) {
        setState(() {
          _weatherData = weatherData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = WeatherService.isApiKeyConfigured 
            ? 'Failed to load weather data'
            : 'Weather service unavailable';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Weather service unavailable';
        _isLoading = false;
      });
    }
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'partly cloudy':
        return Icons.wb_cloudy;
      case 'mostly cloudy':
      case 'cloudy':
        return Icons.cloud;
      case 'humid':
        return Icons.water_drop;
      case 'light rain':
        return Icons.grain;
      case 'shower':
      case 'heavy shower':
      case 'rain':
        return Icons.umbrella;
      case 'light snow':
      case 'snow':
      case 'rain/snow':
        return Icons.ac_unit;
      case 'thunderstorm':
      case 'thunderstorm/rain':
        return Icons.flash_on;
      default:
        return Icons.wb_sunny;
    }
  }

  Color _getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Colors.orange;
      case 'partly cloudy':
        return Colors.amber;
      case 'mostly cloudy':
      case 'cloudy':
        return Colors.grey;
      case 'humid':
        return Colors.teal;
      case 'light rain':
        return Colors.lightBlue;
      case 'shower':
      case 'heavy shower':
      case 'rain':
        return Colors.blue;
      case 'light snow':
      case 'snow':
      case 'rain/snow':
        return Colors.lightBlue;
      case 'thunderstorm':
      case 'thunderstorm/rain':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }



  Widget _buildSimpleWeatherCard({
    required IconData icon,
    required String value,
    required String label,
    bool isCondition = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.04),
            Colors.white.withOpacity(0.01),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.7),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            isCondition ? value.split(' ').first : value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userLocation == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.06),
              Colors.white.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_off,
              color: Colors.orange.withOpacity(0.7),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Location Required',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Enable location access to see weather info',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.06),
              Colors.white.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryYellow,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Loading Weather',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Getting current conditions...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null || _weatherData == null) {
      return const SizedBox.shrink();
    }

    final weatherColor = _getWeatherColor(_weatherData!.condition);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.06),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.primaryYellow,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _weatherData!.location,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: weatherColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getWeatherIcon(_weatherData!.condition),
                  color: weatherColor,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_weatherData!.temperature.round()}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _weatherData!.condition,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: _buildSimpleWeatherCard(
                  icon: Icons.water_drop,
                  value: '${_weatherData!.humidity}%',
                  label: 'Humidity',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSimpleWeatherCard(
                  icon: Icons.air,
                  value: '${_weatherData!.windSpeed.toStringAsFixed(1)} m/s',
                  label: 'Wind',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSimpleWeatherCard(
                  icon: _getWeatherIcon(_weatherData!.condition),
                  value: _weatherData!.condition,
                  label: 'Condition',
                  isCondition: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}