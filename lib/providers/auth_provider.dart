import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

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
    _setLoading(true);
    _setMessage(null);
    try {
      await _authService.signUp(email: email, password: password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Login Action
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setMessage(null);
    try {
      await _authService.signIn(email: email, password: password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setMessage(e.toString());
      _setLoading(false);
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
}