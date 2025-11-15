import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Map<String, dynamic>> signUpWithEmailPassword({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.sendEmailVerification();

      await _createUserDocument(userCredential.user!.uid, userData);

      return {
        'success': true,
        'user': userCredential.user,
        'message': 'Account created successfully. Please verify your email.',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _handleAuthException(e)};
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        return {
          'success': false,
          'error': 'Please verify your email before logging in.',
          'needsVerification': true,
        };
      }

      return {'success': true, 'user': userCredential.user};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _handleAuthException(e)};
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent successfully.',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _handleAuthException(e)};
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return {'success': true, 'message': 'Verification email sent.'};
      }
      return {
        'success': false,
        'error': 'User is already verified or not logged in.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to send verification email: ${e.toString()}',
      };
    }
  }

  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> _createUserDocument(
    String uid,
    Map<String, dynamic> userData,
  ) async {
    await _firestore.collection('users').doc(uid).set({
      'details': {
        'fullName': userData['fullName'],
        'email': userData['email'],
        'studentId': userData['studentId'],
        'phoneNumber': userData['phoneNumber'],
        'profileImageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      },
      'emergencyContact': {
        'name': userData['emergencyName'],
        'phoneNumber': userData['emergencyPhone'],
      },
      'preferences': {
        'notificationsEnabled': true,
        'locationSharingEnabled': false,
      },
      'stats': {
        'ridesCompleted': 0,
        'ridesOffered': 0,
        'rating': 0.0,
        'totalRatings': 0,
      },
    });
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...data,
        'details.lastUpdated': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
