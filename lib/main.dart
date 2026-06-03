import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:alhayat/config/light_theme.dart';
import 'package:alhayat/config/notification.dart';
import 'package:alhayat/features/feature_intro/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'config/connectivity_controller.dart';

final ValueNotifier<bool> showDownloadPanelNotifier = ValueNotifier(false);

/// notifier for tracking download progress
class DownloadProgress {
  static ValueNotifier<int> progress = ValueNotifier(0);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Custom error widget
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lottiefiles/lottieError.json'),
            const Gap(10),
            Text(
              kDebugMode
                  ? details.exception.toString()
                  : 'حدث خطأ غير متوقع',
            ),
          ],
        ),
      ),
    );
  };

  await GetStorage.init();
  await FlutterDownloader.initialize(debug: kDebugMode, ignoreSsl: false);
  FlutterDownloader.registerCallback(downloadCallback);

  /// Init Firebase
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.subscribeToTopic("general");
  await FirebaseNotificationService().initializeNotifications();

  /// Run app
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName(
    'downloader_send_port',
  );
  send?.send([id, status, progress]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ConnectivityController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'عين الحياة',
      themeMode: ThemeMode.system,
      theme: MyThemes.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      locale: const Locale('ar'),
      home: const SplashScreen(),
    );
  }
}
