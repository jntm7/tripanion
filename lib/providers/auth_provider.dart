import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// AuthProvider manages the user authentication state across the app
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  /// get the current user
  User? get user => _user;
  /// check if user is authenticated
  bool get isAuthenticated => _user != null;
  /// check if an operation is in progress
  bool get isLoading => _isLoading;
  /// get the current error message
  String? get errorMessage => _errorMessage;
  /// get user's email
  String? get userEmail => _user?.email;
  /// get user's display name
  String? get userDisplayName => _user?.displayName;

  AuthProvider() {
    // listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });

    // initialize current user
    _user = _authService.currentUser;
  }

  /// sign up for new users
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await _authService.updateDisplayName(displayName);
      }

      _user = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// sign in for existing users
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      _user = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// sign out the current user
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();
      await _authService.signOut();
      _user = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// send password reset email
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// update user's display name
  Future<bool> updateDisplayName(String displayName) async {
    try {
      _setLoading(true);
      _clearError();
      await _authService.updateDisplayName(displayName);
      // reload user to get updated name
      _user = _authService.currentUser;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// delete the current user account
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();
      await _authService.deleteAccount();
      _user = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// clear existing error messages
  void clearError() {
    _clearError();
  }

  // Helper Methods
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
    notifyListeners();
  }
}
