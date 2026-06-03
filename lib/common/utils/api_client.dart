import 'dart:convert';

import 'package:alhayat/config/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static Future<http.Response> post(
    String path, {
    Map<String, String>? body,
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.https(Constants.baseUrl, path, queryParameters);
    final response = await http.post(uri, body: body);
    debugPrint('POST $path -> ${response.statusCode}');
    return response;
  }

  static Future<http.Response> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.https(Constants.baseUrl, path, queryParameters);
    final response = await http.get(uri, headers: headers);
    debugPrint('GET $path -> ${response.statusCode}');
    return response;
  }

  static Map<String, dynamic> decodeBody(http.Response response) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
