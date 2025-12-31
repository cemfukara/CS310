import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class FriendsProvider with ChangeNotifier {
  final DatabaseService _db;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<UserModel> _friends = [];
  List<UserModel> _requests = [];
  bool _isLoading = false;

  StreamSubscription? _friendsSub;
  StreamSubscription? _requestsSub;

  FriendsProvider(this._db) {
    _initStreams();
  }

  List<UserModel> get friends => _friends;
  List<UserModel> get requests => _requests;
  bool get isLoading => _isLoading;

  void _initStreams() {
    _isLoading = true;
    notifyListeners();

    _friendsSub?.cancel();
    _friendsSub = _db.getFriendsStream().listen((data) {
      _friends = data;
      _isLoading = false;
      notifyListeners();
    });

    _requestsSub?.cancel();
    _requestsSub = _db.getFriendRequestsStream().listen((data) {
      _requests = data;
      notifyListeners();
    });
  }

  // --- ACTIONS ---

  Future<String?> sendRequest(String email) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return "Not logged in";
      if (email.trim().toLowerCase() == currentUser.email?.toLowerCase())
        return "You cannot add yourself";

      // 1. Search for user
      final targetUser = await _db.searchUserByEmail(email.trim());
      if (targetUser == null) return "User not found";

      // 2. Check if already friends (simple check)
      if (_friends.any((f) => f.uid == targetUser.uid))
        return "Already friends";

      // 3. Send Request
      await _db.sendFriendRequest(
        currentUser.uid,
        currentUser.displayName ?? 'Unknown',
        currentUser.email ?? '',
        targetUser.uid,
      );
      return null; // Success
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<void> acceptRequest(UserModel request) async {
    final currentUser = _auth.currentUser;
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
    final currentUser = _auth.currentUser;
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
