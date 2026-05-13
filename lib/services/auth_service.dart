import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class AuthService {
  Future<String> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse(ApiConstants.loginEndpoint);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = responseBody['data']?['token'];

      if (token == null || token.toString().isEmpty) {
        throw Exception('Token tidak ditemukan pada response API.');
      }

      return token.toString();
    } else {
      final message = responseBody['message']?.toString() ?? 'Login gagal.';
      throw Exception(message);
    }
  }
}
