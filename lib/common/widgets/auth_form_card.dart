import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    super.key,
    required this.formContent,
    this.heightFactor = 0.4,
    this.bottomChildren = const [],
  });

  final Widget formContent;
  final double heightFactor;
  final List<Widget> bottomChildren;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
              padding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              width: size.width * 0.9,
              height: size.height * heightFactor,
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
              child: formContent,
            ),
            ...bottomChildren,
          ],
        ),
      ),
    );
  }
}
