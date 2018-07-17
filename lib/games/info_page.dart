import 'package:flutter/material.dart';
import 'package:gratzi_game/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => new _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  // _InfoPageState() {
  //   globals.gameState.changes.listen((changes) {
  //     setState(() {
  //       _gameId = globals.gameState['id'];
  //     });
  //   });
  // }
  String _gameId;

  @override
  Widget build(BuildContext context) {
    final body = Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/background-gradient.png"),
                fit: BoxFit.fill)),
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('Users')
              .where('games.' + globals.gameState['id'], isEqualTo: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            final int messageCount = snapshot.data.documents.length;
            return ListView.builder(
              // reverse: true,
              itemCount: messageCount,
              itemBuilder: (_, int index) {
                final DocumentSnapshot document =
                    snapshot.data.documents[index];
                return ListTile(
                  leading: CircleAvatar(
                      backgroundImage: NetworkImage(document['profilePic'])),
                  title: new Text(document['name'], style: TextStyle(color: Colors.white)),
                  // subtitle: new Text("Level 1 - Played by Bobby")
                );
              },
            );
          },
        ));

    final emptyBody = Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/background-gradient.png"),
                fit: BoxFit.fill)));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        // automaticallyImplyLeading: false,
        // leading: new IconButton(icon: new Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () => Application.router.navigateTo(context, '/', transition: TransitionType.inFromLeft)),
        backgroundColor: const Color(0xFF00073F),
        elevation: -1.0,
        title: new Text("Players",
            style: new TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
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
      body: globals.gameState['id'].length == 0 ? emptyBody : body,
    );
  }
}
