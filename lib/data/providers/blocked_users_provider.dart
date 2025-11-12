import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hopin/data/models/blocked_user_model.dart';
import 'package:hopin/data/services/blocked_users_service.dart';

class BlockedUsersProvider extends ChangeNotifier {
  final BlockedUsersService _service = BlockedUsersService();

  List<BlockedUser> _blockedUsers = [];
  List<BlockedUser> _allUsers = [];
  List<BlockedUser> _filteredBlockedUsers = [];
  List<BlockedUser> _filteredAllUsers = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<BlockedUser> get blockedUsers => _blockedUsers;
  List<BlockedUser> get allUsers => _allUsers;
  List<BlockedUser> get filteredBlockedUsers => _filteredBlockedUsers;
  List<BlockedUser> get filteredAllUsers => _filteredAllUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBlockedUsers() async {
    _setLoading(true);
    _clearError();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _setError('User not authenticated');
        return;
      }

      _blockedUsers = await _service.getBlockedUsers(uid);
      _applySearchFilter();
    } catch (e) {
      _setError('Failed to load blocked users: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllUsers() async {
    _setLoading(true);
    _clearError();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _setError('User not authenticated');
        return;
      }

      _allUsers = await _service.getAllUsers(uid);
      _applySearchFilter();
    } catch (e) {
      _setError('Failed to load users: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> blockUser(BlockedUser user) async {
    _setLoading(true);
    _clearError();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _setError('User not authenticated');
        return false;
      }

      final success = await _service.blockUser(uid, user);
      if (success) {
        _blockedUsers.add(user.copyWith(blockedAt: DateTime.now()));
        _applySearchFilter();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to block user: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> unblockUser(String blockedUserId) async {
    _setLoading(true);
    _clearError();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _setError('User not authenticated');
        return false;
      }

      final success = await _service.unblockUser(uid, blockedUserId);
      if (success) {
        _blockedUsers.removeWhere((user) => user.uid == blockedUserId);
        _applySearchFilter();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to unblock user: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  bool isUserBlocked(String userId) {
    return _blockedUsers.any((user) => user.uid == userId);
  }

  void searchUsers(String query) {
    _searchQuery = query.toLowerCase();
    _applySearchFilter();
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredBlockedUsers = List.from(_blockedUsers);
      _filteredAllUsers = List.from(_allUsers);
    } else {
      _filteredBlockedUsers = _blockedUsers.where((user) {
        return user.name.toLowerCase().contains(_searchQuery) ||
            user.email.toLowerCase().contains(_searchQuery) ||
            (user.department?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();

      _filteredAllUsers = _allUsers.where((user) {
        return user.name.toLowerCase().contains(_searchQuery) ||
            user.email.toLowerCase().contains(_searchQuery) ||
            (user.department?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
