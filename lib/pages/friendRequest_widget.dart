import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'dart:math';

class FriendRequest extends StatefulWidget {
  FriendRequest({@required this.friend});
  final DocumentSnapshot friend;

  @override
  _FriendRequestState createState() => new _FriendRequestState();
}

class _FriendRequestState extends State<FriendRequest> {
  bool _isButtonDisabled;

  @override
  void initState() {
    super.initState();
    _isButtonDisabled = false;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: CircleAvatar(radius: 25.0, backgroundImage: widget.friend['profilePic'].contains('http') ? CachedNetworkImageProvider(widget.friend['profilePic']) : AssetImage(widget.friend['profilePic'])),
        // CircleAvatar(
        //     backgroundImage: NetworkImage(widget.friend['profilePic'])),
        title:
            new Text(widget.friend['name'], style: TextStyle(color: Colors.white)),
        trailing: globals.gameState['creator'] ==
                globals.userState['userId']
            ? FlatButton(
                key: null,
                onPressed: _isButtonDisabled? null : () => _handleRequestApproved(widget.friend.documentID),
                color: const Color(0xFF00b0ff),
                child: new Text(
                  _isButtonDisabled? "Loading..." :"Approve",
                  style: new TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ))
            : null,
        // subtitle: new Text("Level 1 - Played by Bobby")
      );
  }

  void _handleRequestApproved(String userId) async {
    setState(() {
      _isButtonDisabled = true;
    });
    dynamic resp = await CloudFunctions.instance
        .call(functionName: 'acceptRequest', parameters: <String, dynamic>{
      'userId': userId,
      'gameId': globals.gameState['id'],
      'code': globals.gameState['code']
    });
    FirebaseDatabase.instance.reference().child('push').push().set(<String, dynamic>{
      'title': "You've been accepted into the party.",
      'message': "Welcome to " + globals.gameState['title'] + '!',
      'friendId': userId,
      'gameId': globals.gameState['id'],
      'genre': globals.gameState['genre'],
      'name': globals.gameState['name'],
      'gameTitle': globals.gameState['title'],
      'code': globals.gameState['code'],
      'players': globals.gameState['players'],
      'creator': globals.gameState['creator']
    });
  }

}