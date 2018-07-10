import 'package:flutter/material.dart';

class JoinGamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // color: Colors.white,
      appBar: new AppBar(
        elevation: -1.0,
        title: new Text("Join Game",
            style: new TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
              letterSpacing: 0.5,
              fontSize: 22.0,
            )),
      ),
      body: Column(children: <Widget>[
        Expanded(child: new Container()),
        Padding(
          padding: const EdgeInsets.all(65.0),
        ),
      ]),
    );
  }
}
