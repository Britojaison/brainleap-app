import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({ApiService? apiService}) : _api = apiService ?? ApiService() {
    // Seed with a demo user so the login screen can showcase states.
    _mockUsers['student@example.com'] = _MockUser(
      id: 'demo-user',
      email: 'student@example.com',
      displayName: 'Sample Student',
      password: 'password123',
    );
  }

  final ApiService _api;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _token;
  UserProfile? _user;
  String? _errorMessage;
  final Map<String, _MockUser> _mockUsers = {};
  final Map<String, String> _pendingOtps = {};

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  UserProfile? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  bool get isInitialized => _isInitialized;
  bool get hasMockUsers => _mockUsers.isNotEmpty;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(StorageKeys.authToken);
    final userJson = prefs.getString(StorageKeys.userProfile);
    if (userJson != null) {
      try {
        _user =
            UserProfile.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error loading user profile: $e');
        await clearSession();
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      debugPrint('🔐 Attempting login for: $email');
      final response = await _api.login(email: email, password: password);
      debugPrint('📡 Login response status: ${response.statusCode}');
      debugPrint('📦 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        // Backend returns: {"success": true, "data": {"token": "...", "user": {...}}}
        final data = responseData['data'] as Map<String, dynamic>;

        _token = data['token'] as String?;
        if (data['user'] != null) {
          _user = UserProfile.fromJson(data['user'] as Map<String, dynamic>);
        }

        debugPrint('✅ Login successful! Token: ${_token?.substring(0, 20)}...');
        debugPrint('👤 User: ${_user?.email}');

        if (_token != null) {
          await _saveSession();
          debugPrint('💾 Session saved');
        }
        notifyListeners();
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = errorData['message'] as String? ?? 'Login failed';
        debugPrint('❌ Login failed: $_errorMessage');
        throw Exception(_errorMessage);
      }
    } catch (error) {
      _errorMessage = error.toString();
      debugPrint('💥 Login error: $error');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await clearSession();
    _token = null;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString(StorageKeys.authToken, _token!);
    }
    if (_user != null) {
      await prefs.setString(
          StorageKeys.userProfile, jsonEncode(_user!.toJson()));
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.authToken);
    await prefs.remove(StorageKeys.userProfile);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// --------
  /// MOCK FLOW HELPERS
  /// These helpers power the current UI-only auth flow while the backend is in progress.
  /// They can be removed or replaced once real endpoints are integrated.
  /// --------

  bool isEmailRegistered(String email) {
    final key = email.trim().toLowerCase();
    return _mockUsers.containsKey(key);
  }

  String? getDisplayName(String email) {
    final key = email.trim().toLowerCase();
    return _mockUsers[key]?.displayName;
  }

  bool validatePassword(String email, String password) {
    final key = email.trim().toLowerCase();
    if (!_mockUsers.containsKey(key)) {
      return false;
    }
    return password.trim().length >= 6;
  }

  void registerMockUser({
    required String id,
    required String email,
    required String displayName,
    String? password,
  }) {
    final key = email.trim().toLowerCase();
    _mockUsers[key] = _MockUser(
      id: id,
      email: key,
      displayName: displayName,
      password: password,
    );
  }

  String sendMockOtp(String email, {bool forceRefresh = false}) {
    final key = email.trim().toLowerCase();
    if (!_mockUsers.containsKey(key)) {
      throw Exception('Email not registered');
    }

    final otp = forceRefresh
        ? _generateOtp(seed: '${DateTime.now().millisecondsSinceEpoch}-$key')
        : _pendingOtps[key] ?? _generateOtp(seed: key);
    _pendingOtps[key] = otp;
    debugPrint('📨 Mock OTP for $email → $otp');
    return otp;
  }

  Future<bool> verifyMockOtp(String email, String code) async {
    final key = email.trim().toLowerCase();
    final mockUser = _mockUsers[key];
    if (mockUser == null) {
      return false;
    }
    // For the UI prototype, accept any code and sign the user in.
    _pendingOtps.remove(key);
    await _completeMockSignIn(mockUser);
    return true;
  }

  Future<void> mockAuthenticate(String email) async {
    final key = email.trim().toLowerCase();
    final mockUser = _mockUsers[key];
    if (mockUser == null) {
      throw Exception('No mock user registered for $email');
    }

    await _completeMockSignIn(mockUser);
  }

  Future<void> _completeMockSignIn(_MockUser mockUser) async {
    _token = 'mock-token-${mockUser.id}';
    _user = UserProfile(
      id: mockUser.id,
      email: mockUser.email,
      displayName: mockUser.displayName,
    );
    _errorMessage = null;
    await _saveSession();
    notifyListeners();
  }

  String _generateOtp({String? seed}) {
    const fallback = '123456';
    if (seed == null) {
      return fallback;
    }
    final hash = seed.hashCode.abs().toString();
    final padded = hash.padLeft(6, '0');
    return padded.substring(padded.length - 6);
  }
}

class _MockUser {
  const _MockUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.password,
  });

  final String id;
  final String email;
  final String displayName;
  final String? password;
}
