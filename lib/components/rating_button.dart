import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:firebase_database/firebase_database.dart';

class RatingButton extends StatefulWidget {
  final Map _turn;
  final String _activeAction;
  final Function _isActivatedCallback;
  RatingButton(this._turn, this._activeAction, this._isActivatedCallback);
	@override
	_RatingButtonState createState() => new _RatingButtonState();
}

class _RatingButtonState extends State<RatingButton> {

	@override
	void initState() {
		super.initState();
	}

  @override
  void dispose() {
    super.dispose();
  }

	@override
	Widget build(BuildContext context) {
    return widget._activeAction == 'chat' ?
      Container(height: 70.0, child: RaisedButton(
      elevation: 4.0,
      highlightElevation: 50.0,
      padding: EdgeInsets.all(0.0),
      // onPressed: null,
      onPressed: widget._isActivatedCallback,
      color: Theme.of(context).buttonColor,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(40.0)),
      child: Container(
        child: CircleAvatar(
          radius: 20.0,
            backgroundColor: Colors.white.withOpacity(.3),
            backgroundImage: AssetImage('assets/images/20D20.png')),
      )))
    :
    Column(children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0), child:
        // Text('How difficult is that action?', style: TextStyle(fontSize: 22.0,color: Colors.white, fontWeight: FontWeight.w800)),
        Row(mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildRatingButton(1, 'easy'),
            _buildRatingButton(2, 'tricky'),
            _buildRatingButton(3, 'hard'),
            _buildRatingButton(4, 'brutal'),
            _buildRatingButton(5, 'insane')]))
        ]);
    }

  Widget _buildRatingButton(int value, String description){
    return Expanded(
      child: Container(
      child: Padding(padding: EdgeInsets.only(left: 5.0, right: 5.0), 
        child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          color: Theme.of(context).buttonColor,
          shape: new RoundedRectangleBorder(
            borderRadius:
              new BorderRadius.circular(
                50.0)),
          onPressed: () => _handleRatingSubmitted(value, description),
          child: Column( children: <Widget>[Text(
            value.toString(),
            style: new TextStyle(
              fontSize: 22.0,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            )),
            Text(description, style: TextStyle(color: Colors.white))
            ]))
      )));
  }

  void _handleRatingSubmitted(int value, String description){
      String _gameId = globals.currentGame.documentID;
    	Firestore.instance.collection('Games/$_gameId/Logs').document()
      .setData(<String, dynamic>{
        'text': 'That sounds ' + description + '.',
        'title': 'Difficulty Check',
        'type': 'difficulty',
        'dts': DateTime.now(),
        'profileUrl': globals.currentUser.data['profilePic'],
        'userId': globals.currentUser.documentID,
				'userName': globals.currentUser.data['name']
      });
      var turns = [widget._turn, {
        'turnPhase': 'roll', 
        'dts': DateTime.now(), 
        'difficulty': value * 4
      }];
      var combinedTurns = turns.reduce((map1, map2) => map1..addAll(map2));
      final DocumentReference turn =
        Firestore.instance.collection('Games').document(_gameId);
      turn.updateData(<String, dynamic>{
        'turn': combinedTurns
      });
      FirebaseDatabase.instance.reference().child('push').push().set(<String, dynamic>{
        'title': "Time for you to roll...",
        'message': globals.currentUser.data['name'] + " said your action was " + description + "!",
        'friendId': widget._turn['playerId'],
        'gameId': globals.currentGame.documentID,
        // 'genre': globals.currentGame.data['genre'],
        // 'name': globals.currentGame.data['name'],
        // 'gameTitle': globals.currentGame.data['title'],
        // 'code': globals.currentGame.data['code'],
        // 'players': globals.currentGame.data['players'],
        // 'creator': globals.currentGame.data['creator']
      });
  }
}
