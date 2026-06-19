import 'package:alhayat/common/utils/costum_loading.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AsyncStatusBuilder extends StatelessWidget {
  const AsyncStatusBuilder({
    super.key,
    required this.future,
    required this.onDone,
    this.loadingText = 'يرجى الانتظار..',
    this.loadingColor,
  });

  final Future? future;
  final Widget Function(AsyncSnapshot snapshot) onDone;
  final String loadingText;
  final Color? loadingColor;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const SizedBox();
          case ConnectionState.waiting:
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingProgress(color: loadingColor),
                const Gap(15),
                Text(
                  loadingText,
                  style: TextStyle(
                    color: loadingColor ?? Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          case ConnectionState.done:
            return onDone(snapshot);
          default:
            return const SizedBox();
        }
      },
    );
  }
}

class ErrorRow extends StatelessWidget {
  const ErrorRow({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
        const Gap(5),
        Text(
          message,
          style: const TextStyle(color: Colors.red, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class SuccessRow extends StatelessWidget {
  const SuccessRow({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.done, color: Colors.green, size: 20),
        const Gap(5),
        Text(
          message,
          style: const TextStyle(color: Colors.green, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
