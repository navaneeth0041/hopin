import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'pages/home_page.dart';
import 'pages/join_trip_page.dart';
import 'pages/create_trip_page.dart';
import 'pages/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const JoinTripPage(),
    const CreateTripPage(),
    const ProfilePage(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
    {
      'icon': Icons.grid_view_outlined,
      'activeIcon': Icons.grid_view,
      'label': 'Trips',
    },
    {
      'icon': Icons.add_circle_outline,
      'activeIcon': Icons.add_circle,
      'label': 'Create',
    },
    {
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'label': 'Profile',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          _pages[_currentIndex],
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E).withOpacity(0.8),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: _getIndicatorPosition(),
                      top: 8,
                      bottom: 8,
                      width: _getIndicatorWidth(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryYellow.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          _navItems.length,
                          (index) => _buildNavItem(
                            icon: _navItems[index]['icon'],
                            activeIcon: _navItems[index]['activeIcon'],
                            label: _navItems[index]['label'],
                            index: index,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getIndicatorPosition() {
    final screenWidth = MediaQuery.of(context).size.width - 40;
    final itemWidth = (screenWidth - 16) / 4;
    return 8 + (_currentIndex * itemWidth);
  }

  double _getIndicatorWidth() {
    final screenWidth = MediaQuery.of(context).size.width - 40;
    return (screenWidth - 16) / 4;
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Icon(
              isActive ? activeIcon : icon,
              color: isActive ? Colors.black : Colors.white.withOpacity(0.6),
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
