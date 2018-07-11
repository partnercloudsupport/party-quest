import 'dart:async';
import 'package:flutter/material.dart';
import 'application.dart';
import 'package:fluro/fluro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_view.dart';
import 'account_drawer.dart';

class HomePage extends StatefulWidget {
  static String tag = 'home-page';

  @override
  createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: AccountDrawer(), // left side
        // endDrawer: CharactersDrawer(), // right side
        appBar: AppBar(
          title: Text('Pegg Party'),
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
