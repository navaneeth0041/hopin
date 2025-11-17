import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/services/trip_request_service.dart';
import 'package:hopin/data/services/privacy_service.dart';
import 'package:hopin/data/models/trip_request.dart';
import 'package:hopin/data/models/privacy_settings_model.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';

class TripRequestsScreen extends StatefulWidget {
  final String tripId;

  const TripRequestsScreen({super.key, required this.tripId});

  @override
  State<TripRequestsScreen> createState() => _TripRequestsScreenState();
}

class _TripRequestsScreenState extends State<TripRequestsScreen> {
  final TripRequestService _requestService = TripRequestService();
  final PrivacyService _privacyService = PrivacyService();
  final Map<String, PrivacySettings> _privacyCache = {};
  final Map<String, Map<String, dynamic>> _userDataCache = {};

  Future<void> _handleAccept(TripRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Accept Request',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Accept ${request.requesterName}\'s request to join this trip?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Accept',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result = await _requestService.acceptTripRequest(request.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success']
                  ? 'Request accepted successfully'
                  : result['error'] ?? 'Failed to accept request',
            ),
            backgroundColor: result['success']
                ? AppColors.accentGreen
                : AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _handleReject(TripRequest request) async {
    final TextEditingController messageController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Reject Request',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reject ${request.requesterName}\'s request?',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 3,
              maxLength: 150,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Optional: Add a reason',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: AppColors.darkBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Reject',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result = await _requestService.rejectTripRequest(
        request.id,
        message: messageController.text.trim().isEmpty
            ? null
            : messageController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success']
                  ? 'Request rejected'
                  : result['error'] ?? 'Failed to reject request',
            ),
            backgroundColor: result['success']
                ? AppColors.accentGreen
                : AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }

    messageController.dispose();
  }

