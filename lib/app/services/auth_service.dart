import 'package:flutter/material.dart';
import 'package:fuba_clicker/main.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'api_service.dart';
import '../models/user_data.dart';
import '../models/auth_response.dart';

class AuthService {
  static const String _jwtKey = 'auth_jwt';
  static const String _rtKey = 'auth_rt';
  static const String _userDataKey = 'user_data';

  final ApiService _apiService = ApiService();
  Box? _authBox;

  Future<void> init() async {
    _authBox = await Hive.openBox('auth_storage');

    final jwt = await getJwt();
    final rt = await getRefreshToken();

    if (jwt != null) {
      _apiService.setJwt(jwt);
    }
    if (rt != null) {
      _apiService.setRefreshToken(rt);
    }
  }

  Future<bool> isAuthenticated() async {
    if (_authBox == null) return false;
    final jwt = _authBox!.get(_jwtKey);
    return jwt != null && jwt.toString().isNotEmpty;
  }

  Future<String?> getJwt() async {
    if (_authBox == null) return null;
    return _authBox!.get(_jwtKey);
  }

  Future<String?> getRefreshToken() async {
    if (_authBox == null) return null;
    return _authBox!.get(_rtKey);
  }

  Future<UserData?> getCurrentUser() async {
    if (_authBox == null) return null;
    final userDataJson = _authBox!.get(_userDataKey);
    if (userDataJson == null) return null;

    try {
      return UserData.fromJson(Map<String, dynamic>.from(userDataJson));
    } catch (e) {
      return null;
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);

      await _saveAuthData(response.jwt, response.rt, null);

      await TokenService().writeMethod('jwt', response.jwt);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String email, String username, String password) async {
    try {
      await _apiService.register(email, username, password);
    } catch (e) {
      debugPrint('[]>> register error: $e');

      rethrow;
    }
  }

  Future<UserData> fetchUserData() async {
    try {
      final userData = await _apiService.getUserData();
      await _saveUserData(userData);
      return userData;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    if (_authBox != null) {
      await _authBox!.clear();
    }
    _apiService.setJwt(null);
    _apiService.setRefreshToken(null);
  }

  Future<void> _saveAuthData(String jwt, String? rt, UserData? userData) async {
    if (_authBox == null) return;

    await _authBox!.put(_jwtKey, jwt);
    if (rt != null) {
      await _authBox!.put(_rtKey, rt);
    }
    _apiService.setJwt(jwt);
    _apiService.setRefreshToken(rt);

    if (userData != null) {
      await _saveUserData(userData);
    }
  }

  Future<void> _saveUserData(UserData userData) async {
    if (_authBox == null) return;
    await _authBox!.put(_userDataKey, userData.toJson());
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      await _apiService.updateUserData(data);
    } catch (e) {
      rethrow;
    }
  }
}
