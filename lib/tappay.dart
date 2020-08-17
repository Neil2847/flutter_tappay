import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tappay/model/valid_response.dart';

import 'model/credit_card.dart';

class Tappay {
  static const MethodChannel _channel = const MethodChannel('tappay/bridge');

  static Future<String> get platformVersion async {
    return await _channel.invokeMethod('getDirectPayToken', {
      "cardNumber": "4242424242424242",
      "dueMonth": "01",
      "dueYear": "23",
      "CCV": "123"
    });
  }

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
  Future<void> cardValid(CreditCard card) async {
    try {
      await _channel.invokeMethod('cardValid', {
        'cardNumber': card.number,
        'dueMonth': card.dueMonth,
        'dueYear': card.dueYear,
        'CCV': card.ccv
      });
      return ValidResponse();
    } catch (e) {
      print('>> $e');
    }
  }

  // -------------------------------------------
  Future<String> getToken(CreditCard card) async {
    try {
      return await _channel.invokeMethod('getDirectPayToken', {
        'cardNumber': card.number,
        'dueMonth': card.dueMonth,
        'dueYear': card.dueYear,
        'CCV': card.ccv
      });
    } catch (e) {
      print(e);
    }
  }
}
