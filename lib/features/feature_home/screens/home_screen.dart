import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:alhayat/common/utils/costum_dialog_message.dart';
import 'package:alhayat/common/utils/dialog_helpers.dart';
import 'package:alhayat/common/utils/navigation_helpers.dart';
import 'package:alhayat/common/utils/costum_loading.dart';
import 'package:alhayat/config/constants.dart';
import 'package:alhayat/features/feature_home/widgets/notif_card.dart';
import 'package:alhayat/features/feature_offline/screens/main_offline_screen.dart';
import 'package:alhayat/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

// import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:screen_protector/screen_protector.dart';

import '../data/hijri_date_controller.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavIndex = 0;
  bool loadContent = false;
  bool pageFinished = true;
  String pageContent = 'grid';
  String pdfName = '';
  // final ValueNotifier<bool> showDownloadPanelNotifier =
  //     ValueNotifier<bool>(false);

  WebViewController controller = WebViewController();
  final List<IconData> iconList = <IconData>[
    Icons.home,
    Icons.chat,
    Icons.menu_book_rounded,
    Icons.note_alt,
  ];
  final List servicesList = [
    {'title': 'المعلومات الشخصية', 'icon': 'cm-01.png'},
    {'title': 'الصوتيات', 'icon': 'cm-02.png'},
    {'title': 'المرئيات', 'icon': 'cm-03.png'},
    {'title': 'البث المباشر', 'icon': 'cm-04.png'},
    {'title': 'المنهج الدراسي', 'icon': 'cm-05.png'},
    {'title': 'المنهج الاسبوعي', 'icon': 'cm-06.png'},
    {'title': 'المكتبة', 'icon': 'cm-07.png'},
    // {'title': 'الاخبار ', 'icon': 'newspaper.png'},
    {'title': 'البوم الصور ', 'icon': 'cm-08.png'},
    {'title': ' الحضور والغياب ', 'icon': 'cm-09.png'},
    {'title': 'امتحان ', 'icon': 'cm-10.png'},
    {'title': 'الرسائل ', 'icon': 'cm-11.png'},
    {'title': 'طباعة ', 'icon': 'cm-12.png'},
    {'title': 'ملاحظات ', 'icon': 'cm-13.png'},
    {'title': 'من نحن ', 'icon': 'cm-14.png'},
    {'title': 'الغاء العضوية', 'icon': 'cm-15.png'},
  ];
  List<String> titleContent = [];
  List<String> bodyContent = [];
  List<String> dateContent = [];
  Timer? _configTimer;
  _getContents() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      titleContent = pref.getStringList("titleContent") ?? [];
      bodyContent = pref.getStringList("bodyContent") ?? [];
      dateContent = pref.getStringList("dateContent") ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    bindBackgroundIsolate();
    _loadConfig();

    // Repeat every 30 minutes
    _configTimer = Timer.periodic(
      const Duration(minutes: 30),
      (timer) => _loadConfig(),
    );
    controller.addJavaScriptChannel(
      'Print11',
      onMessageReceived: (JavaScriptMessage message) {
        debugPrint(
          'js  audioName===========================>>>' + message.message,
        );
        final dateList = message.message.split("+");

        setState(() {
          audioName = message.message;
        });
        debugPrint(
          "js  audioName===========================>>>" +
              dateList[0] +
              '-----' +
              dateList[1],
        );
      },
    );
    _getContents();
    showDownloadPanelNotifier.addListener(() {
      if (showDownloadPanelNotifier.value) {
        print("Download panel should show");
      } else {
        print("Download panel should hide");
      }
    });
  }

  Future<void> _loadConfig() async {
    const url = "https://ain-alhayat.com/api/v1/configurations";

    try {
      final response = await http.get(Uri.parse(url));

      debugPrint("Config HTTP status: ${response.statusCode}");
      debugPrint("Config raw body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        // The response structure you showed has `data` as the container
        final Map<String, dynamic>? data = (body['data'] is Map)
            ? Map<String, dynamic>.from(body['data'])
            : null;

        debugPrint("Config data: ${data}");

        // Safely extract allow_screenshot (handle bool or string)
        final dynamic allowVal = data != null ? data['allow_screenshot'] : null;

        bool allowScreenshot =
            false; // default: keep screenshots blocked (safe default)
        if (allowVal != null) {
          if (allowVal is bool) {
            allowScreenshot = allowVal;
          } else {
            // handle string/number values just in case
            final s = allowVal.toString().toLowerCase();
            allowScreenshot = (s == 'true' || s == '1' || s == 'yes');
          }
        } else {
          // If the server didn't include the field, we keep the safe default (blocked).
          debugPrint(
            "allow_screenshot not present in response; keeping safe default (blocked).",
          );
        }

        // Apply policy
        if (allowScreenshot) {
          debugPrint("Server allows screenshots -> disabling protection");
          await _unsecureScreen();
        } else {
          debugPrint("Server disallows screenshots -> enabling protection");
          await _secureScreen();
        }
      } else {
        // Non-200: keep secure mode and log
        debugPrint(
          "Failed to fetch config. Keeping secure mode. Status: ${response.statusCode}",
        );
        await _secureScreen();
      }
    } catch (e) {
      // On error (network, parse, etc.) keep secure mode (safer)
      debugPrint("Error fetching config: $e. Keeping secure mode.");
      await _secureScreen();
    }
  }

  @override
  void dispose() {
    // Remove restrictions when leaving the page
    _configTimer?.cancel();
    ScreenProtector.preventScreenshotOff();
    ScreenProtector.protectDataLeakageOff();
    super.dispose();
  }

  Future<void> _secureScreen() async {
    // Prevent screenshot and protect from data leakage
    await ScreenProtector.preventScreenshotOn();
    await ScreenProtector.protectDataLeakageOn();
  }

  /// Turn off secure mode (allow screenshots / disable extra protection).
  Future<void> _unsecureScreen() async {
    await ScreenProtector.preventScreenshotOff();
    await ScreenProtector.protectDataLeakageOff();
  }

  String newUrl = '';
  String oldUrl = '';
  String audioName = '';
  String fileName = '';
  String progressP = '';

  @override
  Widget build(BuildContext context) {
    final HijriDateController hijriDateController = Get.put(
      HijriDateController(),
    );
    Size size = MediaQuery.of(context).size;
    Future<bool> _exitApp(BuildContext context) async {
      if (await controller.canGoBack()) {
        print("onwill goback");
        controller.goBack();
        return Future.value(true);
      } else {
        setState(() {
          loadContent = false;
          pageContent = 'grid';
          _bottomNavIndex = 0;
        });
        return Future.value(false);
      }
    }

    if (controller.platform is AndroidWebViewController) {
      // Cast to Android controller
      final androidController = controller.platform as AndroidWebViewController;

      // Allow media playback without user gesture
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        _exitApp(context);
      },
      child: Scaffold(
        body: Container(
          width: size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[200]!, Colors.grey[300]!],

              begin: const FractionalOffset(1.0, 0.0),
              end: const FractionalOffset(1.0, 1.0),
              tileMode: TileMode.clamp,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 40,
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          loadContent = true;
                          pageContent = 'notif';
                        });
                      },
                      icon: const Icon(Icons.notifications_active),
                      color: Theme.of(context).primaryColor,
                    ),
                    Text(
                      'عين الحياة الالكترونية',
                      style: TextStyle(
                        fontSize: 17.0,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    RotatedBox(
                      quarterTurns: 2,
                      child: IconButton(
                        onPressed: () {
                          dialogBuilder(
                            context: context,
                            titleText: 'هل تريد تسجيل الخروج من حسابك؟',
                            disableText: 'لا',
                            enableText: 'نعم',
                            enable: () => logoutAndNavigateToLogin(context),
                          );
                        },
                        icon: const Icon(Icons.exit_to_app),
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 90,
                // right: 30,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: loadContent ? 0 : 1,
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/profile-vector.jpg',
                              image: () {
                                try {
                                  final userData = Constants.getStorage.read(
                                    'userData',
                                  );
                                  final photo = userData?['photo'];
                                  return (photo != null &&
                                          photo is String &&
                                          photo.isNotEmpty)
                                      ? photo
                                      : 'https://ui-avatars.com/api/?name=User&background=0D8ABC&color=fff&rounded=true';
                                } catch (e) {
                                  return 'https://ui-avatars.com/api/?name=User&background=0D8ABC&color=fff&rounded=true';
                                }
                              }(),
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 45,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                          const Gap(3),
                          Text(
                            Constants.getStorage.read('userData')['name'] ?? '',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Gap(3),
                          Text(
                            Constants.getStorage.read(
                                  'userData',
                                )['study_stages'] ??
                                '',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                            ),
                          ),
                          const Gap(3),
                          Obx(
                            () => Text(
                              hijriDateController.hijriDate.value,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: loadContent ? 100 : size.height * 0.3,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    color: Colors.white,
                  ),
                  width: size.width - 20,
                  height: loadContent
                      ? (size.height - 160)
                      : size.height * 0.59,
                  child: pageContent == 'grid'
                      ? AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: loadContent ? 0 : 1,
                          child: GridView.count(
                            padding: const EdgeInsets.all(18),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            crossAxisCount: 3,
                            controller: ScrollController(
                              keepScrollOffset: false,
                            ),
                            children: List.generate(servicesList.length, (
                              index,
                            ) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    pageContent = 'web';
                                  });
                                  switch (index) {
                                    case 0:
                                      fetchContent(uriTab: 'information');
                                      break;
                                    case 1:
                                      fetchContent(uriTab: 'sounds');
                                      break;
                                    case 2:
                                      fetchContent(uriTab: 'videos');
                                      break;
                                    case 3:
                                      fetchContent(uriTab: 'live');
                                      break;
                                    case 4:
                                      fetchContent(uriTab: 'course_study');
                                      break;
                                    case 5:
                                      fetchContent(uriTab: 'weekly_study');
                                      break;
                                    case 6:
                                      fetchContent(uriTab: 'library');
                                      break;
                                    // case 7:
                                    //   fetchContent(uriTab: 'news');
                                    //   break;
                                    case 7:
                                      fetchContent(uriTab: 'gallery');
                                      break;
                                    case 8:
                                      fetchContent(uriTab: 'attendance');
                                      break;
                                    case 9:
                                      fetchContent(uriTab: 'examination');
                                      break;
                                    case 10:
                                      fetchContent(uriTab: 'messages');
                                      break;
                                    case 11:
                                      fetchContent(uriTab: 'print');
                                      break;
                                    case 12:
                                      fetchContent(uriTab: 'notes');
                                      break;
                                    case 13:
                                      setState(() {
                                        pageContent = 'web';
                                        loadContent = true;
                                        pageFinished = false;
                                      });

                                      Future.delayed(
                                        Duration(milliseconds: 300),
                                        () {
                                          setState(() {
                                            pageFinished = true;

                                            controller.loadHtmlString("""
<div
  dir="rtl"
  style="
    text-align: justify !important;
    font: dijFont-Reg;
    padding: 10px;
    color: #8f8f8f;
  "
>
  <p dir="rtl" style="font-size: 40px">
    مرحبا بكم في منصة الزهراء عليها السلام للدراسة الدينية النسوية.
    <br />
    •⁠ ⁠تأسست هذه المنصة بهدف تقديم تجربة تعليمية متميزة للاخوات الراغبات
    بالانضمام الى الدراسة الحوزوية بالإضافة إلى تعزيز التعليم الديني ونشر
    المعرفة الشرعية عبر العالم الإفتراضي.
    <br />
    •⁠ ⁠تتميز منصة الزهراء عليها السلام بتقديمها دراسة دينية متكاملة انطلاقاً من
    المقدمات وصولاً إلى مرحلة البحث الخارج وبوساطة عدة وفق مستويات تتناسب مع
    إمكانية المتقدمة للدراسة.
    <br />
    •⁠ ⁠يتمتع أساتذة المنصة بخبرة وكفاءة عاليتين تميزهم بتقديم المعرفة الدينية
    بأسلوب شيق ومفيد.
    <br />
    •⁠ ⁠تسعى منصة الزهراء عليها السلام إلى توفير بيئة تعليمية محفزة تساعد
    الطالبة على تحقيق أهدافها العلمية بأقصى قدر من الفاعلية والراحة من خلال
    توفير الدروس الدينية الحوزوية عبر الإنترنت والوصول إلى التعليم بكل ما تتمتع
    به الدراسة الحضورية دون الحاجة إلى الحضور أو السفر.
    <br />
    •⁠ ⁠مقر المنصة في النجف الأشرف وبرعاية الحوزة العلمية الشريفة .
    <br />
    •⁠ ⁠انضموا إلينا اليوم وانطلقوا في رحلة العلم والتعلم المثمر.
  </p>

   <br>
                                                    <br>
                                                    <br>
                                                    <p  style="
                                                        text-align: center !important;
                                                        margin: auto;
                                                        font-size: 50px;
                                                        padding: 10px;
                                                        color: #000;
                                                      ">الاصدار: 1.4.4</p>
                                                      </p>
</div>

""");
                                          });
                                        },
                                      );
                                      controller.loadRequest(
                                        Uri.parse(
                                          'https://ain-alhayat.com/Account?app',
                                        ),
                                      );
                                      break;
                                    case 14:
                                      setState(() {
                                        pageContent = 'grid';
                                      });
                                      dialogBuilder(
                                        context: context,
                                        titleText: 'هل انت متأكد من حذف حسابك؟',
                                        disableText: 'لا',
                                        enableText: 'نعم',
                                        enable: () => logoutAndNavigateToLogin(context),
                                      );
                                      break;
                                    default:
                                  }
                                },
                                child: Image.asset(
                                  'assets/images/${servicesList[index]['icon']}',
                                ),
                              );
                            }),
                          ),
                        )
                      : pageContent == 'web'
                      ? AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: loadContent ? 1 : 0,
                          child: pageFinished
                              ? WebViewWidget(
                                  controller: controller
                                    ..setJavaScriptMode(
                                      JavaScriptMode.unrestricted,
                                    )
                                    ..setBackgroundColor(Colors.white)
                                    ..setNavigationDelegate(
                                      NavigationDelegate(
                                        onProgress: (int progress) {
                                          debugPrint(progress.toString());
                                          if (progress < 79) {
                                            progressP = progress.toString();
                                            setState(() {
                                              pageFinished = false;
                                            });
                                          } else {
                                            setState(() {
                                              pageFinished = true;
                                            });
                                          }
                                        },
                                        onNavigationRequest: (request) {
                                          final uri = Uri.parse(request.url);

                                          // بررسی فایل صوتی mp3
                                          if (uri.path.endsWith('.mp3')) {
                                            // استخراج نام فایل و عنوان (بسته به ساختار خودت)
                                            final dateList = audioName.split(
                                              "+",
                                            ); // یا هر روش دیگه شما
                                            final fileName =
                                                '${dateList[1]}.mp3';
                                            final fileTitle = dateList[0];

                                            // شروع دانلود
                                            checkShouldDownload(
                                              context,
                                              request.url,
                                              fileName,
                                              fileTitle,
                                            );

                                            // جلوی حرکت WebView به اون URL رو بگیر
                                            return NavigationDecision.prevent;
                                          }

                                          // بررسی فایل PDF
                                          if (uri.path.endsWith('.pdf')) {
                                            final fileName =
                                                uri.pathSegments.isNotEmpty
                                                ? uri.pathSegments.last
                                                : 'file.pdf';
                                            final fragment =
                                                uri.fragment.isNotEmpty
                                                ? Uri.decodeFull(uri.fragment)
                                                : '';
                                            final cleanPdfName = fragment
                                                .split('#')[0]
                                                .trim();

                                            pdfName = cleanPdfName;

                                            checkShouldDownload(
                                              context,
                                              request.url,
                                              fileName,
                                              pdfName,
                                            );

                                            return NavigationDecision.prevent;
                                          }

                                          // اجازه ادامه مسیر برای سایر URL ها
                                          return NavigationDecision.navigate;
                                        },
                                        onPageStarted: (url) async {
                                          debugPrint(
                                            'onPageStarted==========-====>>>$url',
                                          );

                                          final uri = Uri.parse(url);

                                          if (uri.path.endsWith('.mp3')) {
                                            final dateList = audioName.split(
                                              "+",
                                            );
                                            final fileName =
                                                '${dateList[1]}.mp3';
                                            final fileTitle = dateList[0];

                                            checkShouldDownload(
                                              context,
                                              url,
                                              fileName,
                                              fileTitle,
                                            );
                                          } else if (uri.path.endsWith(
                                            '.pdf',
                                          )) {
                                            final fileName =
                                                uri.pathSegments.isNotEmpty
                                                ? uri.pathSegments.last
                                                : 'file.pdf';

                                            var rawTitle =
                                                uri.fragment.isNotEmpty
                                                ? Uri.decodeFull(uri.fragment)
                                                : 'PDF Document';

                                            final cleanTitle = rawTitle
                                                .split('#')[0]
                                                .trim();

                                            checkShouldDownload(
                                              context,
                                              url,
                                              fileName,
                                              cleanTitle,
                                            );
                                          }
                                        },
                                        onPageFinished: (url) {
                                          controller.runJavaScript('''
                                                  var audios = document.querySelectorAll("audio");
                                                  audios.forEach(a => { a.setAttribute("playsinline", "true"); });
                                                ''');
                                          debugPrint(
                                            'onPageFinished==========-====>>>$url',
                                          );

                                          // جاوااسکریپت برای تنظیم بک‌گراند صفحه به سفید
                                          controller.runJavaScript(
                                            "document.body.style.backgroundColor = 'white';",
                                          );
                                        },
                                      ),
                                    )
                                    ..runJavaScript("""
                                    let navLinks = document.querySelectorAll(".download_link");
                                    navLinks.forEach(function (link) {
                                      link.addEventListener("click", function (event) {
                                        var val = link.getAttribute("title") + "+" + link.getAttribute("data-id");
                                        Print11.postMessage(val);
                                      });
                                    });
                                  """),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LoadingProgress(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      Gap(10),
                                      Text(
                                        progressP + '%',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        )
                      : pageContent == 'offline'
                      ? OfflinePage()
                      : SingleChildScrollView(
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: bodyContent.isNotEmpty
                                ? Column(
                                    children: [
                                      ...List.generate(bodyContent.length, (
                                        index,
                                      ) {
                                        return NotifCard(
                                          body: titleContent[index],
                                          date: dateContent[index],
                                        );
                                      }),
                                    ],
                                  )
                                : Center(
                                    child: Text(
                                      'لا توجد نتائج',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                ),
              ),
              Positioned.fill(
                child: ValueListenableBuilder<bool>(
                  valueListenable: showDownloadPanelNotifier,
                  builder: (context, show, _) {
                    if (!show) return const SizedBox.shrink();
                    return Container(
                      width: size.width,
                      height: size.height,
                      color: Colors.black54,
                      child: Center(
                        child: Container(
                          width: 300,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'تحميل الملف...',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(16),
                              const LoadingProgress(),
                              const Gap(16),
                              // progress bar
                              ValueListenableBuilder<int>(
                                valueListenable: DownloadProgress.progress,
                                builder: (context, value, _) {
                                  return Column(
                                    children: [
                                      LinearProgressIndicator(
                                        value: value / 100,
                                        backgroundColor: Colors.white24,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '$value%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Theme.of(context).primaryColorLight,
        //   shape: const CircleBorder(),
        //   onPressed: () {
        //     setState(() {
        //       pageContent = 'offline';
        //     });
        //     fetchContent(uriTab: 'sounds');
        //   },
        //   child: SvgPicture.asset(
        //     './assets/svgs/download.svg',
        //     colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        //   ),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _bottomNavIndex,
            onTap: null,

            items: [
              BottomNavigationBarItem(
                icon: buildSvgIcon('assets/svgs/house-chimney-blank.svg', 0),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: buildSvgIcon('assets/svgs/comment.svg', 1),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: buildSvgIcon('assets/svgs/download.svg', 2),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: buildSvgIcon('assets/svgs/books-lightbulb.svg', 3),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: buildSvgIcon('assets/svgs/journal-alt.svg', 4),
                label: '',
              ),
            ],
          ),
        ),

        // bottomNavigationBar: AnimatedBottomNavigationBar(
        //   icons: iconList,
        //   inactiveColor: Theme.of(context).primaryColorLight,
        //   iconSize: 30,
        //   activeIndex: _bottomNavIndex,
        //   activeColor: Theme.of(context).secondaryHeaderColor,
        //   gapLocation: GapLocation.center,
        //   notchSmoothness: NotchSmoothness.verySmoothEdge,
        //   onTap: (index) {
        //     setState(() {
        //       _bottomNavIndex = index;
        //       switch (_bottomNavIndex) {
        //         case 0:
        //           setState(() {
        //             loadContent = false;
        //             pageContent = 'grid';
        //           });
        //           break;
        //         case 1:
        //           setState(() {
        //             pageContent = 'web';
        //           });
        //           fetchContent(uriTab: 'messages');
        //           break;
        //         case 2:
        //           setState(() {
        //             pageContent = 'web';
        //           });
        //           fetchContent(uriTab: 'library');
        //           break;
        //         case 3:
        //           setState(() {
        //             pageContent = 'web';
        //           });
        //           fetchContent(uriTab: 'notes');
        //           break;
        //         default:
        //       }
        //     });
        //   },
        // ),
      ),
    );
  }

  Widget buildSvgIcon(String asset, int index) {
    return Transform.translate(
      offset: const Offset(0, 8),
      child: Transform.scale(
        scale: 1.2,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _bottomNavIndex = index;
              switch (index) {
                case 0:
                  loadContent = false;
                  pageContent = 'grid';
                  break;

                case 1:
                  pageContent = 'web';
                  fetchContent(uriTab: 'messages');
                  break;

                case 2:
                  pageContent = 'offline';
                  fetchContent(uriTab: 'sounds');
                  break;

                case 3:
                  pageContent = 'web';
                  fetchContent(uriTab: 'library');
                  break;

                case 4:
                  pageContent = 'web';
                  fetchContent(uriTab: 'notes');
                  break;

                default:
              }
            });
            setState(() {});
          },
          child: SvgPicture.asset(
            asset,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              _bottomNavIndex == index
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  fetchContent({required String uriTab}) {
    debugPrint(
      'token===========================>>>' +
          Constants.getStorage.read('userData')['token'],
    );
    setState(() {
      loadContent = true;
      controller.loadRequest(
        Uri.parse('https://ain-alhayat.com/Account?tab=$uriTab'),
        headers: {
          "Authorization":
              "Bearer ${Constants.getStorage.read('userData')['token']}",
          "Embed": '1',
        },
      );
    });
  }

  Future<void> checkShouldDownload(
    BuildContext context,
    String url,
    String fileName,
    String filetitle,
  ) async {
    final cleanTitle = filetitle.split('#')[0].trim();
    final fileExtension = p.extension(fileName);
    print("fileExtension=====>$fileExtension");

    if (fileExtension == '.mp3' || fileExtension == '.pdf') {
      final boxName = fileExtension == '.mp3' ? 'audioes' : 'pdfs';
      final listKey = fileExtension == '.mp3' ? 'audioName' : 'pdfName';

      await GetStorage.init(boxName);
      final storage = GetStorage(boxName);
      List filesList = storage.read(boxName) ?? [];

      final alreadyExists = filesList.any(
        (item) => item[listKey] == cleanTitle,
      );
      if (alreadyExists) {
        showInfoDialog(
          context,
          titleText: 'تم تحميل هذا الملف مسبقا!',
        );
        return;
      }

      final appDocDir = await getApplicationDocumentsDirectory();
      final baseStorage = Platform.isAndroid
          ? '/storage/emulated/0/Download'
          : appDocDir.path;

      final downloadDir = Directory(baseStorage);
      if (!(await downloadDir.exists())) {
        await downloadDir.create(recursive: true);
      }

      final fullFilePath = '$baseStorage/$fileName';

      /// ✅ اینجا پنل رو فعال کن با استفاده از ValueNotifier
      DownloadProgress.progress.value = 0;
      showDownloadPanelNotifier.value = true; // مهم: تغییر مقدار notifier

      final taskId = await FlutterDownloader.enqueue(
        url: url.trim(),
        savedDir: baseStorage,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );

      // ذخیره فایل
      filesList.add({
        listKey: cleanTitle,
        'fileName': fileName,
        'filePath': fullFilePath,
      });
      storage.write(boxName, filesList);
      print('filesList after save: ${storage.read(boxName)}');
    }
  }

  void bindBackgroundIsolate() {
    final port = ReceivePort();

    IsolateNameServer.removePortNameMapping('downloader_send_port');
    IsolateNameServer.registerPortWithName(
      port.sendPort,
      'downloader_send_port',
    );

    port.listen((dynamic data) {
      final String id = data[0] as String;
      final int status = data[1] as int;
      final int progress = data[2] as int;

      DownloadProgress.progress.value = progress;

      if (status == DownloadTaskStatus.complete || progress == 100) {
        showDownloadPanelNotifier.value =
            false; // Hide the panel when download is complete
      } else if (status == DownloadTaskStatus.failed) {
        showDownloadPanelNotifier.value = false; // Also hide on failure
      } else {
        showDownloadPanelNotifier.value = true; // Show panel while downloading
      }
    });
  }
}
