import 'package:alhayat/config/constants.dart';
import 'package:alhayat/features/feature_intro/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

void logoutAndNavigateToLogin(BuildContext context) {
  Constants.getStorage.remove('userData');
  Navigator.pushReplacement(
    context,
    PageTransition(
      child: const LoginPage(),
      type: PageTransitionType.bottomToTop,
    ),
  );
}
