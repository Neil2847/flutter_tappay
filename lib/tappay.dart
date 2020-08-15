import 'dart:async';

import 'package:flutter/services.dart';

class Tappay {
  static const MethodChannel _channel = const MethodChannel('tappay/bridge');

  static Future<String> get platformVersion async {
    final String version = '33';
    await _channel.invokeMethod('getDirectPayToken', {
      "cardNumber": "12312312312313",
      "dueMonth": "01",
      "dueYear": "55",
      "CCV": "999"
    });
    return version;
  }
}
