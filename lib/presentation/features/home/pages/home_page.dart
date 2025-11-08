// lib/features/home/pages/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_action_buttons.dart';
import '../widgets/active_trips_section.dart';
import '../widgets/nearby_trips_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 120.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeHeader(),
            const SizedBox(height: 28),

            const QuickActionButtons(),
            const SizedBox(height: 32),

            const ActiveTripsSection(),
            const SizedBox(height: 32),

            // const NearbyTripsSection(),
          ],
        ),
      ),
    );
  }
}