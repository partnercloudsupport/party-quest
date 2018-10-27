import 'package:flutter/material.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'friendRequest_widget.dart';
import '../application.dart';
import 'package:fluro/fluro.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlayersInfoPage extends StatefulWidget {
  DocumentSnapshot _gameInfo;
  QuerySnapshot _gamePlayers;
  QuerySnapshot _gameReactions;
  PlayersInfoPage(DocumentSnapshot gameInfo, QuerySnapshot gamePlayers, QuerySnapshot gameReactions){
    this._gameInfo = gameInfo;
    this._gamePlayers = gamePlayers;
    this._gameReactions = gameReactions;
  }
  @override
  _PlayersInfoPageState createState() => new _PlayersInfoPageState();
}

class _PlayersInfoPageState extends State<PlayersInfoPage> with SingleTickerProviderStateMixin {

	@override
	void dispose() {
		super.dispose();
	}

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children
      ..addAll(_buildPlayersList())
      ..add(_buildUserRequestsList())
      ..add(globals.gameState['players']?.contains(globals.userState['userId']) == true ? _buildInviteButton() : Container());
    return ListView(padding: EdgeInsets.zero, children: children);
  }

  List<Widget> _buildPlayersList() {
      List<Widget> labelListTiles = [];
      final int playersCount = widget._gamePlayers.documents.length;
      if (playersCount > 0) {
        labelListTiles.add(_buildLabel('Players'));
      }
      widget._gamePlayers.documents.forEach((player) {
        Map playerReactions;
        for(final reactions in widget._gameReactions.documents){
          if(reactions.documentID == player.documentID){
            playerReactions = reactions.data;
            break;
          }
        }
        var character;
        if(widget._gameInfo.data['characters'] != null) character = widget._gameInfo.data['characters'][player.documentID];
        var canRomove = player.documentID != widget._gameInfo.data['creator'] && globals.userState['userId'] == widget._gameInfo.data['creator'];
        labelListTiles.add(Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: ListTile(
          isThreeLine: true,
          leading:  CircleAvatar(radius: 25.0, backgroundImage: player['profilePic'].contains('http') ? CachedNetworkImageProvider(player['profilePic']) : AssetImage("${player['profilePic']}")),
          // Container(child: Stack(children: <Widget>[
          //     CircleAvatar(radius: 25.0, backgroundImage: player['profilePic'].contains('http') ? CachedNetworkImageProvider(player['profilePic']) : AssetImage("${player['profilePic']}")),
          //     character == null ? Container(width: 10.0) : Positioned(left: 5.0, top: 5.0, child: CircleAvatar(backgroundImage: character['imageUrl'].contains('http') ? CachedNetworkImageProvider(character['imageUrl']) : AssetImage("${character['imageUrl']}"))),              
          //     ])),
          title: Text(player['name'], style: TextStyle(color: Colors.white, fontSize: 20.0)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[ character != null ? Text(character['characterName'], style: TextStyle(color: const Color(0x66FFFFFF), fontSize: 18.0, fontWeight: FontWeight.w400)) : Container(), playerReactions == null? Container(width: 10.0) : _buildReactionsRow(playerReactions)]),
          trailing: (canRomove ? GestureDetector(child: Text('remove', style: TextStyle(color: Colors.blue, fontSize: 14.0)), onTap: () => _handleRemovePlayer(player)) : Container(width: 10.0)) 
             
          // Padding(padding: EdgeInsets.only(top: 0.0), child: 
          //   character == null ? 
          //   (canRomove ? GestureDetector(child: Text('remove', style: TextStyle(color: Colors.blue, fontSize: 14.0)), onTap: () => _handleRemovePlayer(player)) : Container(width: 10.0)) 
          //   : Column(children: <Widget>[
          //     Text(character['HP'].toString() + 'HP', style: TextStyle(color: Colors.red, fontSize: 18.0)),
          //     Text(character['XP'].toString() + 'XP', style: TextStyle(color: Colors.green, fontSize: 18.0)),
          //     canRomove ? GestureDetector(child: Text('remove', style: TextStyle(color: Colors.blue, fontSize: 14.0)), onTap: () => _handleRemovePlayer(player)) : Container(width: 10.0)
          //   ]))
        )));
      });
      return labelListTiles;
  }

  void _handleRemovePlayer(DocumentSnapshot player) async {
    await CloudFunctions.instance.call(functionName: 'removePlayer', parameters: <String, dynamic>{
      'userId': player.documentID,
      'gameId': globals.gameState['id']
    });
  }

  Widget _buildReactionsRow(Map playerReactions){
		List<Widget> reactionsListTiles = [];
    for(var key in playerReactions.keys){
      reactionsListTiles.add(Container(child: Image.asset('assets/images/reaction-' + key + '.png'), height: 20.0));
			reactionsListTiles.add(Padding(padding: EdgeInsets.only(right: 10.0, left: 0.0, top: 9.0), child: Text("${playerReactions[key]}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 10.0))));
    }
    return Padding(padding: EdgeInsets.only(top: 5.0), child: Row(children: reactionsListTiles));
  }

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
  
  // Future<QuerySnapshot> _getGameRequests(){
  //   var requests = Firestore.instance.collection('Users').where('requests.' + globals.gameState['code'], isEqualTo: true);
  //   return requests.getDocuments();
  // }
}
