import 'package:flutter/material.dart';
import 'dart:async';

import 'package:tappay/tappay.dart';
import 'package:tappay/model/credit_card.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      var tappa = TapPay();
      tappa.initTapPay(0, "", ServerType.TEST);
      tappa.cardValid(CreditCard("", "", "", ""));
      platformVersion = await tappa.getToken(CreditCard("", "", "", ""));

      print('$platformVersion');
      print('${await tappa.getLastFour()}');
      print('${await tappa.getCardType()}');
      print('${await tappa.getIdentifier()}');
    } catch (e) {
      print('$e');
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: [
            FlatButton(
                onPressed: () {
                  initPlatformState();
                },
                child: Icon(Icons.info))
          ],
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
