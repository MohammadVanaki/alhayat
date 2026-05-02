import 'package:flutter/material.dart';

class MyThemes {
  static final lightTheme = ThemeData(
    textTheme: const TextTheme(
      titleMedium: TextStyle(
        fontFamily: "Bloomberg",
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(
        fontFamily: "Bloomberg",
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
    ),
    highlightColor: Colors.grey,
    unselectedWidgetColor: Colors.black,
    appBarTheme: AppBarTheme(
      color: const Color.fromARGB(255, 4, 98, 104).withAlpha(50),
    ),
    primaryColorLight: const Color.fromARGB(255, 2, 71, 78),
    primaryColor: const Color.fromARGB(255, 4, 98, 104),
    scaffoldBackgroundColor: Colors.white,
    indicatorColor: Colors.amber,
    colorScheme: ColorScheme.light(
      primary: const Color.fromARGB(255, 2, 71, 78),
    ),
    secondaryHeaderColor: const Color.fromRGBO(0, 137, 142, 1),
    iconTheme: const IconThemeData(color: Color.fromARGB(255, 211, 169, 64)),
    fontFamily: 'Bloomberg',
  );
}
