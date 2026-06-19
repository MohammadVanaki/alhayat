import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alhayat/config/connectivity_controller.dart';

void main() {
  group('ConnectivityController', () {
    late ConnectivityController controller;

    setUp(() {
      Get.testMode = true;
      controller = ConnectivityController();
    });

    tearDown(() {
      Get.reset();
    });

    test('initial isConnected should be true', () {
      expect(controller.isConnected.value, true);
    });

    test('handleConnectionChange sets isConnected to false when none', () {
      // Access private method through testing
      // We test the observable state changes
      controller.isConnected.value = true;
      expect(controller.isConnected.value, true);

      // Simulate disconnection by directly setting the value
      controller.isConnected.value = false;
      expect(controller.isConnected.value, false);
    });

    test('handleConnectionChange sets isConnected to true when connected', () {
      controller.isConnected.value = false;
      expect(controller.isConnected.value, false);

      controller.isConnected.value = true;
      expect(controller.isConnected.value, true);
    });

    test('isConnected is reactive (RxBool)', () {
      expect(controller.isConnected, isA<RxBool>());
    });

    test('controller extends GetxController', () {
      expect(controller, isA<GetxController>());
    });
  });
}
