import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:alhayat/features/feature_home/data/hijri_date_controller.dart';

void main() {
  group('HijriDateController', () {
    late HijriDateController controller;

    setUp(() {
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    test('initial hijriDate should be empty string', () {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'date': '15 Dhul Hijja 1446'}),
          200,
        );
      });

      controller = HijriDateController(httpClient: mockClient);
      expect(controller.hijriDate.value, '');
    });

    test('fetchHijriDate sets date on successful response', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'date': '15 Dhul Hijja 1446'}),
          200,
        );
      });

      controller = HijriDateController(httpClient: mockClient);
      await controller.fetchHijriDate();

      expect(controller.hijriDate.value, '15 Dhul Hijja 1446');
    });

    test('fetchHijriDate sets error message on non-200 response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      controller = HijriDateController(httpClient: mockClient);
      await controller.fetchHijriDate();

      expect(controller.hijriDate.value, contains('\u062e\u0637\u0627'));
    });

    test('fetchHijriDate sets error message on exception', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network error');
      });

      controller = HijriDateController(httpClient: mockClient);
      await controller.fetchHijriDate();

      expect(controller.hijriDate.value, contains('\u062e\u0637\u0627'));
    });

    test('fetchHijriDate sends GET request to correct URL', () async {
      Uri? capturedUri;
      final mockClient = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(
          jsonEncode({'date': '1 Muharram 1447'}),
          200,
        );
      });

      controller = HijriDateController(httpClient: mockClient);
      await controller.fetchHijriDate();

      expect(capturedUri, Uri.parse('https://yaqoobi.in/api/getdate'));
    });

    test('fetchHijriDate handles malformed JSON gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response('not valid json', 200);
      });

      controller = HijriDateController(httpClient: mockClient);
      await controller.fetchHijriDate();

      // Malformed JSON throws FormatException, caught by try/catch
      expect(controller.hijriDate.value, contains('\u062e\u0637\u0627'));
    });

    test('fetchHijriDate handles server error 500', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      controller = HijriDateController(httpClient: mockClient);
      await controller.fetchHijriDate();

      expect(controller.hijriDate.value, contains('\u062e\u0637\u0627'));
    });

    test('hijriDate is reactive (RxString)', () {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'date': 'test'}), 200);
      });

      controller = HijriDateController(httpClient: mockClient);
      expect(controller.hijriDate, isA<RxString>());
    });

    test('controller extends GetxController', () {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'date': 'test'}), 200);
      });

      controller = HijriDateController(httpClient: mockClient);
      expect(controller, isA<GetxController>());
    });
  });
}
