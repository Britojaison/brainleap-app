import 'package:flutter/foundation.dart';

import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;
  bool _isLoading = false;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _api.login(email: email, password: password);
      if (response.statusCode == 200) {
        _token = response.body; // TODO: parse token payload.
      } else {
        throw Exception('Login failed');
      }
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _token = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
