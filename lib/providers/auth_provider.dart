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
    // Listen to Firebase Auth changes in real-time
    _authService.authStateChanges.listen((User? newUser) {
      _user = newUser;
      notifyListeners();
    });
  }

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
      return true; // Success
    } catch (e) {
      _setMessage(e.toString());
      _setLoading(false);
      return false; // Failure
    }
  }

  // Login Action
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setMessage(null);
    try {
      await _authService.signIn(email: email, password: password);
      _setLoading(false);
      return true; // Success
    } catch (e) {
      _setMessage(e.toString());
      _setLoading(false);
      return false; // Failure
    }
  }

  // Logout Action
  Future<void> logout() async {
    await _authService.signOut();
    _setMessage(null);
  }

  // Clear errors manually if needed
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}