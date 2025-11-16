import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/models/trip.dart';
import 'package:hopin/data/models/privacy_settings_model.dart';
import 'package:hopin/data/services/enhanced_trip_service.dart';
import 'package:hopin/data/services/privacy_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class TripDetailBottomSheet extends StatefulWidget {
  final Trip trip;

  const TripDetailBottomSheet({super.key, required this.trip});

  @override
  State<TripDetailBottomSheet> createState() => _TripDetailBottomSheetState();
}

class _TripDetailBottomSheetState extends State<TripDetailBottomSheet> {
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

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final time = '$hour:$minute $period';

    final date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    return '$date at $time';
  }

  Color _getStatusColor() {
    switch (widget.trip.status) {
      case TripStatus.active:
        return AppColors.accentGreen;
      case TripStatus.full:
        return AppColors.primaryYellow;
      case TripStatus.completed:
        return Colors.blue;
      case TripStatus.cancelled:
        return AppColors.accentRed;
    }
  }

  String _getStatusText() {
    switch (widget.trip.status) {
      case TripStatus.active:
        return 'Active';
      case TripStatus.full:
        return 'Full';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filledSeats = widget.trip.totalSeats - widget.trip.availableSeats;

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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text(
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getStatusColor().withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getStatusColor().withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.trip.status == TripStatus.active ||
                                        widget.trip.status == TripStatus.full
                                    ? Icons.directions_car
                                    : widget.trip.status == TripStatus.completed
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: _getStatusColor(),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Status',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getStatusText(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

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
                        title: 'Route Information',
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
                            icon: Icons.schedule,
                            label: 'Departure',
                            value: _formatDateTime(widget.trip.departureTime),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildSectionCard(
                        title: 'Seats & Capacity',
                        icon: Icons.event_seat,
                        children: [
                          _buildDetailRow(
                            icon: Icons.airline_seat_recline_normal,
                            label: 'Total Seats',
                            value: '${widget.trip.totalSeats} seats',
                          ),
                          _buildDetailRow(
                            icon: Icons.people,
                            label: 'Filled Seats',
                            value: '$filledSeats seats',
                            valueColor: filledSeats > 0
                                ? AppColors.accentGreen
                                : null,
                          ),
                          _buildDetailRow(
                            icon: Icons.event_seat_outlined,
                            label: 'Available Seats',
                            value: '${widget.trip.availableSeats} seats',
                            valueColor: widget.trip.availableSeats > 0
                                ? AppColors.primaryYellow
                                : AppColors.accentRed,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (widget.trip.joinedUsers.isNotEmpty || filledSeats > 0)
                        _buildParticipantsSection(),

                      if (widget.trip.joinedUsers.isNotEmpty || filledSeats > 0)
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
                                style: const TextStyle(
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

  Widget _buildParticipantsSection() {
    final allParticipants = [
      {'userId': widget.trip.createdBy, 'isCreator': true},
      ...widget.trip.joinedUsers.map(
        (uid) => {'userId': uid, 'isCreator': false},
      ),
    ];

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
                  Icons.people_alt,
                  color: AppColors.primaryYellow,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Trip Participants (${allParticipants.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...allParticipants.asMap().entries.map((entry) {
            final index = entry.key;
            final participant = entry.value;
            final userId = participant['userId'] as String;
            final isCreator = participant['isCreator'] as bool;
            final isLast = index == allParticipants.length - 1;
            return _buildParticipantCard(
              userId,
              isCreator: isCreator,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(
    String userId, {
    bool isCreator = false,
    bool isLast = false,
  }) {
    final userData = isCreator ? null : _joinedUsersData[userId];
    final userDetails = isCreator
        ? widget.trip.creatorDetails
        : (userData?['details'] as Map<String, dynamic>?);
    final privacy = isCreator ? _creatorPrivacy : _joinedUsersPrivacy[userId];

    final userName = isCreator
        ? widget.trip.creatorName
        : userDetails?['fullName'] ?? 'Unknown User';
    final userEmail = userDetails?['email'] ?? '';

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isCurrentUserCreator = currentUserId == widget.trip.createdBy;

    final canRemove =
        isCurrentUserCreator &&
        !isCreator &&
        (widget.trip.status == TripStatus.active ||
            widget.trip.status == TripStatus.full) &&
        widget.trip.departureTime.isAfter(DateTime.now());

    return GestureDetector(
      onLongPress: canRemove
          ? () => _showRemoveUserDialog(userId, userName)
          : null,
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCreator
                ? AppColors.primaryYellow.withOpacity(0.3)
                : AppColors.divider,
            width: 1,
          ),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCreator)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Creator',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryYellow,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isCreator && userDetails != null)
                  InkWell(
                    onTap: () =>
                        _showUserDetailsDialog(userId, userData, privacy),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryYellow,
                        ),
                      ),
                    ),
                  ),
                if (canRemove) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showRemoveUserDialog(userId, userName),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.accentRed.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_remove,
                        size: 16,
                        color: AppColors.accentRed,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveUserDialog(String userId, String userName) {
    final timeUntilDeparture = widget.trip.departureTime.difference(
      DateTime.now(),
    );
    final hoursRemaining = timeUntilDeparture.inHours;
    final minutesRemaining = timeUntilDeparture.inMinutes % 60;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_remove,
                color: AppColors.accentRed,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Remove Member',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remove $userName from this trip?',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Time until departure:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$hoursRemaining hours $minutesRemaining minutes',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryYellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accentRed.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.accentRed,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This user will be notified and a seat will be freed for others to join.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleRemoveUser(userId, userName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Remove',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRemoveUser(String userId, String userName) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryYellow),
      ),
    );

    final enhancedService = EnhancedTripService();
    final result = await enhancedService.removeUserFromTrip(
      tripId: widget.trip.id,
      userIdToRemove: userId,
      requesterId: currentUserId,
    );

    if (mounted) {
      Navigator.pop(context);

      if (result['success']) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result['message'] ?? '$userName removed successfully',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result['error'] ?? 'Failed to remove user',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
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
            width: 40,
            height: 40,
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primaryYellow.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryYellow, width: 2),
      ),
      child: const Icon(Icons.person, color: AppColors.primaryYellow, size: 20),
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
    Color? valueColor,
    Widget? trailing,
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
                  style: const TextStyle(
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
}
