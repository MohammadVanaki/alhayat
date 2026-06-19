import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:alhayat/features/feature_intro/data/data_source/forgot_api_provider.dart';

void main() {
  group('userForgotPassword', () {
    test('returns decoded body on success (200)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'reset link sent'}),
          200,
        );
      });

      final result = await userForgotPassword(
        email: 'test@example.com',
        client: mockClient,
      );

      expect(result, isA<Map>());
      expect(result['message'], 'reset link sent');
    });

    test('returns error map on non-200 response', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'not found'}),
          404,
        );
      });

      final result = await userForgotPassword(
        email: 'unknown@example.com',
        client: mockClient,
      );

      expect(result, isA<Map>());
      expect(result['errors'], isA<List>());
      expect(result['errors'].length, 1);
    });

    test('sends POST request to correct URL with email param', () async {
      Uri? capturedUri;
      String? capturedMethod;

      final mockClient = MockClient((request) async {
        capturedUri = request.url;
        capturedMethod = request.method;
        return http.Response(
          jsonEncode({'message': 'ok'}),
          200,
        );
      });

      await userForgotPassword(
        email: 'user@test.com',
        client: mockClient,
      );

      expect(capturedMethod, 'POST');
      expect(capturedUri!.host, 'ain-alhayat.com');
      expect(capturedUri!.path, '/api/v1/forget-password');
      expect(capturedUri!.queryParameters['email'], 'user@test.com');
    });

    test('returns error map on 422 response', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'errors': ['validation error']}),
          422,
        );
      });

      final result = await userForgotPassword(
        email: 'bad@example.com',
        client: mockClient,
      );

      expect(result['errors'], isA<List>());
    });

    test('returns error map on 500 server error', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'server error'}),
          500,
        );
      });

      final result = await userForgotPassword(
        email: 'test@example.com',
        client: mockClient,
      );

      expect(result['errors'], isA<List>());
    });
  });
}
