import 'package:flutter/services.dart';

class IrSensorPlugin {
  static const MethodChannel _channel = MethodChannel('ir_sensor_plugin');
  static void Function(bool increase)? onHardwareVolumeKey;
  static bool _handlerInstalled = false;

  /// Installs the single native-to-Dart callback once. Volume keys are only
  /// consumed by Android while this app is foregrounded.
  static void installHardwareVolumeKeyHandler() {
    if (_handlerInstalled) return;
    _handlerInstalled = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'hardwareVolumeKey') {
        final direction = call.arguments is Map
            ? (call.arguments as Map)['direction']
            : null;
        if (direction == 'up') {
          onHardwareVolumeKey?.call(true);
        } else if (direction == 'down') {
          onHardwareVolumeKey?.call(false);
        }
      }
    });
  }

  /// Check whether the device has an infrared emitter.
  static Future<bool> get hasIrEmitter async {
    return await _channel.invokeMethod('hasIrEmitter');
  }

  /// Query the infrared transmitter's supported carrier frequencies in Hertz.
  static Future<String> get getCarrierFrequencies async {
    return await _channel.invokeMethod('getCarrierFrequencies');
  }

  /// Change the frequency with which it is transmitted. Default is 38020 Hz.
  static Future<String> setFrequencies(int newFrequency) async {
    return await _channel.invokeMethod('setFrequency', {"setFrequency": newFrequency});
  }

  static Future<String> transmitString({required String pattern}) async {
    return await _channel.invokeMethod('codeForEmitter', {"codeForEmitter": pattern});
  }

  static Future<String> transmitListInt({required List<int> list}) async {
    return await _channel.invokeMethod('transmitListInt', {"transmitListInt": list});
  }

  /// Shares the selected preset's ON/OFF/WHITE Pronto commands with native
  /// Android components so widgets and Device Controls work without Flutter.
  static Future<void> syncSmartControlCommands({
    required String onPattern,
    required String offPattern,
    required String whitePattern,
  }) async {
    await _channel.invokeMethod('syncSmartControlCommands', {
      'onPattern': onPattern,
      'offPattern': offPattern,
      'whitePattern': whitePattern,
    });
  }

  static Future<void> vibrate() async {
    return await _channel.invokeMethod('vibrate');
  }

  static Future<Map<String, int>> rawSoundList() async {
    final rawSoundList = await _channel.invokeMethod('rawSoundList');
    return (rawSoundList as Map<Object?, Object?>).cast<String, int>();
  }

  static Future<void> playSound({required String? soundName}) async {
    return await _channel.invokeMethod('playSound', {"soundName": soundName});
  }
}
