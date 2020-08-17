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

  @override
  void initState() {
    super.initState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;

    var tappa = Tappay();
    tappa.initTapPay(0, '');
    tappa.cardValid(CreditCard("", "", "", ""));

    platformVersion = await tappa.getToken(CreditCard("", "", "", ""));

    try {} catch (e) {
      print('>>>> $e');
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
                child: Icon(Icons.add))
          ],
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
