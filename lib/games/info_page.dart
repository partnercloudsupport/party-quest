import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  static String tag = 'info-page';
  @override
  _InfoPageState createState() => new _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {

    final body = new ListView(
      // padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        // new ListTile(
        //   title: new Text("Characters",
        //       style: new TextStyle(
        //         color: Colors.black,
        //         fontWeight: FontWeight.w800,
        //         fontFamily: 'Roboto',
        //         letterSpacing: 0.5,
        //         fontSize: 22.0,
        //       )),
        // ),
        new ListTile(
            title: new Text("Patty the Punk"),
            subtitle: new Text("Level 1 - Played by Bobby")
            ),
        new ListTile(
            title: new Text("Slipp the Dogger"),
            subtitle: new Text("Level 1 - Played by You")
            ),
        new ListTile(
            title: new Text("Vert the Suit"),
            subtitle: new Text("Level 1 - Played by Joe")
            ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        elevation: -1.0,
        title: new Text("Game Info",
              style: new TextStyle(
                color: Colors.black,
                // fontWeight: FontWeight.w800,
                fontFamily: 'Roboto',
                // letterSpacing: 0.5,
                // fontSize: 22.0,
              )),
        // leading: null,
        // actions: <Widget>[
        //   new IconButton(
        //       icon: new Icon(Icons.close),
        //       tooltip: 'Close',
        //       onPressed: _closeInfoView)
        // ],
      ),
      body: body,
    );
  }
}
