import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:party_quest/globals.dart' as globals;
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
        leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.friend['profilePic'])),
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
    print(resp);
  }

}