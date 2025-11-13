import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hopin/data/models/privacy_settings_model.dart';

class PrivacyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<PrivacySettings> getPrivacySettings(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('preferences')
          .doc('privacy')
          .get();

      if (doc.exists) {
        return PrivacySettings.fromMap(doc.data()!);
      }

      // Return default settings if document doesn't exist
      return PrivacySettings();
    } catch (e) {
      print('Error getting privacy settings: $e');
      return PrivacySettings();
    }
  }

  Future<bool> updatePrivacySettings(
    String uid,
    PrivacySettings settings,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('preferences')
          .doc('privacy')
          .set(
            settings.toMap(),
            SetOptions(merge: true),
          );

      return true;
    } catch (e) {
      print('Error updating privacy settings: $e');
      return false;
    }
  }

  Future<Map<String, PrivacySettings>> getBatchPrivacySettings(
    List<String> userIds,
  ) async {
    try {
      final Map<String, PrivacySettings> settingsMap = {};

      // Firestore has a limit of 10 items per 'in' query, so we batch
      for (int i = 0; i < userIds.length; i += 10) {
        final batch = userIds.skip(i).take(10).toList();

        for (final uid in batch) {
          final settings = await getPrivacySettings(uid);
          settingsMap[uid] = settings;
        }
      }

      return settingsMap;
    } catch (e) {
      print('Error getting batch privacy settings: $e');
      return {};
    }
  }

  Future<bool> isFieldVisible(String uid, String fieldName) async {
    try {
      final settings = await getPrivacySettings(uid);

      switch (fieldName) {
        case 'profilePicture':
          return settings.showProfilePicture;
        case 'gender':
          return settings.showGender;
        case 'dateOfBirth':
          return settings.showDateOfBirth;
        case 'department':
          return settings.showDepartment;
        case 'year':
          return settings.showYear;
        case 'hostel':
          return settings.showHostel;
        case 'roomNumber':
          return settings.showRoomNumber;
        case 'hometown':
          return settings.showHometown;
        case 'bio':
          return settings.showBio;
        default:
          return true;
      }
    } catch (e) {
      print('Error checking field visibility: $e');
      return true; // Default to visible on error
    }
  }
}