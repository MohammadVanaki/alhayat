import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhayat/config/light_theme.dart';

void main() {
  group('MyThemes', () {
    final theme = MyThemes.lightTheme;

    test('lightTheme should not be null', () {
      expect(theme, isNotNull);
    });

    test('scaffold background color should be white', () {
      expect(theme.scaffoldBackgroundColor, Colors.white);
    });

    test('primary color should be Color(4, 98, 104)', () {
      expect(theme.primaryColor, const Color.fromARGB(255, 4, 98, 104));
    });

    test('primaryColorLight should be Color(2, 71, 78)', () {
      expect(theme.primaryColorLight, const Color.fromARGB(255, 2, 71, 78));
    });

    test('indicator color should be amber', () {
      // ignore: deprecated_member_use
      expect(theme.indicatorColor, Colors.amber);
    });

    test('titleMedium text style should have correct properties', () {
      final titleMedium = theme.textTheme.titleMedium;
      expect(titleMedium, isNotNull);
      expect(titleMedium!.fontFamily, 'Bloomberg');
      expect(titleMedium.fontSize, 20);
      expect(titleMedium.fontWeight, FontWeight.bold);
    });

    test('bodyMedium text style should have correct properties', () {
      final bodyMedium = theme.textTheme.bodyMedium;
      expect(bodyMedium, isNotNull);
      expect(bodyMedium!.fontFamily, 'Bloomberg');
      expect(bodyMedium.fontSize, 15);
      expect(bodyMedium.fontWeight, FontWeight.w400);
    });

    test('colorScheme primary should match primaryColorLight', () {
      expect(
        theme.colorScheme.primary,
        const Color.fromARGB(255, 2, 71, 78),
      );
    });

    test('secondaryHeaderColor should be Color(0, 137, 142)', () {
      expect(
        theme.secondaryHeaderColor,
        const Color.fromRGBO(0, 137, 142, 1),
      );
    });

    test('icon theme color should be gold', () {
      expect(
        theme.iconTheme.color,
        const Color.fromARGB(255, 211, 169, 64),
      );
    });

    test('highlight color should be grey', () {
      expect(theme.highlightColor, Colors.grey);
    });

    test('uses material design', () {
      expect(theme.useMaterial3, isNotNull);
    });
  });
}
