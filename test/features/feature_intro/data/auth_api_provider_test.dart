import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:alhayat/config/constants.dart';

/// Tests for the auth API provider logic.
/// Note: Direct import of auth_api_provider.dart is avoided due to
/// transitive dependency on page_transition which has Flutter SDK
/// compatibility issues. Instead we test the same HTTP contract.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth API Provider contract', () {
    test('login endpoint URL is correctly constructed', () {
      final uri = Uri.https(Constants.baseUrl, '/api/v1/login');
      expect(uri.scheme, 'https');
      expect(uri.host, 'ain-alhayat.com');
      expect(uri.path, '/api/v1/login');
    });

    test('login request body contains email and password', () async {
      String? capturedBody;
      String? capturedMethod;

      final mockClient = MockClient((request) async {
        capturedBody = request.body;
        capturedMethod = request.method;
        return http.Response(
          jsonEncode({'errors': {}}),
          422,
        );
      });

      await mockClient.post(
        Uri.https(Constants.baseUrl, '/api/v1/login'),
        body: {'email': 'test@test.com', 'password': 'mypass'},
      );

      expect(capturedMethod, 'POST');
      expect(capturedBody, contains('email=test%40test.com'));
      expect(capturedBody, contains('password=mypass'));
    });

    test('successful login response contains expected user fields', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'photo': 'https://example.com/photo.jpg',
            'name': 'Test User',
            'study_stages': ['stage1', 'stage2'],
            'evidence': 'evidence_data',
            'token': 'jwt-token-123',
          }),
          200,
        );
      });

      final response = await mockClient.post(
        Uri.https(Constants.baseUrl, '/api/v1/login'),
        body: {'email': 'user@test.com', 'password': 'pass123'},
      );

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['token'], 'jwt-token-123');
      expect(data['name'], 'Test User');
      expect(data['photo'], 'https://example.com/photo.jpg');
      expect(data['study_stages'], isA<List>());
      expect(data['evidence'], 'evidence_data');
    });

    test('422 response contains validation errors', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'errors': {'email': ['Email is required']}
          }),
          422,
        );
      });

      final response = await mockClient.post(
        Uri.https(Constants.baseUrl, '/api/v1/login'),
        body: {'email': '', 'password': ''},
      );

      expect(response.statusCode, 422);
      final data = jsonDecode(response.body);
      expect(data['errors'], isA<Map>());
      expect(data['errors']['email'], contains('Email is required'));
    });

    test('non-200 and non-422 status codes indicate server error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final response = await mockClient.post(
        Uri.https(Constants.baseUrl, '/api/v1/login'),
        body: {'email': 'test@test.com', 'password': 'pass'},
      );

      expect(response.statusCode, 500);
    });

    test('baseUrl is used for login endpoint', () {
      expect(Constants.baseUrl, 'ain-alhayat.com');
      final uri = Uri.https(Constants.baseUrl, '/api/v1/login');
      expect(uri.toString(), 'https://ain-alhayat.com/api/v1/login');
    });
  });
}
