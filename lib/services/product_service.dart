import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/product_model.dart';

class ProductService {
  final String token;

  ProductService({required this.token});

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Product>> getProducts() async {
    final url = Uri.parse(ApiConstants.productsEndpoint);

    final response = await http.get(url, headers: _headers);

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final dynamic data = responseBody['data'];

      List<dynamic> productsJson = [];

      if (data is Map<String, dynamic> && data['products'] is List) {
        productsJson = data['products'];
      } else if (responseBody['products'] is List) {
        productsJson = responseBody['products'];
      } else if (data is List) {
        productsJson = data;
      }

      return productsJson
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      final message =
          responseBody['message']?.toString() ?? 'Gagal mengambil data produk.';
      throw Exception(message);
    }
  }

  Future<void> addProduct({
    required String name,
    required int price,
    required String description,
  }) async {
    final url = Uri.parse(ApiConstants.productsEndpoint);

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
      }),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      final message =
          responseBody['message']?.toString() ?? 'Gagal menyimpan produk.';
      throw Exception(message);
    }
  }

  Future<void> submitTask({
    required String name,
    required int price,
    required String description,
    required String githubUrl,
  }) async {
    final url = Uri.parse(ApiConstants.submitEndpoint);

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': githubUrl,
      }),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      final message =
          responseBody['message']?.toString() ?? 'Gagal submit tugas.';
      throw Exception(message);
    }
  }
}
