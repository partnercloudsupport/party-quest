import 'package:flutter/material.dart';
// import 'package:login/home_page.dart';

class InfoPage extends StatefulWidget {
  static String tag = 'info-page';
  @override
  _InfoPageState createState() => new _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: new Text("Quest Info"),
      ),
    );

    final body = new ListView(
      // padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        new ListTile(
          title: new Text("Characters",
              style: new TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontFamily: 'Roboto',
                letterSpacing: 0.5,
                fontSize: 22.0,
              )),
          // leading: new Icon(Icons.explore),
          // onTap: () {
          //   Navigator.of(context).pop();
          //   Navigator.of(context).push(new MaterialPageRoute(
          //       builder: (BuildContext context) => new Page("First Page")));
          // }
        ),
        new ListTile(
            title: new Text("Patty the Punk"),
            subtitle: new Text("Level 1 - Played by Bobby")
            // leading: new Icon(Icons.explore),
            // onTap: () {
            //   Navigator.of(context).pop();
            //   Navigator.of(context).push(new MaterialPageRoute(
            //       builder: (BuildContext context) => new Page("First Page")));
            // }
            ),
        new ListTile(
            title: new Text("Slipp the Dogger"),
            subtitle: new Text("Level 1 - Played by You")
            // leading: new Icon(Icons.contacts),
            // onTap: () {
            //   Navigator.of(context).pop();
            //   Navigator.of(context).push(new MaterialPageRoute(
            //       builder: (BuildContext context) =>
            //           new Page("Second Page")));
            // }
            ),
        new ListTile(
            title: new Text("Vert the Suit"),
            subtitle: new Text("Level 1 - Played by Joe")
            // leading: new Icon(Icons.settings),
            // onTap: () {
            //   Navigator.of(context).pop();
            //   Navigator.of(context).push(new MaterialPageRoute(
            //       builder: (BuildContext context) =>
            //           new Page("Second Page")));
            // }
            ),
      ],
    );

    void _closeInfoView () {
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: new AppBar(
        title: new Text('Quest Info'),
        leading: null,
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.close),
              tooltip: 'Close',
              onPressed: _closeInfoView)
        ],
      ),
      body: body,
    );
  }
}
