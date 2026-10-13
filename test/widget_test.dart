import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgb_remote/core/config/app_theme.dart';
import 'package:rgb_remote/domain/entities/app_settings.dart';

void main() {
  test('dark app theme is configured', () {
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(AppTheme.dark.dialogTheme, isNotNull);
  });

  test('AMOLED theme uses a pure black scaffold', () {
    expect(AppTheme.amoled.scaffoldBackgroundColor, Colors.black);
  });

  test('vibration is disabled by default and dark theme is default', () {
    const settings = AppSettings();
    expect(settings.isVibrationEnabled, isFalse);
    expect(settings.themeName, 'dark');
  });

  test('copyWith can clear an optional sound name', () {
    const settings = AppSettings(soundFileName: 'tap');
    expect(settings.copyWith(soundFileName: null).soundFileName, isNull);
  });
}
