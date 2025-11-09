import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/models/home/driver_model.dart';
import 'widgets/driver_card.dart';
import 'widgets/driver_filter_chip.dart';

class DriverDirectoryScreen extends StatefulWidget {
  const DriverDirectoryScreen({super.key});

  @override
  State<DriverDirectoryScreen> createState() => _DriverDirectoryScreenState();
}

class _DriverDirectoryScreenState extends State<DriverDirectoryScreen> {
  String selectedFilter = 'all';
  String sortBy = 'rating';
  String searchQuery = '';

  final List<Driver> allDrivers = [
    Driver(
      id: '1',
      name: 'Raju Kumar',
      phoneNumber: '+91 98765 43210',
      vehicleType: 'auto',
      vehicleNumber: 'KL-07 AB 1234',
      area: 'Amritapuri',
      rating: 4.8,
      isVerified: true,
    ),
    Driver(
      id: '2',
      name: 'Suresh Babu',
      phoneNumber: '+91 98765 43211',
      vehicleType: 'taxi',
      vehicleNumber: 'KL-07 CD 5678',
      area: 'Kollam',
      rating: 4.9,
      isVerified: true,
    ),
    Driver(
      id: '3',
      name: 'Anil Kumar',
      phoneNumber: '+91 98765 43212',
      vehicleType: 'auto',
      vehicleNumber: 'KL-07 EF 9012',
      area: 'Karunagappally',
      rating: 4.6,
      isVerified: true,
    ),
    Driver(
      id: '4',
      name: 'Mohan Das',
      phoneNumber: '+91 98765 43213',
      vehicleType: 'taxi',
      vehicleNumber: 'KL-07 GH 3456',
      area: 'Haripad',
      rating: 4.7,
      isVerified: true,
    ),
    Driver(
      id: '5',
      name: 'Vinod Kumar',
      phoneNumber: '+91 98765 43214',
      vehicleType: 'auto',
      vehicleNumber: 'KL-07 IJ 7890',
      area: 'Amritapuri',
      rating: 4.5,
      isVerified: false,
    ),
    Driver(
      id: '6',
      name: 'Ramesh Pillai',
      phoneNumber: '+91 98765 43215',
      vehicleType: 'taxi',
      vehicleNumber: 'KL-07 KL 2345',
      area: 'Kollam',
      rating: 4.9,
      isVerified: true,
    ),
    Driver(
      id: '7',
      name: 'Ajay Kumar',
      phoneNumber: '+91 98765 43216',
      vehicleType: 'auto',
      vehicleNumber: 'KL-07 MN 6789',
      area: 'Kayamkulam',
      rating: 4.4,
      isVerified: true,
    ),
    Driver(
      id: '8',
      name: 'Krishna Das',
      phoneNumber: '+91 98765 43217',
      vehicleType: 'taxi',
      vehicleNumber: 'KL-07 OP 0123',
      area: 'Amritapuri',
      rating: 4.8,
      isVerified: true,
    ),
  ];

  List<Driver> get filteredDrivers {
    var drivers = allDrivers.where((driver) {
      if (selectedFilter != 'all' && driver.vehicleType != selectedFilter) {
        return false;
      }

      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return driver.name.toLowerCase().contains(query) ||
            driver.vehicleNumber.toLowerCase().contains(query) ||
            driver.area.toLowerCase().contains(query);
      }

      return true;
    }).toList();

    switch (sortBy) {
      case 'rating':
        drivers.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        drivers.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return drivers;
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              _buildSortOption('Highest Rating', 'rating', Icons.star_rounded),
              _buildSortOption('Name (A-Z)', 'name', Icons.sort_by_alpha),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value, IconData icon) {
    final isSelected = sortBy == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            sortBy = value;
          });
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryYellow.withOpacity(0.15)
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryYellow : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryYellow
                    : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primaryYellow,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drivers = filteredDrivers;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Driver Directory',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search drivers, vehicles, or areas...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  DriverFilterChip(
                    label: 'All',
                    icon: Icons.grid_view,
                    isSelected: selectedFilter == 'all',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'all';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  DriverFilterChip(
                    label: 'Auto',
                    icon: Icons.airport_shuttle,
                    isSelected: selectedFilter == 'auto',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'auto';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  DriverFilterChip(
                    label: 'Taxi',
                    icon: Icons.local_taxi,
                    isSelected: selectedFilter == 'taxi',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'taxi';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showSortBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider, width: 1),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tune,
                              size: 16,
                              color: AppColors.primaryYellow,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Sort',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Text(
                    '${drivers.length} ${drivers.length == 1 ? 'Driver' : 'Drivers'} Found',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.verified_user,
                    size: 16,
                    color: AppColors.primaryYellow,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${drivers.where((d) => d.isVerified).length} Verified',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: drivers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Drivers Found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      itemCount: drivers.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return DriverCard(driver: drivers[index], onTap: () {});
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