  Future<void> _showUserDetails(TripRequest request) async {
    Map<String, dynamic>? userData;
    PrivacySettings? privacy;

    if (_userDataCache.containsKey(request.requesterId)) {
      userData = _userDataCache[request.requesterId];
    } else {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(request.requesterId)
          .get();
      if (userDoc.exists) {
        userData = userDoc.data();
        _userDataCache[request.requesterId] = userData!;
      }
    }

    if (_privacyCache.containsKey(request.requesterId)) {
      privacy = _privacyCache[request.requesterId];
    } else {
      privacy = await _privacyService.getPrivacySettings(request.requesterId);
      _privacyCache[request.requesterId] = privacy;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => _UserDetailsDialog(
        request: request,
        userData: userData,
        privacy: privacy,
      ),
    );
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C2C2E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const Text(
                    'Join Requests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<List<TripRequest>>(
                stream: _requestService.getTripRequests(widget.tripId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryYellow,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading requests',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  final requests = snapshot.data ?? [];

                  if (requests.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 80,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Pending Requests',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You\'ll see join requests here',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    itemCount: requests.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return _RequestCard(
                        request: request,
                        onAccept: () => _handleAccept(request),
                        onReject: () => _handleReject(request),
                        onViewDetails: () => _showUserDetails(request),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  final TripRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onViewDetails;

  const _RequestCard({
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.onViewDetails,
  });

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  final PrivacyService _privacyService = PrivacyService();
  Widget? _profileImage;
  bool _isLoadingImage = true;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final privacy = await _privacyService.getPrivacySettings(
        widget.request.requesterId,
      );

      if (!privacy.shouldShowField('profilePicture')) {
        setState(() {
          _profileImage = _buildDefaultImage();
          _isLoadingImage = false;
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.request.requesterId)
          .get();

      if (!userDoc.exists) {
        setState(() {
          _profileImage = _buildDefaultImage();
          _isLoadingImage = false;
        });
        return;
      }

      final userData = userDoc.data();
      final userDetails = userData?['details'] as Map<String, dynamic>?;
      final base64Image = userDetails?['profileImageBase64'] as String?;

      if (base64Image != null && base64Image.isNotEmpty) {
        try {
          final Uint8List bytes = base64Decode(base64Image);
          setState(() {
            _profileImage = Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: MemoryImage(bytes),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: AppColors.primaryYellow, width: 2),
              ),
            );
            _isLoadingImage = false;
          });
          return;
        } catch (e) {
          return;
        }
      }

      setState(() {
        _profileImage = _buildDefaultImage();
        _isLoadingImage = false;
      });
    } catch (e) {
      setState(() {
        _profileImage = _buildDefaultImage();
        _isLoadingImage = false;
      });
    }
  }

  Widget _buildDefaultImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primaryYellow.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: AppColors.primaryYellow, size: 28),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _isLoadingImage
                  ? Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryYellow,
                            ),
                          ),
                        ),
                      ),
                    )
                  : _profileImage ?? _buildDefaultImage(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.request.requesterName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (widget.request.requesterPhone != null)
                      Text(
                        widget.request.requesterPhone!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              InkWell(
                onTap: widget.onViewDetails,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (widget.request.message != null &&
              widget.request.message!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.message,
                    size: 16,
                    color: AppColors.accentBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.request.message!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          Text(
            _getTimeAgo(widget.request.createdAt),
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentRed,
                    side: BorderSide(
                      color: AppColors.accentRed.withOpacity(0.3),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Reject',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserDetailsDialog extends StatelessWidget {
  final TripRequest request;
  final Map<String, dynamic>? userData;
  final PrivacySettings? privacy;

  const _UserDetailsDialog({
    required this.request,
    required this.userData,
    required this.privacy,
  });

  bool _shouldShowField(String fieldName) {
    if (privacy == null) return false;
    return privacy!.shouldShowField(fieldName);
  }

  Widget _buildProfileImage() {
    final userDetails = userData?['details'] as Map<String, dynamic>?;

    if (!_shouldShowField('profilePicture')) {
      return _buildDefaultImage();
    }

    try {
      final base64Image = userDetails?['profileImageBase64'] as String?;
      if (base64Image != null && base64Image.isNotEmpty) {
        final Uint8List bytes = base64Decode(base64Image);
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: MemoryImage(bytes),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: AppColors.primaryYellow, width: 2),
          ),
        );
      }
    } catch (e) {
      return _buildDefaultImage();
    }

    return _buildDefaultImage();
  }

  Widget _buildDefaultImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primaryYellow.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryYellow, width: 2),
      ),
      child: const Icon(Icons.person, color: AppColors.primaryYellow, size: 32),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userDetails = userData?['details'] as Map<String, dynamic>?;

    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          _buildProfileImage(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              request.requesterName,
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
              _buildDetailRow(
                icon: Icons.email,
                label: 'Email',
                value: userDetails!['email'],
              ),
            if (request.requesterPhone != null)
              _buildDetailRow(
                icon: Icons.phone,
                label: 'Phone',
                value: request.requesterPhone!,
              ),
            if (_shouldShowField('department') &&
                userDetails?['department'] != null)
              _buildDetailRow(
                icon: Icons.school,
                label: 'Department',
                value: userDetails!['department'],
              ),
            if (_shouldShowField('year') && userDetails?['year'] != null)
              _buildDetailRow(
                icon: Icons.calendar_month,
                label: 'Year',
                value: userDetails!['year'],
              ),
            if (_shouldShowField('hostel') && userDetails?['hostel'] != null)
              _buildDetailRow(
                icon: Icons.home,
                label: 'Hostel',
                value: userDetails!['hostel'],
              ),
            if (_shouldShowField('hometown') &&
                userDetails?['hometown'] != null)
              _buildDetailRow(
                icon: Icons.location_city,
                label: 'Hometown',
                value: userDetails!['hometown'],
              ),
            if (_shouldShowField('bio') && userDetails?['bio'] != null)
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
    );
  }

  Widget _buildDetailRow({
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
