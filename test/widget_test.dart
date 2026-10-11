import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgb_remote/core/config/app_theme.dart';

void main() {
  test('dark app theme is configured', () {
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(AppTheme.dark.dialogTheme, isNotNull);
  });
}
