// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/models/trip.dart';
import 'package:hopin/data/models/privacy_settings_model.dart';
import 'package:hopin/data/services/privacy_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class RideDetailBottomSheet extends StatefulWidget {
  final Trip trip;

  const RideDetailBottomSheet({super.key, required this.trip});

  @override
  State<RideDetailBottomSheet> createState() => _RideDetailBottomSheetState();
}

class _RideDetailBottomSheetState extends State<RideDetailBottomSheet> {
  final PrivacyService _privacyService = PrivacyService();
  PrivacySettings? _creatorPrivacy;
  Map<String, PrivacySettings> _joinedUsersPrivacy = {};
  Map<String, Map<String, dynamic>> _joinedUsersData = {};
  bool _isLoadingPrivacy = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
    _loadJoinedUsersData();
  }

  Future<void> _loadPrivacySettings() async {
    try {
      final creatorPrivacy = await _privacyService.getPrivacySettings(
        widget.trip.createdBy,
      );

      final joinedPrivacy = <String, PrivacySettings>{};
      for (final userId in widget.trip.joinedUsers) {
        final privacy = await _privacyService.getPrivacySettings(userId);
        joinedPrivacy[userId] = privacy;
      }

      if (mounted) {
        setState(() {
          _creatorPrivacy = creatorPrivacy;
          _joinedUsersPrivacy = joinedPrivacy;
          _isLoadingPrivacy = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPrivacy = false;
        });
      }
    }
  }

  Future<void> _loadJoinedUsersData() async {
    try {
      final usersData = <String, Map<String, dynamic>>{};

      for (final userId in widget.trip.joinedUsers) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          usersData[userId] = userDoc.data() ?? {};
        }
      }

      if (mounted) {
        setState(() {
          _joinedUsersData = usersData;
        });
      }
    } catch (e) {
      return;
    }
  }

  bool _shouldShowField(String fieldName, PrivacySettings? privacy) {
    if (privacy == null) return false;
    return privacy.shouldShowField(fieldName);
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('d MMM yyyy').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: const Text(
                  'Trip Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const Divider(color: AppColors.divider, height: 1),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionCard(
                        title: 'Trip Creator',
                        icon: Icons.person,
                        children: [
                          _buildDetailRow(
                            icon: Icons.account_circle,
                            label: 'Name',
                            value: widget.trip.creatorName,
                          ),
                          if (widget.trip.creatorDetails?['email'] != null &&
                              widget.trip.creatorDetails!['email']
                                  .toString()
                                  .isNotEmpty)
                            _buildDetailRow(
                              icon: Icons.email,
                              label: 'Email',
                              value: widget.trip.creatorDetails!['email'],
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  size: 18,
                                  color: AppColors.primaryYellow,
                                ),
                                onPressed: () => _copyToClipboard(
                                  context,
                                  widget.trip.creatorDetails!['email'],
                                  'Email',
                                ),
                              ),
                            ),
                          if (widget.trip.creatorDetails?['phone'] != null &&
                              widget.trip.creatorDetails!['phone']
                                  .toString()
                                  .isNotEmpty)
                            _buildDetailRow(
                              icon: Icons.phone,
                              label: 'Contact',
                              value: widget.trip.creatorDetails!['phone'],
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  size: 18,
                                  color: AppColors.primaryYellow,
                                ),
                                onPressed: () => _copyToClipboard(
                                  context,
                                  widget.trip.creatorDetails!['phone'],
                                  'Phone number',
                                ),
                              ),
                            ),
                          if (!_isLoadingPrivacy &&
                              _shouldShowField('department', _creatorPrivacy) &&
                              widget.trip.creatorDetails?['department'] !=
                                  null &&
                              widget.trip.creatorDetails!['department']
                                  .toString()
                                  .isNotEmpty)
                            _buildDetailRow(
                              icon: Icons.school,
                              label: 'Department',
                              value: widget.trip.creatorDetails!['department'],
                            ),
                          if (!_isLoadingPrivacy &&
                              _shouldShowField('year', _creatorPrivacy) &&
                              widget.trip.creatorDetails?['year'] != null &&
                              widget.trip.creatorDetails!['year']
                                  .toString()
                                  .isNotEmpty)
                            _buildDetailRow(
                              icon: Icons.calendar_month,
                              label: 'Year',
                              value: widget.trip.creatorDetails!['year'],
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildSectionCard(
                        title: 'Trip Details',
                        icon: Icons.route,
                        children: [
                          _buildDetailRow(
                            icon: Icons.my_location,
                            label: 'From',
                            value: widget.trip.currentLocation,
                          ),
                          _buildDetailRow(
                            icon: Icons.location_on,
                            label: 'To',
                            value: widget.trip.destination,
                          ),
                          _buildDetailRow(
                            icon: Icons.calendar_today,
                            label: 'Date',
                            value: _formatDate(widget.trip.departureTime),
                          ),
                          _buildDetailRow(
                            icon: Icons.access_time,
                            label: 'Time',
                            value: _formatTime(widget.trip.departureTime),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildSectionCard(
                        title: 'Seats Information',
                        icon: Icons.event_seat,
                        children: [
                          _buildDetailRow(
                            icon: Icons.event_seat,
                            label: 'Available Seats',
                            value: '${widget.trip.availableSeats} seats',
                            valueColor: widget.trip.availableSeats > 0
                                ? AppColors.accentGreen
                                : AppColors.accentRed,
                          ),
                          _buildDetailRow(
                            icon: Icons.people,
                            label: 'Total Seats',
                            value: '${widget.trip.totalSeats} seats',
                          ),
                          _buildDetailRow(
                            icon: Icons.group,
                            label: 'Joined Users',
                            value:
                                '${widget.trip.joinedUsers.length} ${widget.trip.joinedUsers.length == 1 ? 'person' : 'people'}',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      if (widget.trip.joinedUsers.isNotEmpty)
                        _buildJoinedUsersSection(),

                      if (widget.trip.joinedUsers.isNotEmpty)
                        const SizedBox(height: 16),

                      if (widget.trip.note != null &&
                          widget.trip.note!.isNotEmpty)
                        _buildSectionCard(
                          title: 'Additional Notes',
                          icon: Icons.note,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.darkBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.trip.note!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primaryYellow, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildJoinedUsersSection() {
    if (widget.trip.joinedUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.people,
                  color: AppColors.primaryYellow,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Joined Passengers (${widget.trip.joinedUsers.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.trip.joinedUsers
              .map((userId) => _buildJoinedUserCard(userId))
              ,
        ],
      ),
    );
  }

  Widget _buildJoinedUserCard(String userId) {
    final userData = _joinedUsersData[userId];
    final userDetails = userData?['details'] as Map<String, dynamic>?;
    final privacy = _joinedUsersPrivacy[userId];

    final userName = userDetails?['fullName'] ?? 'Unknown User';
    final userEmail = userDetails?['email'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          FutureBuilder<Widget>(
            future: _buildUserProfileImage(userId, userDetails, privacy),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!;
              }
              return _buildDefaultUserProfileImage();
            },
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          InkWell(
            onTap: () => _showUserDetailsDialog(userId, userData, privacy),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryYellow.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Text(
                'Details',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryYellow,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Widget> _buildUserProfileImage(
    String userId,
    Map<String, dynamic>? userDetails,
    PrivacySettings? privacy,
  ) async {
    if (!_shouldShowField('profilePicture', privacy)) {
      return _buildDefaultUserProfileImage();
    }

    try {
      final base64Image = userDetails?['profileImageBase64'] as String?;

      if (base64Image != null && base64Image.isNotEmpty) {
        try {
          final Uint8List bytes = base64Decode(base64Image);
          return Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: MemoryImage(bytes),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: AppColors.primaryYellow, width: 2),
            ),
          );
        } catch (e) {
          return _buildDefaultUserProfileImage();
        }
      }
    } catch (e) {
      return _buildDefaultUserProfileImage();
    }

    return _buildDefaultUserProfileImage();
  }

  Widget _buildDefaultUserProfileImage() {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.primaryYellow.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryYellow, width: 2),
      ),
      child: const Icon(Icons.person, color: AppColors.primaryYellow, size: 24),
    );
  }

  void _showUserDetailsDialog(
    String userId,
    Map<String, dynamic>? userData,
    PrivacySettings? privacy,
  ) {
    final userDetails = userData?['details'] as Map<String, dynamic>?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            FutureBuilder<Widget>(
              future: _buildUserProfileImage(userId, userDetails, privacy),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return _buildDefaultUserProfileImage();
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                userDetails?['fullName'] ?? 'User Details',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (userDetails?['email'] != null)
                _buildDialogDetailRow(
                  icon: Icons.email,
                  label: 'Email',
                  value: userDetails!['email'],
                ),

              if (userDetails?['phoneNumber'] != null)
                _buildDialogDetailRow(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: userDetails!['phoneNumber'],
                ),

              if (_shouldShowField('department', privacy) &&
                  userDetails?['department'] != null)
                _buildDialogDetailRow(
                  icon: Icons.school,
                  label: 'Department',
                  value: userDetails!['department'],
                ),

              if (_shouldShowField('year', privacy) &&
                  userDetails?['year'] != null)
                _buildDialogDetailRow(
                  icon: Icons.calendar_month,
                  label: 'Year',
                  value: userDetails!['year'],
                ),

              if (_shouldShowField('hostel', privacy) &&
                  userDetails?['hostel'] != null)
                _buildDialogDetailRow(
                  icon: Icons.home,
                  label: 'Hostel',
                  value: userDetails!['hostel'],
                ),

              if (_shouldShowField('hometown', privacy) &&
                  userDetails?['hometown'] != null)
                _buildDialogDetailRow(
                  icon: Icons.location_city,
                  label: 'Hometown',
                  value: userDetails!['hometown'],
                ),

              if (_shouldShowField('bio', privacy) &&
                  userDetails?['bio'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bio',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userDetails!['bio'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                color: AppColors.primaryYellow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
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
