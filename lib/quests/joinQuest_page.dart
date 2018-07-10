import 'package:flutter/material.dart';

class JoinQuestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        // color: Colors.white,
        body: Column(children: <Widget>[
          Container(
              height: 108.0,
              padding: const EdgeInsets.only(top: 50.0),
              child: Text(
                "Join a Quest",
                style: new TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.5,
                  fontSize: 26.0,
                ),
              )),
          Expanded(
            child: new Container()
          ),
          Padding(
            padding: const EdgeInsets.all(65.0),
          ),
        ]),
      ),
      Positioned(
        left: 10.0,
        top: 35.0,
        width: 60.0,
        height: 60.0,
        child: FlatButton(
                key: null,
                onPressed: () => Navigator.pop(context),
                color: Colors.white,
                child: Icon(Icons.close))
        // new IconButton(
        //     icon: new Icon(Icons.close),
        //     tooltip: 'Close.',
        //     onPressed: () => Navigator.pop(context)),
      ),
    ]);
  }
}
