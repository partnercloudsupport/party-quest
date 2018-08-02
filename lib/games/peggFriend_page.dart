import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gratzi_game/globals.dart' as globals;

class PeggFriendPage extends StatefulWidget {
  PeggFriendPage(String answerId) : this.answerId = answerId;
  final String answerId;

  @override
  createState() => PeggFriendPageState();
}

class PeggFriendPageState extends State<PeggFriendPage> {
  Map _answerData;

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
            title: new Text(
              "Pegg a Friend",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            )),
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/background-gradient.png"),
                  fit: BoxFit.fill)),
          child: _buildPickAnswer(context),
        ));
  }

  Widget _buildPickAnswer(BuildContext context) {
    return FutureBuilder(
        future: Firestore.instance
            .collection('Answers')
            .document(widget.answerId)
            .get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            _answerData = snapshot.data.data;
            return Container(
                child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 150.0,
                          height: 150.0,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100.0)),
                            //  color: Colors.black,
                            image: DecorationImage(
                              image:
                                  NetworkImage(globals.userState['profilePic']),
                              // fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(_answerData['question']['text'],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w800))),
                        _buildPredefinedAnswers(
                            _answerData['question']['answers'])
                      ],
                    )));
          } else {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[CircularProgressIndicator()]);
          }
        });
  }

  Widget _buildPredefinedAnswers(Map answers) {
    List<Widget> answerListTiles = [];
    answers.forEach((key, value) {
      answerListTiles.add(Row(children: <Widget>[
        Expanded(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: RaisedButton(
                    padding: EdgeInsets.all(10.0),
                    onPressed: () => _selectGuess(context, value),
                    color: const Color(0x55FFFFFF),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(5.0)),
                    child: Text(value['text'],
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w200)))))
      ]));
      // child: Text(value['text'], style: TextStyle(color: Colors.white))));
    });
    return Column(children: answerListTiles);
  }

  void _selectGuess(BuildContext context, dynamic selectedGuess) {
    if (selectedGuess['text'].length > 0) {
      final DocumentReference newAnswer =
          Firestore.instance.collection('Guesses').document();
      newAnswer.setData(<String, dynamic>{
        'gameId': globals.gameState['id'],
        'dts': DateTime.now(),
        'answerId': widget.answerId,
        'guess': selectedGuess,
        'userId': globals.userState['userId']
      }).then((onValue) {
        Navigator.pop(context);
        var _gameId = globals.gameState['id'];
        // ADD Question to Chat Logs
        final DocumentReference newChat =
            Firestore.instance.collection('Games/$_gameId/Logs').document();
        newChat.setData(<String, dynamic>{
          'text': selectedGuess['text'],
          'type': 'guess',
          'dts': DateTime.now(),
          'profileUrl': globals.userState['profilePic'],
          'userName': globals.userState['name'],
          'userId': globals.userState['userId']
        });
        // UPDATE Game.turn
        final DocumentReference game =
            Firestore.instance.collection('Games').document(_gameId);
        game.get().then((gameResult) {
          var guessers = gameResult.data['guessers'] == null
              ? {}
              : gameResult.data['guessers'];
          guessers[globals.userState['userId']] = true;
          // Merge new turn data into old turn Map
          var newTurn = {
              'type': 'peggFriend',
              'dts': DateTime.now(),
              'guessers': guessers
            };
          var turns = [gameResult.data['turn'], newTurn];
          var combinedTurns = turns.reduce( (map1, map2) => map1..addAll(map2) );
          game.updateData(<String, dynamic>{
            // TODO: needs to be a transaction to prevent race condition overwrites
            'turn': combinedTurns
          });
        });
      });
    }
  }
}
