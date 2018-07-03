import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_page.dart';
import 'info_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    InfoPage.tag: (context) => InfoPage(),
    HomePage.tag: (context) => HomePage(),
  };

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Party Quest',
      theme: new ThemeData(
        primaryColor: Colors.black,
      ),
      home: new HomePage(),
      routes: routes
    );
  }
}
