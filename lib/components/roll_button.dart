import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:party_quest/globals.dart' as globals;
import 'imageRotater.dart';
import 'dart:async';
import 'dart:math';
import 'dart:core';

class RollButton extends StatefulWidget {
  RollButton(Map turn, Map characters){
    this._turn = turn;
    this._characters = characters;
  }
  Map _turn;
  Map _characters;
	@override
	_RollButtonState createState() => new _RollButtonState();
}

class _RollButtonState extends State<RollButton> {
  ImageRotater imageRotator = ImageRotater();
	bool _buttonPressed = false;
	bool _rolling = false;
  String _rollOutcomeTitle;
  String _rollOutcomeDescription;
  Timer _timer1;
  Timer _timer2;
  dynamic outcomePossibilities = {'win': [
      {'title': 'You did it... but just barely.', 'description': "You earn 0XP.", 'chat': ' barely succeeded. +0XP', 'XP': 0},
      {'title': 'Success.', 'description': 'You earn 1XP.', 'chat': ' succeeded. +1XP', 'XP': 1},
      {'title': 'Great success.', 'description': 'You earn 2XP.', 'chat': ' succeeded greatly! +2XP', 'XP': 2},
      {'title': 'CRITICAL SUCCESS!', 'description': 'You earn 3XP.', 'chat': ' got a CRITICAL SUCCESS! +3XP', 'XP': 3}
    ], 
    'fail': [
      {'title': 'You failed... but just barely.','description': "You lose 0HP.", 'chat': ' barely failed. -0HP', 'HP': 0},
      {'title': 'Failure.', 'description': "You lose 1HP.", 'chat': ' failed. -1HP', 'HP': -1},
      {'title': 'Horrible fail.', 'description': "You lose 2HP.", 'chat': ' failed horribly! -2HP', 'HP': -2},
      {'title': 'CRITICAL FAILURE!', 'description': "You lose 3HP.", 'chat': " got a CRITICAL FAIURE! -3HP", 'HP': -3},
    ]};

	@override
	void initState() {
		super.initState();
	}

  @override
  void dispose() {
    super.dispose();
    _timer1?.cancel();
    _timer2?.cancel();
  }

	@override
	Widget build(BuildContext context) {
    return Container(
			decoration: BoxDecoration(color: const Color(0xFF4C6296)),
			child: Container(
				padding: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
				child: Row(children: <Widget>[
					Expanded(
						child: Column(
							children: <Widget>[
								Padding(
									padding: EdgeInsets.all(5.0),
									child: RaisedButton(
										elevation: 4.0,
										highlightElevation: 50.0,
										padding: EdgeInsets.all(10.0),
										// onPressed: null,
										onPressed: _buttonPressed? null : _handleButtonTapped,
										color: const Color(0xFF00b0ff),
										shape: RoundedRectangleBorder(
											borderRadius: new BorderRadius.circular(40.0)),
										child: Row(
											children: <Widget>[
												_buttonPressed? imageRotator : Container(width: 50.0, child: Image.asset('assets/images/20D20.png')),
												Expanded(
													child: Padding(
														padding: EdgeInsets.only(left: 10.0),
														child: Column(
															crossAxisAlignment:
																CrossAxisAlignment.start,
															children: <Widget>[
																Text(_buttonPressed? (_rolling? 'Rolling...' : _rollOutcomeTitle) : 'Roll the dice!',
																	style: TextStyle(
																		fontSize: 22.0,
																		color: Colors.white,
																		fontWeight: FontWeight.w800,
																	)),
																Text(
																	_buttonPressed? (_rolling? 'Cross those fingers!' : _rollOutcomeDescription) : 'Find out if you succeed or fail.',
																	style: TextStyle(
																		color: Colors.white,
																		// fontWeight: FontWeight.w800,
																		letterSpacing: 0.5,
																		fontSize: 14.0,
																	),
																)
															])))
											],
										))),
							],
						),
					),
				])));
	}

	void _handleButtonTapped() {
    setState(() {
      _buttonPressed = true;
      _rolling = true;
    });
    _timer1 = Timer(const Duration(milliseconds: 2000), () {
      var rng = new Random();
      var rollResult = (rng.nextInt(20) + 1) + widget._turn['skillPower'];
      var difficulty = widget._turn['difficulty'];
      var winDegree = rollResult - difficulty;
      if(winDegree >= 0){
        // SUCCESS
        var winIndex = 0;
        if(winDegree >= 9) winIndex = 3;
        else if(winDegree >= 6) winIndex = 2;
        else if(winDegree >= 3) winIndex = 1;
        _handleRollResult('win', winIndex);
      } else {
        //FAILURE
        var failIndex = 0;
        if(winDegree.abs() >= 9) failIndex = 3;
        else if(winDegree.abs() >= 6) failIndex = 2;
        else if(winDegree.abs() >= 3) failIndex = 1;
        _handleRollResult('fail', failIndex);
      }
    });
	}

  _handleRollResult(String winFail, int index){
    setState(() {
      _rolling = false;
      _rollOutcomeTitle = outcomePossibilities[winFail][index]['title'];
      _rollOutcomeDescription = outcomePossibilities[winFail][index]['description'];
    });
    _timer2 = Timer(const Duration(milliseconds: 2000), () {
      var _gameId = globals.gameState['id'];
      // ADD Log
      Firestore.instance.collection('Games/$_gameId/Logs').document()
      .setData(<String, dynamic>{
        'text': widget._turn['characterName'] + ' ' + outcomePossibilities[winFail][index]['chat'],
        'type': 'narration',
        'color': winFail == 'fail' ? 'FF694F' : '9deb00',
        'dts': DateTime.now(),
        'userId': globals.userState['userId']
      });
      if(winFail == 'fail')
        widget._characters[globals.userState['userId']]['HP'] += outcomePossibilities[winFail][index]['HP'];
      else
        widget._characters[globals.userState['userId']]['XP'] += outcomePossibilities[winFail][index]['XP'];
      // UPDATE Game.turn
      var turns = [widget._turn, {
        'dts': DateTime.now(), 
        'turnPhase': 'respond'
        }
      ];
      var combinedTurns = turns.reduce((map1, map2) => map1..addAll(map2));
      final DocumentReference gameRef =
        Firestore.instance.collection('Games').document(_gameId);
      gameRef.updateData(<String, dynamic>{
        'turn': combinedTurns,
        'characters': widget._characters
      });
      
    });
  }
}
