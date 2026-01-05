import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = FirestoreService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.authStateChanges.listen((User? newUser) {
      _user = newUser;
      notifyListeners();
    });
  }

  // --- NEW: Refresh User Method ---
  Future<void> refreshUser() async {
    if (_user != null) {
      await _user!.reload(); // Ask Firebase for the latest data (Name, etc.)
      _user = _authService.currentUser; // Update local reference
      notifyListeners(); // Update the UI
    }
  }
  // --------------------------------

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Sign Up Action
  Future<bool> signUp(String email, String password) async {
    // REMOVED: _setLoading(true); to prevent unmounting UI
    _setMessage(null);
    try {
      await _authService.signUp(email: email, password: password);

      // reset last tab to 0, so it starts from the home screen
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_tab', 0);

      // REMOVED: _setLoading(false);
      return true;
    } catch (e) {
      _setMessage(e.toString());
      // REMOVED: _setLoading(false);
      return false;
    }
  }

  // Login Action
  Future<bool> login(String email, String password) async {
    // REMOVED: _setLoading(true); to prevent unmounting UI
    _setMessage(null);
    try {
      await _authService.signIn(email: email, password: password);

      // reset last tab to 0, so it starts from the home screen
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_tab', 0);

      // REMOVED: _setLoading(false);
      return true;
    } catch (e) {
      _setMessage(e.toString());
      // REMOVED: _setLoading(false);
      return false;
    }
  }

  // Logout Action
  Future<void> logout() async {
    await _authService.signOut();
    _setMessage(null);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Update Profile Name
  Future<bool> updateProfile(String name) async {
    _setMessage(null);
    try {
      await _authService.updateDisplayName(name);
      await _dbService.updateUserPublicProfile(displayName: name);
      await refreshUser();
      return true;
    } catch (e) {
      _setMessage(e.toString());
      return false;
    }
  }

  // Update Email
  Future<bool> updateEmail(String newEmail, String password) async {
    _setMessage(null);
    try {
      await _authService.updateEmail(newEmail: newEmail, password: password);
      await _dbService.updateUserPublicProfile(email: newEmail);
      await refreshUser();
      return true;
    } catch (e) {
      _setMessage(e.toString());
      return false;
    }
  }

  // Update Password
  Future<bool> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _setMessage(null);
    try {
      await _authService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _setMessage(e.toString());
      return false;
    }
  }
}
