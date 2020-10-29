import 'dart:async';

import 'package:flutter/services.dart';

import 'model/credit_card.dart';

enum ServerType { TEST, RELEASE }

class TapPay {
  static const MethodChannel _channel = const MethodChannel('tappay/bridge');

  // -------------------------------------------
  int getType(ServerType type) {
    return type == ServerType.TEST ? 0 : 1;
  }

  // -------------------------------------------
  void initTapPay(int id, String appKey, ServerType type) async {
    try {
      await _channel.invokeMethod(
          'initTapPay', {"appId": id, "appKey": appKey, "type": getType(type)});
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

  // -------------------------------------------
  Future<String> getIdentifier() async {
    return await _channel.invokeMethod('identifier');
  }

  // -------------------------------------------
  Future<int> getCardType() async {
    return await _channel.invokeMethod('cardType');
  }

  // -------------------------------------------
  Future<String> getLastFour() async {
    return await _channel.invokeMethod('lastFour');
  }
}
