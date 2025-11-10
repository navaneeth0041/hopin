import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfile _userProfile = UserProfile(
    name: 'Laaal Singh',
    email: 'laal_jodhil@am.amrita.edu',
    studentId: 'AM.EN.U4CSE21001',
    phone: '9876543210',
    department: 'Computer Science',
    yearOfStudy: '3rd Year',
    emergencyContactName: 'Jane Doe',
    emergencyContactPhone: '9876543211',
    emergencyContactRelation: 'Mother',
  );

  UserProfile get userProfile => _userProfile;
  int get completionPercentage => _userProfile.completionPercentage;

  // Initialize and load saved profile
  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('user_profile');
      
      if (profileJson != null) {
        final Map<String, dynamic> profileData = json.decode(profileJson);
        _userProfile = UserProfile.fromJson(profileData);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  // Update profile
  Future<void> updateProfile(UserProfile newProfile) async {
    try {
      _userProfile = newProfile;
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final profileJson = json.encode(_userProfile.toJson());
      await prefs.setString('user_profile', profileJson);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      throw Exception('Failed to update profile');
    }
  }

  // Update profile image
  Future<void> updateProfileImage(String? imagePath) async {
    try {
      _userProfile = _userProfile.copyWith(profileImagePath: imagePath);
      
      final prefs = await SharedPreferences.getInstance();
      final profileJson = json.encode(_userProfile.toJson());
      await prefs.setString('user_profile', profileJson);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile image: $e');
      throw Exception('Failed to update profile image');
    }
  }

  // Clear profile (logout)
  Future<void> clearProfile() async {
    try {
      _userProfile = UserProfile.empty();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_profile');
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing profile: $e');
    }
  }
}