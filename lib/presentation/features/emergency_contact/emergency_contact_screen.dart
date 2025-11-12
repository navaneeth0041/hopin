import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/presentation/common_widgets/custom_buttons.dart';
import 'package:hopin/data/models/home/emergency_contact_model.dart';
import 'package:hopin/data/services/user_service.dart';
import 'widgets/emergency_contact_card.dart';
import 'widgets/add_contact_bottom_sheet.dart';
import 'package:hopin/data/services/sos_service.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final UserService _userService = UserService();
  final SosService sosService = SosService();

  List<EmergencyContact> emergencyContacts = [];
  bool sosEnabled = true;
  bool autoShareLocation = true;
  bool _isLoading = true;
  bool _settingsLoading = false;
  bool _sosTriggering = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final hasPermissions = await sosService.checkPermissions();
    if (!hasPermissions) {
      showPermissionDialog();
    }
  }

  void showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.primaryYellow),
            const SizedBox(width: 12),
            Text(
              'Permissions Required',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Text(
          'HopIn needs SMS, Call, and Location permissions to enable SOS features. Please grant these permissions to use emergency alerts.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Later',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await sosService.requestPermissions();
            },
            child: Text(
              'Grant Permissions',
              style: TextStyle(color: AppColors.primaryYellow),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final contacts = await _userService.getEmergencyContacts(uid);
      final settings = await _userService.getSosSettings(uid);

      setState(() {
        emergencyContacts = contacts;
        sosEnabled = settings['sosEnabled'] ?? true;
        autoShareLocation = settings['autoShareLocation'] ?? true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  Future<void> _loadEmergencyContacts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final contacts = await _userService.getEmergencyContacts(uid);
      setState(() {
        emergencyContacts = contacts;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading contacts: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  Future<void> _updateSosSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _settingsLoading = true);

    try {
      await _userService.updateSosSettings(
        uid,
        sosEnabled: sosEnabled,
        autoShareLocation: autoShareLocation,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating settings: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      setState(() => _settingsLoading = false);
    }
  }

  void _showAddContactSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddContactBottomSheet(
        onContactAdded: (contact) async {
          final uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid == null) return;

          final result = await _userService.addEmergencyContact(uid, contact);

          if (result['success']) {
            await _loadEmergencyContacts();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Emergency contact added successfully'),
                  backgroundColor: AppColors.accentGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['error'] ?? 'Failed to add contact'),
                  backgroundColor: AppColors.accentRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _deleteContact(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: Text(
          'Delete Contact',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to remove this emergency contact?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;

              final success = await _userService.deleteEmergencyContact(
                uid,
                id,
              );

              if (success) {
                await _loadEmergencyContacts();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Contact removed'),
                      backgroundColor: AppColors.cardBackground,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to remove contact'),
                      backgroundColor: AppColors.accentRed,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: Text('Delete', style: TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }

  void _setPrimaryContact(String id) async {
    final contact = emergencyContacts.firstWhere((c) => c.id == id);

    if (contact.isPrimary) {
      _showChangePrimaryDialog(id);
    } else {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final success = await _userService.setPrimaryContact(uid, id);

      if (success) {
        await _loadEmergencyContacts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${contact.name} is now your primary contact'),
              backgroundColor: AppColors.accentGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showChangePrimaryDialog(String currentPrimaryId) {
    final otherContacts = emergencyContacts
        .where((c) => c.id != currentPrimaryId)
        .toList();

    if (otherContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add more contacts to change primary contact'),
          backgroundColor: AppColors.cardBackground,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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
                'Change Primary Contact',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a new primary emergency contact',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ...otherContacts.map((contact) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () async {
                      Navigator.pop(context);

                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) return;

                      final success = await _userService.setPrimaryContact(
                        uid,
                        contact.id,
                      );

                      if (success) {
                        await _loadEmergencyContacts();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${contact.name} is now your primary contact',
                              ),
                              backgroundColor: AppColors.accentGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2E),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                contact.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryYellow,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contact.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  contact.relationship,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makeQuickCall(EmergencyContact contact) async {
    try {
      final success = await sosService.makeCall(contact.phoneNumber);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to make call. Please check permissions.',
            ),
            backgroundColor: AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _triggerSOS() async {
    if (!sosEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enable SOS feature first'),
          backgroundColor: AppColors.accentRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (emergencyContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one emergency contact'),
          backgroundColor: AppColors.accentRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _executeSOS();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
      ),
    );
  }

  Future<void> _executeSOS() async {
    if (_sosTriggering) return;

    setState(() => _sosTriggering = true);

    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (context) => AlertDialog(
    //     backgroundColor: const Color(0xFF2C2C2E),
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    //     title: Row(
    //       children: [
    //         Container(
    //           padding: const EdgeInsets.all(8),
    //           decoration: BoxDecoration(
    //             color: AppColors.accentRed.withOpacity(0.15),
    //             borderRadius: BorderRadius.circular(10),
    //           ),
    //           child: Icon(
    //             Icons.warning_amber_rounded,
    //             color: AppColors.accentRed,
    //             size: 34,
    //           ),
    //         ),
    //         const SizedBox(width: 12),
    //         Text(
    //           'Sending SOS Alert',
    //           style: TextStyle(
    //             color: AppColors.textPrimary,
    //             fontSize: 18,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //       ],
    //     ),
    //     content: Row(
    //       children: [
    //         SizedBox(
    //           width: 18,
    //           height: 18,
    //           child: CircularProgressIndicator(
    //             color: AppColors.accentRed,
    //             strokeWidth: 4.5,
    //           ),
    //         ),
    //         const SizedBox(width: 17),
    //         Expanded(
    //           child: Text(
    //             'Notifying emergency contacts...',
    //             style: TextStyle(
    //               color: AppColors.textSecondary,
    //               fontSize: 16,
    //               height: 1.4,
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

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

            //  Circular Progress Indicator
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

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userName = user?.displayName ?? 'HopIn User';

      final contactsList = emergencyContacts
          .map(
            (c) => {
              'name': c.name,
              'phoneNumber': c.phoneNumber,
              'relationship': c.relationship,
            },
          )
          .toList();

      final result = await sosService.triggerSOS(
        userName: userName,
        emergencyContacts: contactsList,
        includeLocation: autoShareLocation,
      );

      Navigator.pop(context);

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🚨 SOS Alert Sent Successfully!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result['contactsNotified']} contacts notified',
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (result['location'] != null)
                    const Text(
                      'Location shared with contacts',
                      style: TextStyle(fontSize: 12),
                    ),
                ],
              ),
              backgroundColor: AppColors.accentRed,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('SOS failed: ${result['error']}'),
              backgroundColor: AppColors.accentRed,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _sosTriggering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: sosEnabled
                          ? AppColors.accentRed.withOpacity(0.15)
                          : AppColors.cardBackground,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: sosEnabled && !_sosTriggering
                          ? _triggerSOS
                          : null,
                      icon: Icon(
                        Icons.emergency,
                        color: sosEnabled
                            ? AppColors.accentRed
                            : AppColors.textTertiary,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: sosEnabled ? 'Trigger SOS' : 'SOS Disabled',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryYellow,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primaryYellow.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryYellow.withOpacity(
                                      0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.info_outline,
                                    color: AppColors.primaryYellow,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Your emergency contacts will be notified with your live location when you trigger SOS.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'SOS Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C2C2E),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.crisis_alert,
                                    color: AppColors.accentRed,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Enable SOS Feature',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Quick emergency alert button',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: sosEnabled,
                                  onChanged: _settingsLoading
                                      ? null
                                      : (value) {
                                          setState(() => sosEnabled = value);
                                          _updateSosSettings();
                                        },
                                  activeColor: AppColors.primaryYellow,
                                  activeTrackColor: AppColors.primaryYellow
                                      .withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C2C2E),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.my_location,
                                    color: AppColors.accentBlue,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Auto Share Location',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Share live location during SOS',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: autoShareLocation,
                                  onChanged: _settingsLoading
                                      ? null
                                      : (value) {
                                          setState(
                                            () => autoShareLocation = value,
                                          );
                                          _updateSosSettings();
                                        },
                                  activeColor: AppColors.primaryYellow,
                                  activeTrackColor: AppColors.primaryYellow
                                      .withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Emergency Contacts',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${emergencyContacts.length}/5',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (emergencyContacts.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.person_add_alt_outlined,
                                      size: 48,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No Emergency Contacts',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add trusted contacts who will be\nnotified in case of emergency',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...emergencyContacts.map((contact) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: EmergencyContactCard(
                                  contact: contact,
                                  onDelete: () => _deleteContact(contact.id),
                                  onSetPrimary: () =>
                                      _setPrimaryContact(contact.id),
                                  onQuickCall: () => _makeQuickCall(contact),
                                ),
                              );
                            }).toList(),
                          const SizedBox(height: 24),
                          if (emergencyContacts.length < 5)
                            PrimaryButton(
                              label: 'Add Emergency Contact',
                              icon: Icons.add,
                              onPressed: _showAddContactSheet,
                            ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
