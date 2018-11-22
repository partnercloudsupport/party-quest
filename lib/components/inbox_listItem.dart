import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'dart:math';

class InboxItem extends StatefulWidget {
  InboxItem(this.inboxItem);
  final DocumentSnapshot inboxItem;

  @override
  _InboxItemState createState() => new _InboxItemState();
}

class _InboxItemState extends State<InboxItem> {
  String _buttonPressed;

  @override
  void initState() {
    super.initState();
    _buttonPressed = null;
  }

  @override
  void dispose(){
    super.dispose();
    _buttonPressed = null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.symmetric(vertical: 10.0), 
      child: ListTile(
        dense: false,
        leading: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(.3),
          radius: 25.0, 
          backgroundImage: widget.inboxItem['profilePic'].contains('http') ? CachedNetworkImageProvider(widget.inboxItem['profilePic']) : AssetImage(widget.inboxItem['profilePic'])),
        title:
            Text(widget.inboxItem['body'], style: TextStyle(color: Colors.white, fontSize: 20.0)),      
        trailing: _buttonPressed == null ? Container(width: 90.0, child: Row(children: <Widget>[
            Expanded(child: IconButton(color: Theme.of(context).buttonColor, icon: Icon(Icons.thumb_up), onPressed: _handleRequestApproved)),
            Container(width: 5.0),
            Expanded(child: IconButton(color: Theme.of(context).errorColor, icon: Icon(Icons.thumb_down), onPressed: _handleRequestRejected)),
          ])) 
          : Text(_buttonPressed, style: TextStyle(color: Colors.white))
      ));
  }

  // Widget _buildRoundedIconButton(String type) {
  //   ClipOval(
  //     child: Container(
  //       color: Theme.of(context).selectedRowColor,
  //       child: IconButton(color: Colors.white, icon: Icon(Icons.thumb_up), onPressed: () => _handleRequestApproved(inboxId)),
  //     ));
  // }

  void _handleRequestRejected() {
    setState(() {
      _buttonPressed = 'Rejecting...';
    });
    CloudFunctions.instance
    .call(functionName: 'rejectRequest', parameters: <String, dynamic>{
      'userId': globals.currentUser.documentID,
      'friendId': widget.inboxItem.data['userId'],
      'gameId': widget.inboxItem.data['gameId'],
      'inboxId': widget.inboxItem.documentID
    });
  }

  void _handleRequestApproved() {
    setState(() {
      _buttonPressed = 'Accepting...';
    });
    CloudFunctions.instance
    .call(functionName: 'acceptRequest', parameters: <String, dynamic>{
      'userId': globals.currentUser.documentID,
      'friendId': widget.inboxItem.data['userId'],
      'gameId': widget.inboxItem.data['gameId'],
      'gameTitle': widget.inboxItem.data['gameTitle'],      
      'inboxId': widget.inboxItem.documentID
    });
  }

}