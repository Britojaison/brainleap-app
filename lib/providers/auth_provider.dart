import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _token;
  UserProfile? _user;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  UserProfile? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  bool get isInitialized => _isInitialized;

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

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;

        _token = data['token'] as String?;
        final refreshToken = data['refreshToken'] as String?;
        if (data['user'] != null) {
          _user = UserProfile.fromJson(data['user'] as Map<String, dynamic>);
        }

        debugPrint('✅ Login successful! Token: ${_token?.substring(0, 20)}...');
        debugPrint('👤 User: ${_user?.email}');

        if (_token != null) {
          await _saveSession();
          if (refreshToken != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(StorageKeys.refreshToken, refreshToken);
          }
          debugPrint('💾 Session saved');
        }
        notifyListeners();
      } else {
        _errorMessage = (response['message'] as String?) ?? 'Login failed';
        debugPrint('❌ Login failed: $_errorMessage');
        throw Exception(_errorMessage);
      }
    } on Exception catch (error) {
      _errorMessage = error.toString();
      debugPrint('💥 Login error: $error');
      throw Exception(_errorMessage);
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
    await prefs.remove(StorageKeys.refreshToken);
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
}
