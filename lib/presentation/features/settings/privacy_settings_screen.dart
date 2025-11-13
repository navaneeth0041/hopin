import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/providers/privacy_provider.dart';
import 'package:provider/provider.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPrivacySettings();
    });
  }

  Future<void> _loadPrivacySettings() async {
    final provider = Provider.of<PrivacyProvider>(context, listen: false);
    await provider.loadPrivacySettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Consumer<PrivacyProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryYellow),
              );
            }

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Profile Visibility'),
                        const SizedBox(height: 12),
                        _buildVisibilityCard(provider),
                        const SizedBox(height: 32),
                        _buildSectionTitle('What Others Can See'),
                        const SizedBox(height: 12),
                        _buildPrivacyOptions(provider),
                        const SizedBox(height: 32),
                        _buildSaveButton(provider),
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
            'Privacy & Data',
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

  Widget _buildInfoCard() {
    return Container(
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.privacy_tip_outlined,
              color: AppColors.primaryYellow,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Control Your Privacy',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose what information other users can see about you',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildVisibilityCard(PrivacyProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: provider.settings.profileVisible
                      ? AppColors.primaryYellow.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  provider.settings.profileVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: provider.settings.profileVisible
                      ? AppColors.primaryYellow
                      : Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Visibility',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Make your profile visible to other users',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: provider.settings.profileVisible,
                onChanged: (value) {
                  provider.updateProfileVisibility(value);
                },
                activeColor: AppColors.primaryYellow,
                activeTrackColor: AppColors.primaryYellow.withOpacity(0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOptions(PrivacyProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        children: [
          _buildPrivacyOption(
            icon: Icons.person_outline,
            title: 'Profile Picture',
            subtitle: 'Show your profile photo',
            value: provider.settings.showProfilePicture,
            onChanged: provider.updateShowProfilePicture,
          ),
          const Divider(color: AppColors.divider, height: 1, indent: 56),
          _buildPrivacyOption(
            icon: Icons.wc_outlined,
            title: 'Gender',
            subtitle: 'Show your gender',
            value: provider.settings.showGender,
            onChanged: provider.updateShowGender,
          ),
          const Divider(color: AppColors.divider, height: 1, indent: 56),
          _buildPrivacyOption(
            icon: Icons.cake_outlined,
            title: 'Date of Birth',
            subtitle: 'Show your date of birth',
            value: provider.settings.showDateOfBirth,
            onChanged: provider.updateShowDateOfBirth,
          ),
          const Divider(color: AppColors.divider, height: 1, indent: 56),
          _buildPrivacyOption(
            icon: Icons.business_outlined,
            title: 'Department',
            subtitle: 'Show your department',
            value: provider.settings.showDepartment,
            onChanged: provider.updateShowDepartment,
          ),
          const Divider(color: AppColors.divider, height: 1, indent: 56),
          _buildPrivacyOption(
            icon: Icons.calendar_today_outlined,
            title: 'Year',
            subtitle: 'Show your academic year',
            value: provider.settings.showYear,
            onChanged: provider.updateShowYear,
          ),
          const Divider(color: AppColors.divider, height: 1, indent: 56),
          _buildPrivacyOption(
            icon: Icons.home_outlined,
            title: 'Hostel',
            subtitle: 'Show your hostel information',
            value: provider.settings.showHostel,
            onChanged: provider.updateShowHostel,
          ),
          const Divider(color: AppColors.divider, height: 1, indent: 56),
          _buildPrivacyOption(
            icon: Icons.meeting_room_outlined,
            title: 'Room Number',
            subtitle: 'Show your room number',
            value: provider.settings.showRoomNumber,
            onChanged: provider.updateShowRoomNumber,
          ),
          const Divider(color: AppColors.divider, height: 1, indent: 56),
          _buildPrivacyOption(
            icon: Icons.location_city_outlined,
            title: 'Hometown',
            subtitle: 'Show your hometown',
            value: provider.settings.showHometown,
            onChanged: provider.updateShowHometown,
          ),
          const Divider(color: AppColors.divider, height: 1, indent: 56),
          _buildPrivacyOption(
            icon: Icons.description_outlined,
            title: 'Bio',
            subtitle: 'Show your bio',
            value: provider.settings.showBio,
            onChanged: provider.updateShowBio,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primaryYellow.withOpacity(0.1)
                  : AppColors.darkBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.primaryYellow : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryYellow,
            activeTrackColor: AppColors.primaryYellow.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(PrivacyProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: provider.hasUnsavedChanges
            ? () async {
                final success = await provider.savePrivacySettings();
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          const Text(
                            'Privacy settings saved successfully',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: provider.hasUnsavedChanges
              ? AppColors.primaryYellow
              : AppColors.primaryYellow.withOpacity(0.3),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: provider.isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}