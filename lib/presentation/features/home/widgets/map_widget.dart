// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/services/location_service.dart';
import '../../../../data/models/trip.dart';
import '../../../../data/providers/trip_provider.dart';

class TripsMap extends StatefulWidget {
  final Function(int)? onTripsCountChanged;
  final List<Trip>? availableTrips;
  
  const TripsMap({super.key, this.onTripsCountChanged, this.availableTrips});

  @override
  State<TripsMap> createState() => _TripsMapState();
}

class _TripsMapState extends State<TripsMap> with TickerProviderStateMixin {
  late final AnimatedMapController _mapController = AnimatedMapController(
    vsync: this,
  );

  LatLng? _currentLocation;
  List<Marker> _markers = [];
  List<Trip> _availableTrips = [];
  bool _loading = true;
  final double _zoomLevel = 16.0;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _init();
    // Start real-time location updates
    _startLocationUpdates();
  }

  @override
  void didUpdateWidget(TripsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if available trips changed
    if (widget.availableTrips != oldWidget.availableTrips) {
      if (_currentLocation != null) {
        _fetchTrips(_currentLocation!.latitude, _currentLocation!.longitude);
      }
    }
  }

  void _startLocationUpdates() {
    // Update location every 15 seconds for map
    Stream.periodic(const Duration(seconds: 15)).listen((_) {
      if (mounted) {
        _updateCurrentLocation();
      }
    });
  }

  Future<void> _updateCurrentLocation() async {
    try {
      final pos = await LocationService.getCurrentLocation();
      final userLocation = LatLng(pos.latitude, pos.longitude);
      
      if (mounted && _currentLocation != userLocation) {
        setState(() {
          _currentLocation = userLocation;
        });
      }
    } catch (e) {
      // Handle location update errors silently
    }
  }

  Future<void> _init() async {
    try {
      final pos = await LocationService.getCurrentLocation();
      final userLocation = LatLng(pos.latitude, pos.longitude);

      setState(() => _currentLocation = userLocation);

      await _fetchTrips(pos.latitude, pos.longitude);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (_currentLocation != null) {
            _animateTo(_currentLocation!, _zoomLevel);
          }
        });
      });
    } catch (e) {
      // Handle location errors silently
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchTrips(double lat, double lon) async {
    if (!mounted) return;
    
    if (widget.availableTrips != null) {
      _availableTrips = widget.availableTrips!;
    } else {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      final allTrips = tripProvider.activeTrips;
      
      if (currentUserId == null) {
        _availableTrips = [];
      } else {
        _availableTrips = allTrips.where((trip) {

          if (trip.joinedUsers.contains(currentUserId)) return false; 
          return trip.status == TripStatus.active;
        }).toList();
      }
    }
    


    setState(() {
      _markers = _availableTrips.map((trip) {
        double tripLat, tripLng;
        if (trip.currentLat != null && trip.currentLng != null &&
            trip.currentLat != 0.0 && trip.currentLng != 0.0) {
          tripLat = trip.currentLat!;
          tripLng = trip.currentLng!;
        } else {
          final index = _availableTrips.indexOf(trip);
          final angle = (index * 2 * 3.14159) / _availableTrips.length; 
          final radius = 0.005; 
          tripLat = lat + (radius * math.cos(angle));
          tripLng = lon + (radius * math.sin(angle));
        }
        
        final isOwnTrip = trip.createdBy == currentUserId;
        
        return Marker(
          width: 120,
          height: 90,
          point: LatLng(tripLat, tripLng),
          child: SizedBox(
            width: 120,
            height: 90,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: isOwnTrip ? Colors.blue.withOpacity(0.6) : Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: isOwnTrip ? Colors.blue.withOpacity(0.3) : AppColors.primaryYellow.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOwnTrip ? Colors.blue.withOpacity(0.9) : AppColors.primaryYellow.withOpacity(0.9),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '🛺',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isOwnTrip ? Colors.blue : AppColors.primaryYellow,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: isOwnTrip ? Colors.blue.withOpacity(0.4) : AppColors.primaryYellow.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  isOwnTrip ? 'You' : (trip.creatorName.isNotEmpty 
                    ? trip.creatorName.split(' ').first 
                    : 'Driver'), 
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            ),
          ),
        );
      }).toList();
    });

    if (widget.onTripsCountChanged != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onTripsCountChanged!(_availableTrips.length);
        }
      });
    }
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
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground,
              AppColors.cardBackground,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryYellow,
                ),
                strokeWidth: 3,
              ),
              SizedBox(height: 24),
              Text(
                "Loading map...",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentLocation == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground,
              AppColors.cardBackground,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                color: AppColors.accentRed,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                "Unable to fetch location",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Please enable location services",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Main Map
        ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: FlutterMap(
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
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.example.hopin',
                retinaMode: RetinaMode.isHighDensity(context),
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  // Current Location Marker (Enhanced)
                  Marker(
                    width: 60,
                    height: 60,
                    point: _currentLocation!,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulse animation background
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryYellow.withOpacity(0.3),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryYellow.withOpacity(0.6),
                          ),
                        ),
                        // Main marker
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryYellow,
                            border: Border.all(
                              color: AppColors.darkBackground,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryYellow.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.black,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._markers.map((marker) => Marker(
                    width: 48,
                    height: 48,
                    point: marker.point,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        // decoration: BoxDecoration(
                        //   shape: BoxShape.circle,
                        //   color: const Color.fromARGB(108, 48, 255, 7).withOpacity(0.9),
                        //   border: Border.all(
                        //     color: Colors.white.withOpacity(0.4),
                        //     width: 1,
                        //   ),
                        // ),
                        child: const Center(
                          child: Text(
                            '🛺',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),

        // Lighter overlay for better visibility
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.05),
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),



      ],
    );
  }


}
