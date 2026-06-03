import 'package:alhayat/common/utils/api_client.dart';
import 'package:alhayat/config/constants.dart';
import 'package:alhayat/features/feature_home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

Future userValidate({
  required context,
  required String email,
  required String password,
}) async {
  debugPrint(email.toString());
  debugPrint(password.toString());

  final response = await ApiClient.post(
    '/api/v1/login',
    body: {'email': email, 'password': password},
  );

  if (response.statusCode == 200) {
    final responseData = ApiClient.decodeBody(response);
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
    return ApiClient.decodeBody(response);
  } else {
    throw Exception('Error: ${response.statusCode}');
  }
}
