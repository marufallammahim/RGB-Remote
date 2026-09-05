import 'package:flutter/services.dart';

class BackPressHandler {
  static Future<void> handleBackPress() async {
    SystemNavigator.pop();
  }
}
