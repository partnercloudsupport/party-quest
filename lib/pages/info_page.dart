import 'package:flutter/material.dart';
import 'package:pegg_party/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => new _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (globals.gameState['id'].length == 0) {
      children = [Container()];
    } else {
      children..add(_buildPlayersList())..add(_buildUserRequestsList());
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          backgroundColor: const Color(0xFF00073F),
          elevation: -1.0,
          title: new Text("Game Info",
              style: new TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              )),
        ),
        body: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                  child: Container(
                      // width: 400.0,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  "assets/images/background-gradient.png"),
                              fit: BoxFit.fill)),
                      child: ListView(
                          padding: EdgeInsets.zero, children: children)))
            ]));
  }

  Widget _buildLabel(String labelName) {
    return ListTile(
        title: Text(labelName,
            style: new TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w100,
              // letterSpacing: 0.5,
              fontSize: 12.0,
            )));
  }

  Widget _buildUserRequestsList() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('Users')
            .where('requests.' + globals.gameState['code'], isEqualTo: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          List<Widget> labelListTiles = [];
          // final int messageCount = snapshot.data.documents.length;
          if (snapshot.data.documents.length > 0) {
            labelListTiles.add(_buildLabel('Requests to Join'));
          }
          snapshot.data.documents.forEach((user) {
            labelListTiles.add(ListTile(
              leading: CircleAvatar(
                  backgroundImage: NetworkImage(user['profilePic'])),
              title:
                  new Text(user['name'], style: TextStyle(color: Colors.white)),
              trailing: globals.gameState['creator'] ==
                      globals.userState['userId']
                  ? FlatButton(
                      key: null,
                      onPressed: () => _handleRequestApproved(user.documentID),
                      color: const Color(0xFF00b0ff),
                      child: new Text(
                        "Approve",
                        style: new TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ))
                  : null,
              // subtitle: new Text("Level 1 - Played by Bobby")
            ));
          });
          return Column(children: labelListTiles);
        });
  }

  void _handleRequestApproved(String userId) async {
    dynamic resp = await CloudFunctions.instance
        .call(functionName: 'acceptRequest', parameters: <String, dynamic>{
      'userId': userId,
      'gameId': globals.gameState['id'],
      'code': globals.gameState['code']
    });
    print(resp);
  }

  Widget _buildPlayersList() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('Users')
            .where('games.' + globals.gameState['id'], isEqualTo: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          List<Widget> labelListTiles = [];
          final int messageCount = snapshot.data.documents.length;
          if (messageCount > 0) {
            labelListTiles.add(_buildLabel('Players'));
          }
          snapshot.data.documents.forEach((user) {
            labelListTiles.add(ListTile(
              leading: CircleAvatar(
                  backgroundImage: NetworkImage(user['profilePic'])),
              title:
                  new Text(user['name'], style: TextStyle(color: Colors.white)),
              // subtitle: new Text("Level 1 - Played by Bobby")
            ));
          });
          return Column(children: labelListTiles);
        });
  }
}
