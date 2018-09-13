import 'package:flutter/material.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'friendRequest_widget.dart';
import '../application.dart';
import 'package:fluro/fluro.dart';
import 'dart:async';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => new _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  List<Widget> _infoPageWidgets;
  String _gameId;
  _InfoPageState() {
    _gameId = globals.gameState['id'];
    Future.wait([_getGameInfo(), _getGamePlayers(), _getGameReactions(), _getGameRequests()])
    .then((List responses) {
      setState(() {
        List<Widget> children = [];
            children
            ..addAll(_buildPlayersList(responses[0], responses[1], responses[2]));
            // ..add(_buildUserRequestsList(responses[3]));
        _infoPageWidgets = children;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_infoPageWidgets == null) {
      return _buildScaffold([Container()]);
    } else {
      return _buildScaffold(_infoPageWidgets..add(_buildUserRequestsList()));
    }
  }

  Widget _buildScaffold(List<Widget> children){
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ), 
          backgroundColor: const Color(0xFF00073F),
          elevation: -1.0,
          title: new Text("Game Info",
              style: new TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              )),
        ),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      "assets/images/background-gradient.png"),
                  fit: BoxFit.fill)),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(padding: EdgeInsets.zero, children: children)),
                _buildInviteButton()])));
  }

  List<Widget> _buildPlayersList(DocumentSnapshot gameInfo, QuerySnapshot gamePlayers, QuerySnapshot gameReactions) {
      List<Widget> labelListTiles = [];
      final int playersCount = gamePlayers.documents.length;
      if (playersCount > 0) {
        labelListTiles.add(_buildLabel('Players'));
      }
      gamePlayers.documents.forEach((player) {
        Map playerReactions;
        for(final reactions in gameReactions.documents){
          if(reactions.documentID == player.documentID){
            playerReactions = reactions.data;
            break;
          }
        }
        var character;
        if(gameInfo.data['characters'] != null)
          character = gameInfo.data['characters'][player.documentID];
        labelListTiles.add(ListTile(
          leading: Container(child: Stack(children: <Widget>[
              CircleAvatar(radius: 25.0, backgroundImage: NetworkImage(player['profilePic'])),
              character == null ? Container(width: 10.0) : Positioned(left: 5.0, top: 5.0, child: CircleAvatar(backgroundImage: NetworkImage(character['imageUrl']))),              
              ])),
          title: character == null ? Text(player['name'], style: TextStyle(color: Colors.white, fontSize: 20.0)) : Text(player['name'] + '  :  ' + character['characterName'], style: TextStyle(color: Colors.white, fontSize: 20.0)),
          subtitle: playerReactions == null? Container(width: 10.0) : _buildReactionsRow(playerReactions),
          trailing: Padding(padding: EdgeInsets.only(top: 0.0), child: 
            character == null ? Container(width: 10.0) : Column(children: <Widget>[
              Text(character['HP'].toString() + 'HP', style: TextStyle(color: Colors.red, fontSize: 18.0)),
              Text(character['XP'].toString() + 'XP', style: TextStyle(color: Colors.blue, fontSize: 18.0)), 
            ]))
        ));
      });
      return labelListTiles;
  }

  Widget _buildReactionsRow(Map playerReactions){
		List<Widget> reactionsListTiles = [];
    for(var key in playerReactions.keys){
      reactionsListTiles.add(Container(child: Image.asset('assets/images/reaction-' + key + '.png'), height: 20.0));
			reactionsListTiles.add(Padding(padding: EdgeInsets.only(right: 10.0, left: 0.0, top: 9.0), child: Text("${playerReactions[key]}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 10.0))));
    }
    return Padding(padding: EdgeInsets.only(top: 5.0), child: Row(children: reactionsListTiles));
  }

  // List<Widget> _buildUserRequestsList(QuerySnapshot userRequests) {
  //   List<Widget> labelListTiles = [];
  //   userRequests.documents.forEach((user) {
  //     labelListTiles.add(FriendRequest(friend: user));
  //   });
  //   return labelListTiles;
  // }

  Widget _buildInviteButton(){
    return Align(
		alignment: Alignment.bottomCenter, child: Container(
			margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
			child: Padding(
				padding: const EdgeInsets.only(bottom: 50.0),
				child: RaisedButton(
					padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
						color: const Color(0xFF00b0ff),
						shape: RoundedRectangleBorder(
							borderRadius:
								BorderRadius.circular(
									10.0)),
						onPressed: () => Application.router.navigateTo(
			context, 'inviteFriends?code=' + globals.gameState['code'],
			transition: TransitionType.fadeIn),
						child: Text(
							"Invite Friends",
							style: TextStyle(
								fontSize: 20.0,
								color: Colors.white,
								fontWeight: FontWeight.w800,
							),)))));
  }

  Widget _buildLabel(String labelName) {
    return ListTile(
        title: Text(labelName,
            style: new TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w100,
              // letterSpacing: 0.5,
              fontSize: 16.0,
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
            labelListTiles.add(FriendRequest(friend: user));
          });
          return Column(children: labelListTiles);
        });
  }

  // Widget _buildPlayersList() {
  //   return StreamBuilder<QuerySnapshot>(
  //       stream: Firestore.instance
  //           .collection('Users')
  //           .where('games.' + _gameId, isEqualTo: true)
  //           .snapshots(),
  //       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //         if (!snapshot.hasData) return const Text('Loading...');
  //         List<Widget> labelListTiles = [];
  //         final int messageCount = snapshot.data.documents.length;
  //         if (messageCount > 0) {
  //           labelListTiles.add(_buildLabel('Players'));
  //         }
  //         snapshot.data.documents.forEach((user) {
  //           labelListTiles.add(ListTile(
  //             leading: CircleAvatar(
  //                 backgroundImage: NetworkImage(user['profilePic'])),
  //             title:
  //                 new Text(user['name'], style: TextStyle(color: Colors.white)),
  //             // subtitle: new Text("Level 1 - Played by Bobby")
  //           ));
  //         });
  //         return Column(children: labelListTiles);
  //       });
  // }

  Future<QuerySnapshot> _getGameReactions(){
    var reactions = Firestore.instance.collection('Games/$_gameId/Reactions');
    return reactions.getDocuments();
  }

  Future<DocumentSnapshot> _getGameInfo(){
    var gameInfo = Firestore.instance.collection('Games').document(_gameId);
    return gameInfo.get();
  }

  Future<QuerySnapshot> _getGamePlayers(){
    var players = Firestore.instance.collection('Users').where('games.' + _gameId, isEqualTo: true);
    return players.getDocuments();
  }

  Future<QuerySnapshot> _getGameRequests(){
    var requests = Firestore.instance.collection('Users').where('requests.' + globals.gameState['code'], isEqualTo: true);
    return requests.getDocuments();
  }
}
