import 'package:flutter/material.dart';
import 'application.dart';
import 'package:fluro/fluro.dart';
import 'package:gratzi_game/globals.dart' as globals;

class SplashPages extends StatefulWidget {
  @override
  createState() => SplashPagesState();
}

class SplashPagesState extends State<SplashPages> {
  List<Widget> pages = [
    Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text("Some text")
        )),
    Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[Text("Some text"), Text("More text")],
        ))
  ];

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: pages,
    );
  }

  void _submitUserData() {
    Application.router
        .navigateTo(context, 'info', transition: TransitionType.native);
  }
}
