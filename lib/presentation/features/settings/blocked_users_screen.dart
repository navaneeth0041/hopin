// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/providers/blocked_users_provider.dart';
import 'package:hopin/data/models/blocked_user_model.dart';
import 'package:hopin/data/services/image_cache_service.dart';
import 'package:provider/provider.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ImageCacheService _imageCache = ImageCacheService();
  bool _showAllUsers = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<BlockedUsersProvider>(context, listen: false);
    await provider.loadBlockedUsers();
    if (_showAllUsers) {
      await provider.loadAllUsers();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildProfileAvatar(BlockedUser user, {double radius = 28}) {
    // Check if profile picture should be shown based on privacy settings
    if (user.privacySettings != null &&
        !user.privacySettings!.showProfilePicture) {
      return _buildDefaultAvatar(radius);
    }

    if (user.profileImageBase64 != null &&
        user.profileImageBase64!.isNotEmpty) {
      try {
        final image = _imageCache.getCachedImage(
          user.uid,
          user.profileImageBase64,
        );
        if (image != null) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: const Color(0xFF2C2C2E),
            child: ClipOval(
              child: SizedBox(
                width: radius * 2,
                height: radius * 2,
                child: image,
              ),
            ),
          );
        }
      } catch (e) {
        print('Error displaying base64 image: $e');
      }
    }

    return _buildDefaultAvatar(radius);
  }

  Widget _buildDefaultAvatar(double radius) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF2C2C2E),
      child: Icon(Icons.person, color: AppColors.textSecondary, size: radius),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildToggleButton(),
            Expanded(child: _buildUserList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
            'Blocked Users',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Search users...',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: AppColors.textSecondary),
          ),
          onChanged: (value) {
            final provider = Provider.of<BlockedUsersProvider>(
              context,
              listen: false,
            );
            provider.searchUsers(value);
          },
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _showAllUsers = false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !_showAllUsers
                        ? AppColors.primaryYellow
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Blocked',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: !_showAllUsers
                            ? Colors.black
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _showAllUsers = true);
                  _loadData();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _showAllUsers
                        ? AppColors.primaryYellow
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'All Users',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _showAllUsers
                            ? Colors.black
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return Consumer<BlockedUsersProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryYellow),
          );
        }

        final users = _showAllUsers
            ? provider.filteredAllUsers
            : provider.filteredBlockedUsers;

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showAllUsers ? Icons.people_outline : Icons.block,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  _showAllUsers ? 'No users found' : 'No blocked users',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserCard(user, provider);
          },
        );
      },
    );
  }

  Widget _buildUserCard(BlockedUser user, BlockedUsersProvider provider) {
    final isBlocked = provider.isUserBlocked(user.uid);

    return GestureDetector(
      onTap: () => _showUserDetailsBottomSheet(user, provider),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: isBlocked
              ? Border.all(color: Colors.red.withOpacity(0.3), width: 1)
              : Border.all(color: AppColors.divider, width: 1),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                _buildProfileAvatar(user),
                if (isBlocked)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cardBackground,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.block,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetailsBottomSheet(
    BlockedUser user,
    BlockedUsersProvider provider,
  ) {
    final isBlocked = provider.isUserBlocked(user.uid);
    final privacy = user.privacySettings;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
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
                    'User Details',
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
                      children: [
                        _buildProfileAvatar(user, radius: 50),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _buildDetailSection(
                          title: 'Contact Information',
                          icon: Icons.contact_mail,
                          children: [
                            _buildDetailRow(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: user.email,
                            ),
                            if (user.phone != null)
                              _buildDetailRow(
                                icon: Icons.phone_outlined,
                                label: 'Phone',
                                value: user.phone!,
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_hasVisibleAcademicInfo(user, privacy))
                          _buildDetailSection(
                            title: 'Academic Information',
                            icon: Icons.school_outlined,
                            children: _buildAcademicInfoRows(user, privacy),
                          ),
                        if (_hasVisiblePersonalInfo(user, privacy)) ...[
                          const SizedBox(height: 16),
                          _buildDetailSection(
                            title: 'Personal Information',
                            icon: Icons.person_outline,
                            children: _buildPersonalInfoRows(user, privacy),
                          ),
                        ],
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _handleBlockUnblock(user, isBlocked, provider);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isBlocked
                                  ? AppColors.primaryYellow
                                  : Colors.red.withOpacity(0.1),
                              foregroundColor: isBlocked
                                  ? Colors.black
                                  : Colors.red[400],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: isBlocked
                                    ? BorderSide.none
                                    : BorderSide(
                                        color: Colors.red.withOpacity(0.5),
                                        width: 1,
                                      ),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isBlocked
                                      ? Icons.check_circle_outline
                                      : Icons.block,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isBlocked ? 'Unblock User' : 'Block User',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
      ),
    );
  }

  bool _hasVisibleAcademicInfo(BlockedUser user, dynamic privacy) {
    if (privacy == null) return user.department != null || user.year != null;

    return (user.department != null && privacy.showDepartment) ||
        (user.year != null && privacy.showYear);
  }

  bool _hasVisiblePersonalInfo(BlockedUser user, dynamic privacy) {
    if (privacy == null) {
      return user.gender != null ||
          user.dateOfBirth != null ||
          user.hostel != null ||
          user.roomNumber != null ||
          user.hometown != null ||
          user.bio != null;
    }

    return (user.gender != null && privacy.showGender) ||
        (user.dateOfBirth != null && privacy.showDateOfBirth) ||
        (user.hostel != null && privacy.showHostel) ||
        (user.roomNumber != null && privacy.showRoomNumber) ||
        (user.hometown != null && privacy.showHometown) ||
        (user.bio != null && privacy.showBio);
  }

  List<Widget> _buildAcademicInfoRows(BlockedUser user, dynamic privacy) {
    List<Widget> rows = [];

    if (user.department != null &&
        (privacy == null || privacy.showDepartment)) {
      rows.add(_buildDetailRow(
        icon: Icons.business_outlined,
        label: 'Department',
        value: user.department!,
      ));
    }

    if (user.year != null && (privacy == null || privacy.showYear)) {
      rows.add(_buildDetailRow(
        icon: Icons.calendar_today_outlined,
        label: 'Year',
        value: user.year!,
      ));
    }

    return rows;
  }

  List<Widget> _buildPersonalInfoRows(BlockedUser user, dynamic privacy) {
    List<Widget> rows = [];

    if (user.gender != null && (privacy == null || privacy.showGender)) {
      rows.add(_buildDetailRow(
        icon: Icons.wc_outlined,
        label: 'Gender',
        value: user.gender!,
      ));
    }

    if (user.dateOfBirth != null &&
        (privacy == null || privacy.showDateOfBirth)) {
      rows.add(_buildDetailRow(
        icon: Icons.cake_outlined,
        label: 'Date of Birth',
        value: user.dateOfBirth!,
      ));
    }

    if (user.hostel != null && (privacy == null || privacy.showHostel)) {
      rows.add(_buildDetailRow(
        icon: Icons.home_outlined,
        label: 'Hostel',
        value: user.hostel!,
      ));
    }

    if (user.roomNumber != null &&
        (privacy == null || privacy.showRoomNumber)) {
      rows.add(_buildDetailRow(
        icon: Icons.meeting_room_outlined,
        label: 'Room Number',
        value: user.roomNumber!,
      ));
    }

    if (user.hometown != null && (privacy == null || privacy.showHometown)) {
      rows.add(_buildDetailRow(
        icon: Icons.location_city_outlined,
        label: 'Hometown',
        value: user.hometown!,
      ));
    }

    if (user.bio != null && (privacy == null || privacy.showBio)) {
      rows.add(_buildDetailRow(
        icon: Icons.description_outlined,
        label: 'Bio',
        value: user.bio!,
      ));
    }

    return rows;
  }

  Widget _buildDetailSection({
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
                  style: const TextStyle(
                    fontSize: 15,
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

  Future<void> _handleBlockUnblock(
    BlockedUser user,
    bool isBlocked,
    BlockedUsersProvider provider,
  ) async {
    if (isBlocked) {
      final success = await provider.unblockUser(user.uid);
      if (success && mounted) {
        _showCustomSnackBar(
          '${user.name} has been unblocked',
          Colors.green,
          Icons.check_circle,
        );
      }
    } else {
      final confirmed = await _showBlockConfirmationDialog(user.name);

      if (confirmed == true && mounted) {
        final success = await provider.blockUser(user);
        if (success && mounted) {
          _showCustomSnackBar(
            '${user.name} has been blocked',
            Colors.red,
            Icons.block,
          );
        }
      }
    }
  }

  Future<bool?> _showBlockConfirmationDialog(String userName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.block, size: 40, color: Colors.red[400]),
              ),
              const SizedBox(height: 20),
              const Text(
                'Block User',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to block $userName?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.darkBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Block',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}