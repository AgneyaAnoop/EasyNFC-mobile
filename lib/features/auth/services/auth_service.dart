
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:easy_nfc/config/api_config.dart';
import '../models/signup_data.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _lastLoginKey = 'last_login';

  Future<bool> isAuthenticated() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final lastLoginStr = await _storage.read(key: _lastLoginKey);

      if (token == null || lastLoginStr == null) return false;

      final lastLogin = DateTime.parse(lastLoginStr);
      final now = DateTime.now();
      final difference = now.difference(lastLogin);

      // If token is older than 24 hours, consider it expired
      if (difference.inHours >= 24) {
        await logout(); // Clear expired token
        return false;
      }

      return true;
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(APIConfig.loginEndpoint),
        headers: APIConfig.headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final token = json.decode(response.body)['token'];
        await _storage.write(key: _tokenKey, value: token);
        await _storage.write(
          key: _lastLoginKey,
          value: DateTime.now().toIso8601String(),
        );
        return token;
      } else {
        throw json.decode(response.body)['message'] ?? 'Login failed';
      }
    } catch (e) {
      print('Login error: $e');
      throw 'Connection error. Please try again.';
    }
  }


  Future<String> register(SignupData data) async {
  try {
    print('Making register request to: ${APIConfig.registerEndpoint}'); // Debug log
    
    final response = await http.post(
      Uri.parse(APIConfig.registerEndpoint),
      headers: APIConfig.headers,
      body: json.encode(data.toJson()),
    );

    print('Register response status: ${response.statusCode}'); // Debug log
    print('Register response body: ${response.body}'); // Debug log

    if (response.statusCode == 201) {
      final token = json.decode(response.body)['token'];
      // Store the token
      await _storage.write(key: _tokenKey, value: token);
      // Store login timestamp for the new registration
      await _storage.write(
        key: _lastLoginKey,
        value: DateTime.now().toIso8601String(),
      );
      return token;
    } else {
      throw json.decode(response.body)['message'] ?? 'Registration failed';
    }
  } catch (e) {
    print('Register error: $e'); // Debug log
    if (e is String) {
      throw e;
    }
    throw 'Connection error. Please try again.';
  }
}

  Future<String?> getStoredToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }
}