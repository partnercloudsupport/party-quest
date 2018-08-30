import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:pegg_party/globals.dart' as globals;
import 'package:cached_network_image/cached_network_image.dart';
// import 'dart:math';

class SubmitAnswerPage extends StatelessWidget {
	final TextEditingController _textController = TextEditingController();

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: new AppBar(
				automaticallyImplyLeading: false,
				leading: new IconButton(
					icon: new Icon(Icons.close, color: Colors.white),
					onPressed: () => Navigator.pop(context)),
				backgroundColor: const Color(0xFF00073F),
				elevation: -1.0,
				title: Text(
					"Pegg " + globals.peggeeName,
					style:
						TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
				)),
			body: Container(
				decoration: BoxDecoration(
					image: DecorationImage(
						image: AssetImage("assets/images/background-gradient.png"),
						fit: BoxFit.fill)),
				child: _buildPickAnswer(context)));
	}

	Widget _buildPickAnswer(BuildContext context) {
		return Container(
			child: Padding(
				padding: EdgeInsets.all(20.0),
				child: ListView(
					children: <Widget>[
						Column(children: <Widget>[ Container(
				width: 150.0,
				height: 150.0,
					// margin: const EdgeInsets.only(top: 0.0, bottom: 10.0),
							decoration: BoxDecoration(
					shape: BoxShape.circle,
					image: DecorationImage(
						fit: BoxFit.cover,
						image: CachedNetworkImageProvider(globals.peggeeProfilePic),
									// fit: BoxFit.cover,
								),
							),
						)]), 
							Padding(padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0), child: Text(
								globals.question,
								style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22.0))),
              Row(children: <Widget>[
						Flexible(
							child: Container(child: TextField(
								style: TextStyle(color: Colors.white, fontSize: 18.0),
								maxLines: null,
								keyboardType: TextInputType.multiline,
								controller: _textController,
								decoration: InputDecoration(
									// contentPadding: const EdgeInsets.all(10.0),
									hintText: "Enter your answer",
									hintStyle: TextStyle(color: Colors.white),
                  border: null
                  ),
							), padding: EdgeInsets.all(10.0), decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(8.0))),
						)]),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                child: RaisedButton(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  key: null,
                  onPressed: () => _handleSubmitted(context),
                  color: const Color(0xFF00b0ff),
                  shape: new RoundedRectangleBorder(
                    borderRadius:
                      new BorderRadius.circular(
                        10.0)),
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  )))
          ]
		  )));
		}

	void _handleSubmitted(BuildContext context) {
		var _gameId = globals.gameState['id'];
		// ADD Question to Chat Logs
		final DocumentReference newChat =
			Firestore.instance.collection('Games/$_gameId/Logs').document();
		newChat.setData(<String, dynamic>{
			'text': _textController.text,
			'type': 'answer',
			'dts': DateTime.now(),
			'profileUrl': globals.userState['profilePic'],
			'userName': globals.userState['name'],
			'userId': globals.userState['userId']
		});
    // UPDATE Logs.turn
    // TODO: needs to be a transaction to prevent race condition overwrites
    final DocumentReference gameRef =
      Firestore.instance.collection('Games').document(_gameId);
    gameRef.get().then((gameResult) {
      var turn = gameResult['turn'];
      var guessers = turn['guessers'] == null ? {} : turn['guessers'];
      guessers[globals.userState['userId']] = true;
      var newTurn = {'dts': DateTime.now(), 'guessers': guessers};
      var turns = [turn, newTurn];
      var combinedTurns = turns.reduce((map1, map2) => map1..addAll(map2));
      gameRef.updateData(<String, dynamic>{
        'turn': combinedTurns
      }).then((result){
        Navigator.pop(context);
      });
    });
  }

}
