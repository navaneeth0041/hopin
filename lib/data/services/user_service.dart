import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hopin/data/models/home/emergency_contact_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
      print('Error adding emergency contact: $e');
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
      print('Error fetching emergency contacts: $e');
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
      print('Error fetching primary contact: $e');
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
      print('Error updating emergency contact: $e');
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
      print('Error setting primary contact: $e');
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
      print('Error deleting emergency contact: $e');
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
      print('Error fetching SOS settings: $e');
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
      print('Error updating SOS settings: $e');
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
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<String?> uploadProfileImage(String uid, File imageFile) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');

      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploaded-by': uid,
            'uploaded-at': DateTime.now().toIso8601String(),
          },
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  Future<bool> deleteProfileImage(String uid) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting profile image: $e');
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
        final imageUrl = await uploadProfileImage(uid, profileImage);
        if (imageUrl != null) {
          updateData['details.profileImageUrl'] = imageUrl;
          updateData['details.profileImagePath'] = profileImage.path;
        }
      }

      if (updates.containsKey('removeProfileImage') &&
          updates['removeProfileImage'] == true) {
        await deleteProfileImage(uid);
        updateData['details.profileImageUrl'] = FieldValue.delete();
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

      if (updates.containsKey('gender')) {
        if (updates['gender'] != null) {
          updateData['details.gender'] = updates['gender'];
        } else {
          updateData['details.gender'] = FieldValue.delete();
        }
      }

      if (updates.containsKey('dateOfBirth')) {
        if (updates['dateOfBirth'] != null) {
          updateData['details.dateOfBirth'] = updates['dateOfBirth'];
        } else {
          updateData['details.dateOfBirth'] = FieldValue.delete();
        }
      }

      if (updates.containsKey('department')) {
        if (updates['department'] != null) {
          updateData['details.department'] = updates['department'];
        } else {
          updateData['details.department'] = FieldValue.delete();
        }
      }

      if (updates.containsKey('year')) {
        if (updates['year'] != null) {
          updateData['details.year'] = updates['year'];
        } else {
          updateData['details.year'] = FieldValue.delete();
        }
      }

      if (updates.containsKey('hostel')) {
        if (updates['hostel'] != null) {
          updateData['details.hostel'] = updates['hostel'];
        } else {
          updateData['details.hostel'] = FieldValue.delete();
        }
      }

      if (updates.containsKey('roomNumber')) {
        if (updates['roomNumber'] != null) {
          updateData['details.roomNumber'] = updates['roomNumber'];
        } else {
          updateData['details.roomNumber'] = FieldValue.delete();
        }
      }

      if (updates.containsKey('hometown')) {
        if (updates['hometown'] != null) {
          updateData['details.hometown'] = updates['hometown'];
        } else {
          updateData['details.hometown'] = FieldValue.delete();
        }
      }

      if (updates.containsKey('bio')) {
        if (updates['bio'] != null) {
          updateData['details.bio'] = updates['bio'];
        } else {
          updateData['details.bio'] = FieldValue.delete();
        }
      }

      if (updates.containsKey('profileImagePath') && profileImage == null) {
        updateData['details.profileImagePath'] = updates['profileImagePath'];
      }
      if (updates.containsKey('profileImageUrl') && profileImage == null) {
        updateData['details.profileImageUrl'] = updates['profileImageUrl'];
      }

      updateData['details.lastUpdated'] = FieldValue.serverTimestamp();

      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updateData);
      }

      return true;
    } catch (e) {
      print('Error updating user profile: $e');
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

  Future<String?> getProfileImageUrl(String uid) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting profile image URL: $e');
      return null;
    }
  }
}
