import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';

class FriendsProvider with ChangeNotifier {
  AuthProvider _authProvider; // Fix: Inject AuthProvider
  DatabaseService _db; // Fix: Inject DatabaseService

  List<UserModel> _friends = [];
  List<UserModel> _requests = [];
  bool _isLoading = false;

  StreamSubscription? _friendsSub;
  StreamSubscription? _requestsSub;

  FriendsProvider(this._authProvider, this._db) {
    _initStreams();
  }

  // --- FIX: Setter for ProxyProvider ---
  void update(AuthProvider auth, DatabaseService db) {
    _authProvider = auth;
    _db = db;
    // We re-init streams in case the user logged in/out
    _initStreams();
  }

  List<UserModel> get friends => _friends;
  List<UserModel> get requests => _requests;
  bool get isLoading => _isLoading;

  void _initStreams() {
    // Fix: Get user from injected provider, not FirebaseAuth directly
    final user = _authProvider.user;

    _friendsSub?.cancel();
    _requestsSub?.cancel();

    if (user == null) {
      _friends = [];
      _requests = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    // Use Future.microtask to avoid "notifyListeners during build" error
    Future.microtask(() => notifyListeners());

    _friendsSub = _db.getFriendsStream().listen((data) {
      _friends = data;
      _isLoading = false;
      notifyListeners();
    });

    _requestsSub = _db.getFriendRequestsStream().listen((data) {
      _requests = data;
      notifyListeners();
    });
  }

  Future<String?> sendRequest(String email) async {
    try {
      final currentUser = _authProvider.user; // Fix: Use injected user
      if (currentUser == null) return "Not logged in";

      // Fix: Check if adding self by email
      if (email.trim().toLowerCase() == currentUser.email?.toLowerCase()) {
        return "You cannot add yourself";
      }

      final targetUser = await _db.searchUserByEmail(email.trim());
      if (targetUser == null) return "User not found";

      // Fix: Check if adding self by UID (double check)
      if (targetUser.uid == currentUser.uid) {
        return "You cannot add yourself";
      }

      if (_friends.any((f) => f.uid == targetUser.uid)) {
        return "Already friends";
      }

      await _db.sendFriendRequest(
        currentUser.uid,
        currentUser.displayName ?? 'Unknown',
        currentUser.email ?? '',
        targetUser.uid,
      );
      return null;
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<void> acceptRequest(UserModel request) async {
    final currentUser = _authProvider.user;
    if (currentUser == null) return;

    await _db.acceptFriendRequest(
      currentUser.uid,
      currentUser.displayName ?? 'Unknown',
      currentUser.email ?? '',
      request.uid,
      request.displayName,
      request.email,
    );
  }

  Future<void> declineRequest(String requestUid) async {
    final currentUser = _authProvider.user;
    if (currentUser == null) return;

    await _db.declineFriendRequest(currentUser.uid, requestUid);
  }

  @override
  void dispose() {
    _friendsSub?.cancel();
    _requestsSub?.cancel();
    super.dispose();
  }
}
