import 'package:flutter/services.dart';

class BackPressHandler {
  BackPressHandler._();

  static Future<void> handleBackPress() async {
    await SystemNavigator.pop();
  }
}
