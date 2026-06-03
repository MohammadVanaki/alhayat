import 'package:alhayat/common/utils/costum_dialog_message.dart';
import 'package:flutter/material.dart';

void showFileNotFoundDialog(BuildContext context) {
  dialogBuilder(
    context: context,
    titleText: 'الملف غير موجود!',
    disableText: '',
    enableText: 'إغلاق',
    enable: () => Navigator.of(context).pop(),
  );
}

void showInfoDialog(
  BuildContext context, {
  required String titleText,
  String enableText = 'اغلاق',
}) {
  dialogBuilder(
    context: context,
    titleText: titleText,
    disableText: '',
    enableText: enableText,
    enable: () => Navigator.of(context).pop(),
  );
}
