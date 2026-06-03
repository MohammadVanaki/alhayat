import 'dart:convert';
import 'package:alhayat/config/constants.dart';
import 'package:alhayat/features/feature_home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

Future userValidate({
  required context,
  required String email,
  required String password,
}) async {
  debugPrint(email.toString());
  debugPrint(password.toString());

  try {
    final response = await http.post(
      Uri.https(
        Constants.baseUrl,
        '/api/v1/login',
      ),
      body: {'email': email, 'password': password},
    );

    debugPrint(response.statusCode.toString());

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      Constants.getStorage.write('userData', {
        'email': email,
        'password': password,
        'photo': responseData['photo'],
        'name': responseData['name'],
        'study_stages': responseData['study_stages'],
        'evidence': responseData['evidence'],
        'token': responseData['token'],
      });

      Navigator.pushReplacement(
        context,
        PageTransition(
          child: const HomePage(),
          type: PageTransitionType.bottomToTop,
        ),
      );
    } else if (response.statusCode == 422) {
      return jsonDecode(response.body);
    } else {
      return {
        'errors': ['خطأ في الخادم: ${response.statusCode}']
      };
    }
  } catch (e) {
    debugPrint('Login request failed: $e');
    return {
      'errors': ['فشل الاتصال بالخادم. تحقق من اتصالك بالإنترنت.']
    };
  }
}
