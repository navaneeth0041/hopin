// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/providers/user_profile_provider.dart';
import 'package:hopin/data/services/location_service.dart';
import 'package:hopin/data/services/geocoding_service.dart';
import 'package:hopin/data/services/trip_request_service.dart';
import 'package:hopin/data/services/user_service.dart';
import 'package:hopin/data/services/sos_service.dart';
import 'package:hopin/presentation/features/notifications/notifications_screen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  String _currentLocation = 'Loading location...';
  final UserService _userService = UserService();
  final SosService _sosService = SosService();
  bool _sosTriggering = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    Stream.periodic(const Duration(seconds: 30)).listen((_) {
      if (mounted) {
        _getCurrentLocation();
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      final address = await GeocodingService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _currentLocation = address;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentLocation = 'Location unavailable';
        });
      }
    }
  }

  Future<void> _handleSOSTap(bool sosEnabled, bool autoShareLocation) async {
    if (!sosEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('SOS is disabled. Enable it in Emergency Contacts'),
              ),
            ],
          ),
          backgroundColor: AppColors.accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/emergency-contact');
            },
          ),
        ),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final emergencyContacts = await _userService.getEmergencyContacts(uid);

    if (emergencyContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Please add emergency contacts first'),
              ),
            ],
          ),
          backgroundColor: AppColors.accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: 'Add',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/emergency-contact');
            },
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.accentRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Trigger SOS',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'This will immediately alert your emergency contacts${autoShareLocation ? ' with your current location' : ''}. Are you sure?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Send Alert',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _executeSOS(autoShareLocation);
    }
  }

  Future<void> _executeSOS(bool autoShareLocation) async {
    if (_sosTriggering) return;

    setState(() => _sosTriggering = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppColors.accentRed,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sending SOS Alert',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifying emergency contacts...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.accentRed,
                strokeWidth: 3.0,
              ),
            ),
          ],
        ),
      ),
    );

    void showCustomSnackBar(String message, Color color, IconData icon) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userName = user?.displayName ?? 'HopIn User';
      final uid = user?.uid;

      if (uid == null) {
        Navigator.pop(context);
        showCustomSnackBar(
          'User not authenticated',
          AppColors.accentRed,
          Icons.error_outline,
        );
        setState(() => _sosTriggering = false);
        return;
      }

      final emergencyContacts = await _userService.getEmergencyContacts(uid);

      final contactsList = emergencyContacts
          .map(
            (c) => {
              'name': c.name,
              'phoneNumber': c.phoneNumber,
              'relationship': c.relationship,
            },
          )
          .toList();

      final result = await _sosService.triggerSOS(
        userName: userName,
        emergencyContacts: contactsList,
        includeLocation: autoShareLocation,
      );

      Navigator.pop(context);

      if (result['success']) {
        showCustomSnackBar(
          '🚨 SOS Alert Sent Successfully! ${result['contactsNotified']} contacts notified${result['location'] != null ? ' (Location shared)' : ''}',
          AppColors.accentRed,
          Icons.warning_amber_rounded,
        );
      } else {
        showCustomSnackBar(
          'SOS failed: ${result['error']}',
          AppColors.accentRed,
          Icons.error_outline,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      showCustomSnackBar('Error: $e', AppColors.accentRed, Icons.error_outline);
    } finally {
      setState(() => _sosTriggering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<UserProfileProvider>(
                builder: (context, profileProvider, child) {
                  final userName = profileProvider.userProfile.name.isNotEmpty
                      ? profileProvider.userProfile.name.split(' ').first
                      : 'User';

                  return Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    child: Text(
                      'Hello, $userName!',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _getCurrentLocation,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _currentLocation,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_currentLocation == 'Loading location...')
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        width: 12,
                        height: 12,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<int>(
              stream: TripRequestService().getUnreadNotificationsCount(
                FirebaseAuth.instance.currentUser?.uid ?? '',
              ),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.accentRed,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(width: 12),

            // SOS Button with StreamBuilder for real-time updates
            if (uid != null)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('preferences')
                    .doc('sosSettings')
                    .snapshots(),
                builder: (context, snapshot) {
                  bool sosEnabled = true;
                  bool autoShareLocation = true;
                  bool isLoading = !snapshot.hasData;

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    sosEnabled = data?['sosEnabled'] ?? true;
                    autoShareLocation = data?['autoShareLocation'] ?? true;
                  }

                  return GestureDetector(
                    onTap: isLoading || _sosTriggering
                        ? null
                        : () => _handleSOSTap(sosEnabled, autoShareLocation),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: sosEnabled
                            ? AppColors.accentRed.withOpacity(0.1)
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sosEnabled
                              ? AppColors.accentRed
                              : AppColors.divider,
                          width: 1,
                        ),
                      ),
                      child: isLoading
                          ? Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    sosEnabled
                                        ? AppColors.accentRed
                                        : AppColors.textTertiary,
                                  ),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.emergency_outlined,
                              color: sosEnabled
                                  ? AppColors.accentRed
                                  : AppColors.textTertiary,
                              size: 22,
                            ),
                    ),
                  );
                },
              )
            else
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider, width: 1),
                ),
                child: const Icon(
                  Icons.emergency_outlined,
                  color: AppColors.textTertiary,
                  size: 22,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
