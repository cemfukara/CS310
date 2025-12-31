import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class FriendsProvider with ChangeNotifier {
  DatabaseService _db;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FriendsProvider(this._db);

  void updateDatabase(DatabaseService db) {
    _db = db;
    notifyListeners();
  }

  // expose streams directly
  Stream<List<UserModel>> get friendsStream => _db.getFriendsStream();
  Stream<List<UserModel>> get requestsStream => _db.getFriendRequestsStream();

  // --- ACTIONS ---
  Future<String?> sendRequest(String email) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return "Not logged in";

      if (email.trim().toLowerCase() == currentUser.email?.toLowerCase()) {
        return "You cannot add yourself";
      }

      final targetUser = await _db.searchUserByEmail(email.trim());
      if (targetUser == null) return "User not found";

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
}
