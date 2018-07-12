import 'package:flutter/material.dart';
import 'application.dart';
import 'package:fluro/fluro.dart';
import 'chat_view.dart';
import 'account_drawer.dart';
import 'package:gratzi_game/globals.dart' as globals;


class HomePage extends StatefulWidget {
  static String tag = 'home-page';

  @override
  createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  HomePageState() {
    globals.gameState.changes.listen((changes) {
      // print(changes);
      setState(() {
        _gameName = globals.gameState['gameName'];
      });
    });
  }
  String _gameName;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: AccountDrawer(), // left side
        // endDrawer: CharactersDrawer(), // right side
        appBar: AppBar(
          title: Text(_gameName == null ? 'Gratzi Game' : _gameName),
          elevation: -1.0,
          // leading: IconButton(
          //     icon: Icon(Icons.explore),
          //     onPressed: _scaffoldKey.currentState.openDrawer
          //     ),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.info_outline),
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
