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
        _type = globals.gameState['type'];
      });
    });
  }
  String _type;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        // backgroundColor: Colors.white,
        drawer: AccountDrawer(), // left side
        appBar: AppBar(
          // toolbarOpacity: 0.0,
          leading: new IconButton(icon: new Icon(Icons.settings, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState.openDrawer()),
          backgroundColor: const Color(0xFF00073F),
          title: Text(_type == null ? 'Pegg Party' : _type, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          elevation: -1.0,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.info_outline, color: Colors.white,),
                tooltip: 'Info about this Quest.',
                onPressed: _openInfoView)
          ],
        ),
        body: ChatView());
  }

  void _openInfoView() {
    Application.router
        .navigateTo(context, 'info', transition: TransitionType.native);
  }
}
