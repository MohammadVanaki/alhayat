import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:alhayat/config/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Mock path_provider channel for GetStorage
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '/tmp/test_storage';
      },
    );
    await GetStorage.init();
  });

  group('Constants', () {
    test('baseUrl should be ain-alhayat.com', () {
      expect(Constants.baseUrl, 'ain-alhayat.com');
    });

    test('fcmToken should default to empty string', () {
      expect(Constants.fcmToken, '');
    });

    test('getStorage should not be null', () {
      expect(Constants.getStorage, isNotNull);
    });

    test('getStorageNotif should not be null', () {
      expect(Constants.getStorageNotif, isNotNull);
    });

    test('baseUrl can be updated', () {
      final original = Constants.baseUrl;
      Constants.baseUrl = 'test.example.com';
      expect(Constants.baseUrl, 'test.example.com');
      Constants.baseUrl = original;
    });

    test('fcmToken can be updated', () {
      final original = Constants.fcmToken;
      Constants.fcmToken = 'test-token-123';
      expect(Constants.fcmToken, 'test-token-123');
      Constants.fcmToken = original;
    });
  });
}
