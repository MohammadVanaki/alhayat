import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HijriDateController extends GetxController {
  final http.Client? httpClient;
  var hijriDate = ''.obs;

  HijriDateController({this.httpClient});

  Future<void> fetchHijriDate() async {
    try {
      final client = httpClient ?? http.Client();
      final response =
          await client.get(Uri.parse('https://yaqoobi.in/api/getdate'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        hijriDate.value = data['date'];
      } else {
        hijriDate.value = 'خطا ';
      }
    } catch (e) {
      hijriDate.value = 'خطای ';
    }
  }

  @override
  void onInit() {
    fetchHijriDate();
    super.onInit();
  }
}
