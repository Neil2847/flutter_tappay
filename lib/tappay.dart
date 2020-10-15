import 'dart:async';

import 'package:flutter/services.dart';

import 'model/credit_card.dart';

class TapPay {
  static const MethodChannel _channel = const MethodChannel('tappay/bridge');

  // -------------------------------------------
  void initTapPay(int id, String appKey) async {
    try {
      await _channel
          .invokeMethod('initTapPay', {"appId": id, "appKey": appKey});
    } catch (e) {
      print(e);
    }
  }

  // -------------------------------------------
  Future<bool> cardValid(CreditCard card) async {
    return await _channel.invokeMethod('cardValid', {
      'cardNumber': card.number,
      'dueMonth': card.dueMonth,
      'dueYear': card.dueYear,
      'CCV': card.ccv
    });
  }

  // -------------------------------------------
  Future<String> getToken(CreditCard card) async {
    return await _channel.invokeMethod('getDirectPayToken', {
      'cardNumber': card.number,
      'dueMonth': card.dueMonth,
      'dueYear': card.dueYear,
      'CCV': card.ccv
    });
  }
}
