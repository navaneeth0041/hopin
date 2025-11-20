// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/presentation/features/home/widgets/payment_notification_banner.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../widgets/home_header.dart';
import '../widgets/quick_action_buttons.dart';
import '../widgets/active_trips_section.dart';
import '../widgets/map_widget.dart';
import '../widgets/nearby_trips_section.dart';
import '../services/trip_filter_service.dart';
import '../../../../data/providers/trip_provider.dart';
import '../../../../data/models/trip.dart';
import '../../../../data/services/location_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Trip> _availableTrips = [];
  String _personalizedMessage = 'Searching for trips in your area...';
  Position? _userLocation;
  bool _isLoadingLocation = true;
  int _lastLogTime = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrips();
      _getUserLocation();
      _updateTripsData();
    });
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    tripProvider.addListener(() {
      if (!mounted) return;
      _updateTripsData();
    });
  }

  void _updateTripsData() {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final newAvailableTrips = TripFilterService.filterAvailableTrips(
      tripProvider.activeTrips,
      _userLocation,
      lastLogTime: _lastLogTime,
    );
    final newPersonalizedMessage = TripFilterService.getPersonalizedTripMessage(
      tripProvider.activeTrips,
      _userLocation,
    );

    setState(() {
      _availableTrips = newAvailableTrips;
      _personalizedMessage = newPersonalizedMessage;
    });
  }

  void _loadTrips() {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    tripProvider.loadActiveTrips();
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      setState(() {
        _userLocation = position;
        _isLoadingLocation = false;
      });
      _updateTripsData();
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _onTripsCountChanged(int count) {}

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 17, 17, 17),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: screenHeight * 0.65,
                floating: false,
                pinned: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Positioned.fill(
                        child: TripsMap(
                          onTripsCountChanged: _onTripsCountChanged,
                          availableTrips: _availableTrips,
                        ),
                      ),

                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 200,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.6, 1.0],
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 150,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.2),
                                Colors.black.withOpacity(0.5),
                                Colors.black.withOpacity(0.8),
                                Colors.black,
                              ],
                              stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
                            ),
                          ),
                        ),
                      ),

                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: HomeHeader(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.8),
                        Colors.black,
                      ],
                      stops: const [0.0, 0.2, 0.5, 0.7],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      const PaymentNotificationBanner(),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.12),
                                Colors.white.withOpacity(0.04),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.yellow.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.explore,
                                  color: AppColors.primaryYellow,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _availableTrips.any(
                                            (trip) =>
                                                trip.createdBy ==
                                                TripFilterService.getCurrentUserId(),
                                          )
                                          ? 'Your Trips & Nearby'
                                          : 'Available Trips Nearby',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _personalizedMessage,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.3),
                                  ),
                                ),
                                child: const Text(
                                  'Live',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.18),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  width: 1.2,
                                  color: Colors.white.withOpacity(0.25),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(
                                      255,
                                      0,
                                      0,
                                      0,
                                    ).withOpacity(0.2),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const ActiveRideCard(),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: QuickActionButtons(),
                      ),

                      const SizedBox(height: 30),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: NearbyTripsSection(
                          availableTrips: _availableTrips,
                          userLocation: _userLocation,
                          isLoadingLocation: _isLoadingLocation,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
