
import 'package:flutter_test/flutter_test.dart';
import 'package:rgb_remote/core/extensions/string_extensions.dart';

void main() {
  group('StringExtensions', () {
    test('capitalize converts words to title case', () {
      expect('hELLO wORLD'.capitalize(), 'Hello World');
    });

    test('capitalize normalizes repeated whitespace', () {
      expect('  hello   WORLD  '.capitalize(), 'Hello World');
    });

    test('capitalize handles tabs and newlines', () {
      expect('hello\tWORLD\nagain'.capitalize(), 'Hello World Again');
    });

    test('capitalize handles empty strings', () {
      expect(''.capitalize(), '');
    });

    test('formatName replaces underscores and normalizes words', () {
      expect('rgb_remote_controller'.formatName(),
          'Rgb Remote Controller');
    });

    test('formatName handles repeated underscores', () {
      expect('RGB__REMOTE'.formatName(), 'Rgb Remote');
    });
  });
}
