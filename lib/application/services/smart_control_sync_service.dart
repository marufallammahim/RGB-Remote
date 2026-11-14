import 'settings_service.dart';
import '../../plugins/ir_sensor_plugin.dart';
import '../../resources/pronto_data.dart';

/// Keeps the native Android widget and Device Controls supplied with the
/// currently selected preset's ON/OFF Pronto commands.
class SmartControlSyncService {
  static Future<void> syncSelectedRemote() async {
    final remoteIndex = SettingsService().settingsNotifier.value.remoteIndex;
    await syncRemote(remoteIndex);
  }

  static Future<void> syncRemote(int remoteIndex) async {
    final type = remoteIndex == 1
        ? ProntoDataType.type2
        : ProntoDataType.type1;
    final commands = getProntoData(type);

    final onCommand = commands.firstWhere(
      (command) => command.name.trim().toUpperCase() == 'ON',
    );
    final offCommand = commands.firstWhere(
      (command) => command.name.trim().toUpperCase() == 'OFF',
    );

    await IrSensorPlugin.syncSmartControlCommands(
      onPattern: onCommand.pattern,
      offPattern: offCommand.pattern,
    );
  }
}
