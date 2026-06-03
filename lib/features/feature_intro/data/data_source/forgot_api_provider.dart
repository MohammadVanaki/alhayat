import 'package:alhayat/common/utils/api_client.dart';

Future userForgotPassword({required String email}) async {
  final response = await ApiClient.post(
    '/api/v1/forget-password',
    queryParameters: {'email': email},
  );
  if (response.statusCode == 200) {
    return ApiClient.decodeBody(response);
  } else {
    return {
      'errors': ['بريد المستخدم غير مسجل']
    };
  }
}
