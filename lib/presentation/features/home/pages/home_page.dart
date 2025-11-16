// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_action_buttons.dart';
import '../widgets/active_trips_section.dart'; 
import '../widgets/map_widget.dart';
import '../../../../data/providers/trip_provider.dart';
import '../../../../data/models/trip.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _availableTripsCount = 0;
  List<Trip> _availableTrips = [];
  String? currentUserId;
  String _personalizedMessage = 'Searching for trips in your area...';
  
  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    // Load trips from TripProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrips();
    });
  }
  
  void _loadTrips() {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    tripProvider.loadActiveTrips();
  }
  
  void _onTripsCountChanged(int count) {
    setState(() {
      _availableTripsCount = count;
    });
  }
  
  List<Trip> _getAvailableTrips(List<Trip> allTrips) {
    if (currentUserId == null) {
      return [];
    }
    
  
    final filteredTrips = allTrips.where((trip) {
      if (trip.joinedUsers.contains(currentUserId)) {
        return false;
      }
      if (trip.status != TripStatus.active) {
        return false;
      }
      
      return true;
    }).toList();
    
    return filteredTrips;
  }

  int _getJoinableTripsCount(List<Trip> allTrips) {
    if (currentUserId == null) return 0;
    
    final joinableTrips = allTrips.where((trip) {
      if (trip.createdBy == currentUserId) return false; 
      if (trip.joinedUsers.contains(currentUserId)) return false;
      return trip.status == TripStatus.active;
    }).toList();
    
    return joinableTrips.length;
  }

  String _getPersonalizedTripMessage(List<Trip> allTrips) {
    if (currentUserId == null) {
      return 'Searching for trips in your area...';
    }
    
    final ownTrips = allTrips.where((trip) => 
      trip.createdBy == currentUserId && trip.status == TripStatus.active).toList();
    
    final joinedTrips = allTrips.where((trip) => 
      trip.joinedUsers.contains(currentUserId) && trip.status == TripStatus.active).toList();
    
    final joinableTrips = _getJoinableTripsCount(allTrips);
    
    List<String> parts = [];
    
    if (ownTrips.isNotEmpty) {
      parts.add('${ownTrips.length} trip${ownTrips.length > 1 ? 's' : ''} created');
    }
    
    if (joinedTrips.isNotEmpty) {
      parts.add('${joinedTrips.length} trip${joinedTrips.length > 1 ? 's' : ''} joined');
    }
    
    if (joinableTrips > 0) {
      parts.add('${joinableTrips} available to join');
    }
    
    String message;
    if (parts.isEmpty) {
      message = 'No trips found. Create your first trip!';
    } else if (parts.length == 1) {
      message = parts.first;
    } else if (parts.length == 2) {
      message = '${parts[0]} • ${parts[1]}';
    } else {
      message = '${parts[0]} • ${parts[1]} • ${parts[2]}';
    }
    
    return message;
  }
  
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour == 0 ? 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        _availableTrips = _getAvailableTrips(tripProvider.activeTrips);
        final joinableCount = _getJoinableTripsCount(tripProvider.activeTrips);
        final personalizedMessage = _getPersonalizedTripMessage(tripProvider.activeTrips);
        
        if (_availableTripsCount != joinableCount || _personalizedMessage != personalizedMessage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _availableTripsCount = joinableCount;
              _personalizedMessage = personalizedMessage;
            });
          });
        }
        
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 17, 17, 17), // set opacity to blac
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
                  // Full Screen Map
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
                  
                  // Bottom Gradient Overlay for Seamless Blending
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
                  
                  // Header Content
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: HomeHeader(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content Section
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
                  const SizedBox(height: 40), // Reduced space for better blending
                  
               
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
                              color: Colors.yellow,
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
                                  _availableTrips.any((trip) => trip.createdBy == currentUserId) 
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
                                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
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
                  
                  // Quick Actions
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: QuickActionButtons(),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Nearby Trips Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Nearby Trips",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        
                        // Responsive Grid for Real Trip Cards
                        _availableTrips.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: Colors.white.withOpacity(0.5),
                                      size: 32,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Loading available trips...',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: screenWidth > 600 ? 2 : 1,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: screenWidth > 600 ? 1.2 : 2.8,
                                ),
                                itemCount: _availableTrips.length,
                                itemBuilder: (context, index) {
                                  final trip = _availableTrips[index];
                                  final isOwnTrip = trip.createdBy == currentUserId;
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isOwnTrip 
                                        ? Colors.blue.withOpacity(0.12)
                                        : Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isOwnTrip 
                                          ? Colors.blue.withOpacity(0.3)
                                          : Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: isOwnTrip ? Colors.blue : Colors.yellow,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isOwnTrip ? Icons.account_circle : Icons.person,
                                                color: Colors.black,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    isOwnTrip ? 'You (${trip.creatorName})' : trip.creatorName,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${trip.currentLocation} → ${trip.destination}',
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.7),
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isOwnTrip 
                                                  ? Colors.blue.withOpacity(0.2)
                                                  : Colors.green.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                isOwnTrip 
                                                  ? 'Your trip'
                                                  : '${trip.availableSeats} seats',
                                                style: TextStyle(
                                                  color: isOwnTrip ? Colors.blue : Colors.green,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (screenWidth <= 600) ...[
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time,
                                                color: Colors.yellow,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${_formatTime(trip.departureTime)} • ${trip.availableSeats} seats',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.8),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                        
                        const SizedBox(height: 100), // Bottom padding
                      ],
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