import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showAppSnackbar({
  required String title,
  required String message,
  required Color? textColor,
  required Color? backgroundColor,
  Duration duration = const Duration(seconds: 3),
  SnackPosition position = SnackPosition.TOP,
}) {
  Get.snackbar(
    title,
    message,
    colorText: textColor,
    backgroundColor: backgroundColor,
    duration: duration,
    snackPosition: position,
  );
}

void showSuccessSnackbar({
  required String title,
  required String message,
}) {
  showAppSnackbar(
    title: title,
    message: message,
    textColor: Colors.green[300],
    backgroundColor: Colors.green[50],
  );
}

void showErrorSnackbar({
  required String title,
  required String message,
}) {
  showAppSnackbar(
    title: title,
    message: message,
    textColor: Colors.red[300],
    backgroundColor: Colors.red[50],
  );
}

void showWarningSnackbar({
  required String title,
  required String message,
}) {
  showAppSnackbar(
    title: title,
    message: message,
    textColor: Colors.white,
    backgroundColor: const Color.fromARGB(200, 212, 191, 0),
  );
}
