import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String API_BASE = String.fromEnvironment('API_BASE', defaultValue: 'http://127.0.0.1:8000');

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final res = await http.post(Uri.parse('$API_BASE/api/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await http.post(Uri.parse('$API_BASE/api/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'name': name, 'email': email, 'password': password, 'password_confirmation': passwordConfirmation
      }),
    );
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> fetchCurrentUser() async {
    final token = await getToken();
    if (token == null) return {'status': 'error', 'message': 'No token'};
    final res = await http.get(Uri.parse('$API_BASE/api/user'), headers: {
      'Accept': 'application/json', 'Authorization': 'Bearer $token',
    });
    return _handleResponse(res);
  }

  Future<void> saveToken(String token) => _secureStorage.write(key: _tokenKey, value: token);
  Future<String?> getToken() => _secureStorage.read(key: _tokenKey);
  Future<void> deleteToken() => _secureStorage.delete(key: _tokenKey);

  Map<String, dynamic> _handleResponse(http.Response res) {
    try {
      final body = res.body.isEmpty ? {} : jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {'status': 'ok', 'data': body};
      } else if (res.statusCode == 422) {
        return {'status': 'validation_error', 'errors': (body['errors'] ?? {}), 'message': body['message'] ?? 'Validation failed'};
      } else {
        return {'status': 'error', 'message': body['message'] ?? 'Request failed', 'body': body};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Invalid response format', 'exception': e.toString()};
    }
  }
}
