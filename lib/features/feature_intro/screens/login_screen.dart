import 'package:alhayat/common/widgets/async_status_builder.dart';
import 'package:alhayat/common/widgets/auth_form_card.dart';
import 'package:alhayat/common/widgets/input.dart';
import 'package:alhayat/features/feature_intro/data/data_source/auth_api_provider.dart';
import 'package:alhayat/features/feature_intro/screens/forgot_password_screen.dart';
import 'package:flutter/material.dart';
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
  final f1 = FocusNode();
  final f2 = FocusNode();
  Future? _userValidateFuture;

  @override
  Widget build(BuildContext context) {
    return AuthFormCard(
      formContent: Form(
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
            ElevatedButton(
              onPressed: () {
                setState(() {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _userValidateFuture = userValidate(
                    email: _controllerEmail.text,
                    password: _controllerPassword.text,
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
      bottomChildren: [
        Positioned(
          bottom: 100,
          child: AsyncStatusBuilder(
            future: _userValidateFuture,
            loadingText: 'انتظر من فضلك',
            loadingColor: Theme.of(context).primaryColor,
            onDone: (snapshot) {
              return snapshot.data?['errors'][0] != null
                  ? ErrorRow(message: snapshot.data['errors'][0])
                  : const SizedBox();
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
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
