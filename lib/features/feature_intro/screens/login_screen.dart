import 'package:alhayat/common/utils/costum_loading.dart';
import 'package:alhayat/common/widgets/input.dart';
import 'package:alhayat/features/feature_intro/data/data_source/auth_api_provider.dart';
import 'package:alhayat/features/feature_intro/screens/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final f1 = FocusNode();
  final f2 = FocusNode();
  Future? _userValidateFuture;
  String? _validationError;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/svgs/Sprinkle.svg',
              fit: BoxFit.fill,
              height: size.height,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              width: size.width * 0.9,
              height: size.height * 0.4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 1,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(20),
                    FormInput(
                      labelText: 'بريد المستخدم',
                      obscureText: false,
                      controller: _controllerEmail,
                      focusNode: f1,
                      onEditingComplete: () => f2.requestFocus(),
                      autofillHints: const [AutofillHints.email],
                    ),
                    const Gap(20),
                    FormInput(
                      labelText: 'كلمة المرور',
                      obscureText: true,
                      controller: _controllerPassword,
                      focusNode: f2,
                      onEditingComplete: () {},
                      autofillHints: const [AutofillHints.password],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: const ForgotPasswordPage(),
                              type: PageTransitionType.bottomToTop,
                            ),
                          );
                        },
                        child: Text(
                          'نسيت كلمة المرور',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    if (_validationError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _validationError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        final email = _controllerEmail.text.trim();
                        final password = _controllerPassword.text;
                        if (email.isEmpty || password.isEmpty) {
                          setState(() {
                            _validationError =
                                'يرجى إدخال البريد الالكتروني وكلمة المرور';
                          });
                          return;
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                          setState(() {
                            _validationError =
                                'يرجى إدخال بريد الكتروني صحيح';
                          });
                          return;
                        }
                        setState(() {
                          _validationError = null;
                          _userValidateFuture = userValidate(
                            email: email,
                            password: password,
                            context: context,
                          );
                        });
                      },
                      child: Text(
                        'دخول',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              child: FutureBuilder(
                future: _userValidateFuture,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return const SizedBox();
                    case ConnectionState.waiting:
                      return Column(
                        children: [
                          LoadingProgress(
                            color: Theme.of(context).primaryColor,
                          ),
                          Gap(15),
                          Text(
                            'انتظر من فضلك',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    case ConnectionState.done:
                      return snapshot.data?['errors'][0] != null
                          ? Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const Gap(5),
                                Text(
                                  snapshot.data['errors'][0],
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : const SizedBox();
                    default:
                      return const SizedBox();
                  }
                },
              ),
            ),
            Positioned(
              bottom: 10,
              child: TextButton(
                onPressed: () {
                  _launchUrl(Uri.parse('https://ain-alhayat.com/Register'));
                },
                child: const Text(
                  'تسجيل في المنصة',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
