import 'package:flutter/material.dart';
import 'application.dart';
import 'package:fluro/fluro.dart';
import 'chat_view.dart';
import 'account_drawer.dart';
import 'package:gratzi_game/globals.dart' as globals;

class HomePage extends StatefulWidget {
  @override
  createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  HomePageState() {
    globals.gameState.changes.listen((changes) {
      setState(() {
        _title = globals.gameState['title'];
      });
    });
  }
  String _title;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        // backgroundColor: Colors.white,
        drawer: AccountDrawer(), // left side
        appBar: AppBar(
          // toolbarOpacity: 0.0,
          leading: new IconButton(
              icon: new Icon(Icons.account_circle, color: Colors.white),
              onPressed: () => _scaffoldKey.currentState.openDrawer()),
          backgroundColor: const Color(0xFF00073F),
          title: Text(_title == null ? 'Pegg Party' : _title,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          elevation: -1.0,
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: Colors.white,
                ),
                tooltip: 'Info about this Quest.',
                onPressed: _openInfoView)
          ],
        ),
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              // image: AssetImage("assets/images/$_gameType.jpg"),
              image: AssetImage("assets/images/background-cosmos.png"),
              fit: BoxFit.cover,
              // colorFilter: ColorFilter.mode(
              //     Colors.black.withOpacity(0.9), BlendMode.dstATop)
            )),
            child: globals.gameState['id'] == ''
                ? _buildStartScreen()
                : ChatView()));
  }

  Widget _buildStartScreen() {
    return Center(
      // width: 300.0,
      child: Column(
      children: <Widget>[
        Container(width: 200.0, padding: EdgeInsets.only(top: 100.0), child: FlatButton(
            padding: EdgeInsets.all(20.0),
            onPressed: () => Application.router.navigateTo(
                context, 'createGame',
                transition: TransitionType.fadeIn),
            color: const Color(0xFF00b0ff),
            child: new Text(
              "Create a Game",
              style: new TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ))),
        Container(width: 200.0, padding: EdgeInsets.only(top: 40.0), child: FlatButton(
            padding: EdgeInsets.all(20.0),
            onPressed: () => Application.router.navigateTo(context, 'joinGame',
                transition: TransitionType.fadeIn),
            color: const Color(0xFF00b0ff),
            child: new Text(
              "Join a Game",
              style: new TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            )))
      ],
    ));
  }

  void _openInfoView() {
    Application.router
        .navigateTo(context, 'info', transition: TransitionType.native);
  }
}
