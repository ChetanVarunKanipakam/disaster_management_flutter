// lib/presentation/auth/providers/auth_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import 'package:image_picker/image_picker.dart';
enum AuthStatus { Uninitialized, Authenticated, Authenticating, Unauthenticated, Updating }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  // Existing properties for login/auth state
  AuthStatus _status = AuthStatus.Uninitialized;
  UserModel? _user;
  String? _loginErrorMessage;
  String? _updateErrorMessage;
  // New properties specifically for the signup process
  bool _isSigningUp = false;
  String? _signupErrorMessage;

  AuthProvider(this._authRepository) {
    _init();
  }

  // --- Getters ---
  AuthStatus get status => _status;
  UserModel? get user => _user;
  bool get isAuthenticated => _status == AuthStatus.Authenticated;
  String? get loginErrorMessage => _loginErrorMessage;
  bool get isSigningUp => _isSigningUp;
  String? get signupErrorMessage => _signupErrorMessage;
  String? get updateErrorMessage => _updateErrorMessage;
  // --- Auth Methods ---
  Future<void> _init() async {
    final token = await _authRepository.getToken();
    if (token != null) {
      try {
      // Fetch user details using the token
      final response= await _authRepository.getUser();
      print(response.toString());
      // Store user info in your user model (adjust this based on your app’s structure)
      _user = response;

      _status = AuthStatus.Authenticated;
    } catch (e) {
      // If fetching user details fails, treat as unauthenticated
      _status = AuthStatus.Unauthenticated;
      print("Error fetching user info: $e");
    }
    } else {
      _status = AuthStatus.Unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.Authenticating;
    _loginErrorMessage = null;
    notifyListeners();
    try {
      _user = await _authRepository.login(email, password);
      _status = AuthStatus.Authenticated;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _loginErrorMessage = e.response?.data['message'] ?? 'An unknown error occurred.';
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// **New method for handling user registration.**
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _isSigningUp = true;
    _signupErrorMessage = null;
    notifyListeners(); // Update UI to show loading indicator

    try {
      await _authRepository.signup(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _isSigningUp = false;
      notifyListeners();
      return true; // Signal success to the UI
    } on DioException catch (e) {
      // Extract a user-friendly error message from the backend response
      _signupErrorMessage = e.response?.data['message'] ?? 'Failed to sign up. Please try again.';
      _isSigningUp = false;
      notifyListeners();
      return false; // Signal failure to the UI
    }
  }
  Future<bool> updateProfile({
    required String name,
    required String phone,
    XFile? imageFile,
  }) async {
    _status = AuthStatus.Updating;
    _updateErrorMessage = null;
    notifyListeners();

    final result = await _authRepository.updateUserProfile(
      name: name,
      phone: phone,
      imageFile: imageFile,
    );

    if (result['success']) {
      // The backend returns the updated user object.
      // We use it to update our local user state.
      _user = UserModel.fromJson(result['data']);
      
      // TODO: Save the updated user to SharedPreferences if you persist user data
      
      _status = AuthStatus.Authenticated;
      notifyListeners();
      return true;
    } else {
      _updateErrorMessage = result['error'];
      _status = AuthStatus.Authenticated; // Or an error state if you have one
      notifyListeners();
      return false;
    }
  }
  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _status = AuthStatus.Unauthenticated;
    print(_status);
    notifyListeners();
  }
}