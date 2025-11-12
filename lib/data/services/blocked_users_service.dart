import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hopin/data/models/blocked_user_model.dart';

class BlockedUsersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<BlockedUser>> getBlockedUsers(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('blockedUsers')
          .orderBy('blockedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BlockedUser.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<BlockedUser>> getAllUsers(String currentUid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, isNotEqualTo: currentUid)
          .limit(100)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return BlockedUser.fromMap(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> blockUser(String uid, BlockedUser userToBlock) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('blockedUsers')
          .doc(userToBlock.uid)
          .set(userToBlock.toMap());

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unblockUser(String uid, String blockedUserId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('blockedUsers')
          .doc(blockedUserId)
          .delete();

      return true;
    } catch (e) {
      print('Error unblocking user: $e');
      return false;
    }
  }

  Future<bool> isUserBlocked(String uid, String otherUserId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('blockedUsers')
          .doc(otherUserId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking if user is blocked: $e');
      return false;
    }
  }

  Future<List<String>> getBlockedUserIds(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('blockedUsers')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> getBlockedUsersCount(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('blockedUsers')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
