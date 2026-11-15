import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';

class AuthService {
  Future<void> signIn({
    required String whatsapp,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/login'),
      headers: {'Accept': 'application/json'},
      body: {'whatsapp': whatsapp, 'password': password},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Falha ao entrar.');
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('auth_token', data['token']);
  }

  Future<void> signOut() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('auth_token');
  }

  Future<String?> getToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('auth_token');
  }
}
