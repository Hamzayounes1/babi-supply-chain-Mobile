import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  bool loading = true;
  Map<String, dynamic>? user;
  String? token;

  AuthProvider(this._service) { _init(); }

  Future<void> _init() async {
    token = await _service.getToken();
    if (token != null) {
      final res = await _service.fetchCurrentUser();
      if (res['status'] == 'ok') user = res['data'];
      else { await _service.deleteToken(); token = null; user = null; }
    }
    loading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _service.login(email: email, password: password);
    if (res['status'] == 'ok') {
      final data = res['data'];
      final t = data['token'] ?? data['access_token'] ?? (data['data']?['token']);
      if (t != null) {
        token = t;
        await _service.saveToken(token!);
        final userRes = await _service.fetchCurrentUser();
        if (userRes['status'] == 'ok') user = userRes['data'];
        notifyListeners();
      }
    }
    return res;
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String passwordConfirmation) async {
    final res = await _service.register(name: name, email: email, password: password, passwordConfirmation: passwordConfirmation);
    if (res['status'] == 'ok') {
      final data = res['data'];
      final t = data['token'] ?? data['access_token'] ?? (data['data']?['token']);
      if (t != null) {
        token = t;
        await _service.saveToken(token!);
        final userRes = await _service.fetchCurrentUser();
        if (userRes['status'] == 'ok') user = userRes['data'];
        notifyListeners();
      }
    }
    return res;
  }

  Future<void> logout() async {
    await _service.deleteToken();
    token = null; user = null; notifyListeners();
  }
}
