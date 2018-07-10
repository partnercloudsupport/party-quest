import 'package:flutter/material.dart';

class MyGamesPage extends StatefulWidget {
  static String tag = 'MyGames-page';
  @override
  _MyGamesPageState createState() => new _MyGamesPageState();
}

class _MyGamesPageState extends State<MyGamesPage> {
  @override
  Widget build(BuildContext context) {

    final body = new ListView(
      // padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        new ListTile(
            title: new Text("Jim, Joe, Bob"),
            subtitle: new Text("Level 21 - Winner: Joe")
            ),
        new ListTile(
            title: new Text("Cathy, Sue, Randy"),
            subtitle: new Text("Level 1 - Winner: You")
            )
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        elevation: -1.0,
        title: new Text("My Games",
              style: new TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontFamily: 'Roboto',
                letterSpacing: 0.5,
                fontSize: 22.0,
              )),
      ),
      body: body,
    );
  }
}
