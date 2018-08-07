import 'package:flutter/material.dart';

class InviteFriendsPage extends StatelessWidget {
  InviteFriendsPage(String code) : this.code = code;
  final String code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
            automaticallyImplyLeading: false,
            leading: new IconButton(
                icon: new Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context)),
            backgroundColor: const Color(0xFF00073F),
            elevation: -1.0,
            title: new Text(
              "Invite Friends",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            )),
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/background-gradient.png"),
                    fit: BoxFit.fill)),
            child: Column(children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(50.0),
                  child: Row(children: <Widget>[
                    Expanded(
                        child: Text(
                      code,
                      style: TextStyle(fontSize: 40.0, color: Colors.white),
                    ))
                  ]))
            ])));
  }
}
