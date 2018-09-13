import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:party_quest/globals.dart' as globals;

class RatingButton extends StatefulWidget {
  final Map _turn;
  RatingButton(Map turn): this._turn = turn;
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
    return Container(
			decoration: BoxDecoration(color: const Color(0xFF4C6296)),
			child: Column(children: <Widget>[
        Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: Text('How difficult is that action?', style: TextStyle(fontSize: 22.0,color: Colors.white, fontWeight: FontWeight.w800))),
        Row(mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildRatingButton(1, 'easy'),
            _buildRatingButton(2, 'tricky'),
            _buildRatingButton(3, 'hard'),
            _buildRatingButton(4, 'brutal'),
            _buildRatingButton(5, 'insane')])
        ])
            );
    }

  Widget _buildRatingButton(int value, String description){
    return Expanded(
      child: Container(
      child: Padding(padding: EdgeInsets.only(left: 5.0, right: 5.0), 
        child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          color: const Color(0xFF00b0ff),
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
      String _gameId = globals.gameState['id'];
    	Firestore.instance.collection('Games/$_gameId/Logs').document()
      .setData(<String, dynamic>{
        'text': 'That sounds ' + description + '.',
        'title': 'Difficulty Check',
        'type': 'difficulty',
        'dts': DateTime.now(),
        'profileUrl': globals.userState['profilePic'],
        'userId': globals.userState['userId']
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
  }
}
