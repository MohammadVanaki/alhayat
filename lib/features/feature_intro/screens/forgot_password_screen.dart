import 'package:alhayat/common/widgets/async_status_builder.dart';
import 'package:alhayat/common/widgets/auth_form_card.dart';
import 'package:alhayat/common/widgets/input.dart';
import 'package:alhayat/features/feature_intro/data/data_source/forgot_api_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _controllerEmail = TextEditingController();
  Future? _forgotPasswordFuture;

  @override
  Widget build(BuildContext context) {
    return AuthFormCard(
      formContent: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'نسيت كلمة المرور',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(20),
            FormInput(
              labelText: 'البريد الالكتروني',
              obscureText: false,
              controller: _controllerEmail,
            ),
            const Gap(20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _forgotPasswordFuture =
                      userForgotPassword(email: _controllerEmail.text);
                });
              },
              child: Text(
                'ارسال',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomChildren: [
        Positioned(
          bottom: 60,
          child: AsyncStatusBuilder(
            future: _forgotPasswordFuture,
            onDone: (snapshot) {
              debugPrint('${snapshot.data?['errors']}');
              return snapshot.data?['errors'] != null
                  ? ErrorRow(
                      message: snapshot.data['errors'][0] ?? '',
                    )
                  : const SuccessRow(
                      message: 'تم ارسال الرمز الجديد على البريد الالكتروني',
                    );
            },
          ),
        ),
      ],
    );
  }
}
