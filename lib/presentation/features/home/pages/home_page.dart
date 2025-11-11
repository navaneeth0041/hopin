import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_action_buttons.dart';
import '../widgets/active_trips_section.dart'; 
import '../widgets/map_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox(
            height: screenHeight * 0.6,
            width: double.infinity,
            child: const TripsMap(),
          ),

          Positioned(
            top: screenHeight * 0.6 - 120, 
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),


          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 500,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: [
                    0.0,
                    1.0,
                  ],
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: HomeHeader(),
                  ),
                ),

                SizedBox(height: screenHeight * 0.38), 

          
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
                            color: Colors.white.withOpacity(0.25), // glowing edge
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
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

                const SizedBox(height: 24),

    
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const QuickActionButtons(),
                      const SizedBox(height: 24),
                      const Text(
                        "Nearby Trips",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "More trips loading soon 🚗",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 300), 
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}