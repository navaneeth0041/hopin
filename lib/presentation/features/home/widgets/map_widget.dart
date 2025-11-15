import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import '../../../../data/services/location_service.dart';

class TripsMap extends StatefulWidget {
  const TripsMap({super.key});

  @override
  State<TripsMap> createState() => _TripsMapState();
}

class _TripsMapState extends State<TripsMap> with TickerProviderStateMixin {
  late final AnimatedMapController _mapController = AnimatedMapController(
    vsync: this,
  );

  LatLng? _currentLocation;
  List<Marker> _markers = [];
  bool _loading = true;
  final double _zoomLevel = 16.0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final pos = await LocationService.getCurrentLocation();
      final userLocation = LatLng(pos.latitude, pos.longitude);

      setState(() => _currentLocation = userLocation);
      debugPrint(
        "Current Location: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}",
      );

      await _fetchTrips(pos.latitude, pos.longitude);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (_currentLocation != null) {
            _animateTo(_currentLocation!, _zoomLevel);
          }
        });
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchTrips(double lat, double lon) async {
    final trips = [
      {"lat": lat + 0.01, "lon": lon + 0.01},
      {"lat": lat - 0.01, "lon": lon - 0.01},
      {"lat": lat + 0.015, "lon": lon - 0.005},
    ];

    setState(() {
      _markers = trips
          .map(
            (trip) => Marker(
              width: 60,
              height: 60,
              point: LatLng(trip["lat"]!, trip["lon"]!),
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 35,
              ),
            ),
          )
          .toList();
    });
  }

  void _animateTo(LatLng dest, double zoom) {
    _mapController.animateTo(
      dest: dest,
      zoom: zoom,
      rotation: 0,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 800),
    );
  }

  // void _updateZoom(double newZoom) {
  //   if (_currentLocation == null) return;
  //   setState(() => _zoomLevel = newZoom.clamp(3.0, 22.0));
  //   _animateTo(_currentLocation!, _zoomLevel);
  // }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentLocation == null) {
      return const Center(
        child: Text(
          "Unable to fetch location",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController.mapController,
          options: MapOptions(
            initialCenter: _currentLocation!,
            initialZoom: _zoomLevel,
            minZoom: 10,
            maxZoom: 22,
            onMapReady: () => _animateTo(_currentLocation!, _zoomLevel),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              userAgentPackageName: 'com.example.hopin',
              retinaMode: RetinaMode.isHighDensity(context),
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 35,
                  height: 35,
                  point: _currentLocation!,
                  child: Image.asset(
                    "assets/images/person_pin.png",
                    width: 20,
                    height: 20,
                  ),
                ),
                ..._markers,
              ],
            ),
            IgnorePointer(
              child: Container(
                color: const Color.fromARGB(
                  255,
                  255,
                  255,
                  255,
                ).withOpacity(0.20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
