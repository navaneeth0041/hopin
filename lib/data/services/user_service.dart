import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hopin/data/models/home/emergency_contact_model.dart';
import 'package:hopin/data/services/image_cache_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImageCacheService _imageCache = ImageCacheService();

  Future<Map<String, dynamic>> addEmergencyContact(
    String uid,
    EmergencyContact contact,
  ) async {
    try {
      final contacts = await getEmergencyContacts(uid);

      if (contacts.length >= 5) {
        return {
          'success': false,
          'error': 'Maximum 5 emergency contacts allowed',
        };
      }

      bool shouldBePrimary = contacts.isEmpty || contact.isPrimary;

      if (shouldBePrimary) {
        await _updateAllContactsPrimaryStatus(uid, contacts, false);
      }

      final newContact = contact.copyWith(isPrimary: shouldBePrimary);

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('emergencyContacts')
          .doc(contact.id)
          .set(newContact.toMap());

      return {'success': true, 'contact': newContact};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<List<EmergencyContact>> getEmergencyContacts(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('emergencyContacts')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => EmergencyContact.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<EmergencyContact?> getPrimaryEmergencyContact(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('emergencyContacts')
          .where('isPrimary', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return EmergencyContact.fromMap(snapshot.docs.first.data());
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateEmergencyContact(
    String uid,
    EmergencyContact contact,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('emergencyContacts')
          .doc(contact.id)
          .update(contact.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setPrimaryContact(String uid, String contactId) async {
    try {
      final contacts = await getEmergencyContacts(uid);
      final batch = _firestore.batch();

      for (var contact in contacts) {
        final docRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('emergencyContacts')
            .doc(contact.id);
        batch.update(docRef, {'isPrimary': contact.id == contactId});
      }

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteEmergencyContact(String uid, String contactId) async {
    try {
      final contact = await _firestore
          .collection('users')
          .doc(uid)
          .collection('emergencyContacts')
          .doc(contactId)
          .get();

      if (!contact.exists) return false;

      final wasPrimary = contact.data()?['isPrimary'] ?? false;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('emergencyContacts')
          .doc(contactId)
          .delete();

      if (wasPrimary) {
        final remainingContacts = await getEmergencyContacts(uid);
        if (remainingContacts.isNotEmpty) {
          await setPrimaryContact(uid, remainingContacts.first.id);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _updateAllContactsPrimaryStatus(
    String uid,
    List<EmergencyContact> contacts,
    bool isPrimary,
  ) async {
    final batch = _firestore.batch();

    for (var contact in contacts) {
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('emergencyContacts')
          .doc(contact.id);
      batch.update(docRef, {'isPrimary': isPrimary});
    }

    await batch.commit();
  }

  Future<Map<String, dynamic>> getSosSettings(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('preferences')
          .doc('sosSettings')
          .get();

      if (doc.exists) {
        return doc.data() ?? {'sosEnabled': true, 'autoShareLocation': true};
      }

      return {'sosEnabled': true, 'autoShareLocation': true};
    } catch (e) {
      return {'sosEnabled': true, 'autoShareLocation': true};
    }
  }

  Future<bool> updateSosSettings(
    String uid, {
    required bool sosEnabled,
    required bool autoShareLocation,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('preferences')
          .doc('sosSettings')
          .set({
            'sosEnabled': sosEnabled,
            'autoShareLocation': autoShareLocation,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> storeProfileImageAsBase64(String uid, File imageFile) async {
    try {
      final base64String = await _imageCache.imageToBase64(imageFile);
      if (base64String == null) return null;

      await _imageCache.saveToLocalFile(base64String, uid);

      return base64String;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteProfileImageBase64(String uid) async {
    try {
      _imageCache.clearUserCache(uid);
      await _imageCache.deleteLocalFile(uid);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUserProfile(
    String uid,
    Map<String, dynamic> updates, {
    File? profileImage,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (profileImage != null) {
        final base64String = await storeProfileImageAsBase64(uid, profileImage);
        if (base64String != null) {
          updateData['details.profileImageBase64'] = base64String;
          updateData['details.profileImagePath'] = profileImage.path;
        }
      }

      if (updates.containsKey('removeProfileImage') &&
          updates['removeProfileImage'] == true) {
        await deleteProfileImageBase64(uid);
        updateData['details.profileImageBase64'] = FieldValue.delete();
        updateData['details.profileImagePath'] = FieldValue.delete();
      }

      if (updates.containsKey('fullName')) {
        updateData['details.fullName'] = updates['fullName'];
      }
      if (updates.containsKey('phoneNumber')) {
        updateData['details.phoneNumber'] = updates['phoneNumber'];
      }
      if (updates.containsKey('studentId')) {
        updateData['details.studentId'] = updates['studentId'];
      }

      final optionalFields = [
        'gender',
        'dateOfBirth',
        'department',
        'year',
        'hostel',
        'roomNumber',
        'hometown',
        'bio',
      ];

      for (var field in optionalFields) {
        if (updates.containsKey(field)) {
          if (updates[field] != null) {
            updateData['details.$field'] = updates[field];
          } else {
            updateData['details.$field'] = FieldValue.delete();
          }
        }
      }

      updateData['details.lastUpdated'] = FieldValue.serverTimestamp();

      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updateData);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return {'success': false, 'error': 'No user is currently signed in'};
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return {'success': true, 'message': 'Password changed successfully'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _handlePasswordChangeError(e)};
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  String _handlePasswordChangeError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
        return 'Current password is incorrect';
      case 'weak-password':
        return 'New password is too weak';
      case 'requires-recent-login':
        return 'Please log out and log in again before changing password';
      default:
        return 'Failed to change password: ${e.message}';
    }
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  bool isUserAuthenticated() {
    return _auth.currentUser != null;
  }
}
