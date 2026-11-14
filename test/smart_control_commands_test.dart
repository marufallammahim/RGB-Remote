import 'package:flutter_test/flutter_test.dart';
import 'package:rgb_remote/resources/pronto_data.dart';

void main() {
  for (final type in ProntoDataType.values) {
    test('${type.name} preset exposes valid LIGHT ON and LIGHT OFF commands', () {
      final commands = getProntoData(type);
      final onCommands = commands
          .where((command) => command.name.trim().toUpperCase() == 'ON')
          .toList();
      final offCommands = commands
          .where((command) => command.name.trim().toUpperCase() == 'OFF')
          .toList();

      expect(onCommands, hasLength(1));
      expect(offCommands, hasLength(1));

      for (final command in [onCommands.single, offCommands.single]) {
        final words = command.pattern.trim().split(RegExp(r'\s+'));
        expect(words.length, greaterThanOrEqualTo(6));
        expect(words.first.toUpperCase(), '0000');
        expect(words.every((word) => RegExp(r'^[0-9A-Fa-f]{1,4}$').hasMatch(word)), isTrue);
      }
    });
  }
}
