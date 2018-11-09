import 'package:flutter/material.dart';
import '../application.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:party_quest/globals.dart' as globals;
import '../components/rating_button.dart';
import '../components/roll_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:core';
import 'package:fluro/fluro.dart';


class ActionsView extends StatefulWidget {
  final String gameId;
  final Function textSubmittedCallback;
  ActionsView(this.gameId, this.textSubmittedCallback);

	@override
	_ActionsViewState createState() => new _ActionsViewState();
}

class _ActionsViewState extends State<ActionsView> with SingleTickerProviderStateMixin {
  // Animation<double> animation;
  // AnimationController controller;

  int _actionButtonFlex;
  int _inputFlex;
  Map _turn, _characters;
  String _activeAction;
	final TextEditingController _textController = TextEditingController();

	@override
	void initState() {
		super.initState();
    // controller = AnimationController(
    // duration: const Duration(milliseconds: 2000), vsync: this);
    // animation = Tween(begin: 50.0, end: MediaQuery.of(context).size.width - 20.0).animate(controller)
    //   ..addListener(() {
    //     setState(() {
    //       // the state that has changed here is the animation object’s value
    //     });
    //   });

    // controller.forward();
    _actionButtonFlex = 5;
    _inputFlex = 1;
    _activeAction = 'act';
	}

  @override
  void dispose() {
    super.dispose();
  }

	@override
	Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 0.0, left: 10.0, right: 10.0),
      // decoration: BoxDecoration(color: Theme.of(context).accentColor),
        // image: DecorationImage(image: AssetImage('assets/images/bottom-clouds.png'), fit: BoxFit.fitHeight)),
      child: Row(children: <Widget>[ 
        Expanded(flex: _actionButtonFlex, child: _buildActionButton()), 
        Expanded(flex: _inputFlex, child: _buildTextComposer())
      ]));
        // Container(width: animation.value, child: _buildActionButton()), 
        // Container(width: MediaQuery.of(context).size.width - 20, child: FractionallySizedBox(widthFactor: 50.0, child: _buildActionButton())), 
        // FractionallySizedBox(widthFactor: animation.value, child: _buildTextComposer())
        
	}

	Widget _buildActionButton() {
		if (widget.gameId != null) {
			return StreamBuilder<DocumentSnapshot>(
				stream: Firestore.instance
					.collection('Games')
					.document(widget.gameId)
					.snapshots(),
				builder:
					(BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
					if (!snapshot.hasData) return new Text("Loading");
					var document = snapshot.data;
					if (document['players'][globals.userState['userId']] == true) {
						_characters = document['characters'];
            _turn = document['turn'];
            //PICK A SCENARIO
            // this only happens if the user failed to pick it on game creation (got distracted and closed the app, eg)
						// if (_turn == null || _turn['scenario'] == null) {  
						// 	Function onPressed = () => Application.router.navigateTo(
						// 		context, 'pickScenario',
						// 		transition: TransitionType.fadeIn);
						// 	return _buildButton(document['imageUrl'], onPressed,
						// 	'Pick a Scenario', 'Set the stage for your party quest.');
						// }

            //PICK A CHARACTER
						if (_characters == null || _characters[globals.userState['userId']] == null) {
							Function pickCharacter = () => Application.router.navigateTo(
								context, 'pickCharacter',
								transition: TransitionType.fadeIn);
							return _buildButton(document['imageUrl'], pickCharacter,
								'Pick a character...', 'to play as in this story!');
						}
            
            // GAME OVER
            if(_turn['turnPhase'] == 'gameOver'){
              return _buildButton(document['imageUrl'], null,
                'Game over, man...', 'You all died. Mourn the dead and move on.');
            }

            //INVITE SOMEONE
            // if (document['players'].length == 1) {
						// 	Function pickCharacter = () => Application.router.navigateTo(
						// 		context, 'inviteFriends?code=' + document['code'],
						// 		transition: TransitionType.fadeIn);
						// 	return _buildButton(document['imageUrl'], pickCharacter,
						// 		'Invite a friend!', 'Get your party together.');
						// }

            // YOUR TURN
            if(_turn['playerId'] == globals.userState['userId']){
              // ACT PHASE
              if (_turn['turnPhase'] == 'act') {
                Function onPressed = () => Application.router.navigateTo(
                  context, 'pickAction',
                  transition: TransitionType.fadeIn);
                  return _buildButton(globals.userState['profilePic'], onPressed,
                    'What do you do?', "It's your turn, " + globals.userState['name'] + '.');
              }
              // DIFFICULTY
              if(_turn['turnPhase'] == 'difficulty') {
                if(document['players'].keys.length == 1){
                  //you can set your own difficulty if you're the only person in here.
                  return RatingButton(_turn, _activeAction, _focusAction);
                } else {
                  return _buildButton(_turn['playerImageUrl'], null,
                    'Waiting on...', 'Another player to set the difficulty.');
                }
              }
              // ROLL PHASE
              if(_turn['turnPhase'] == 'roll'){
                return RollButton(_turn, _characters, _activeAction, _focusAction);
              }
              // RESPOND PHASE
              if(_turn['turnPhase'] == 'respond') {
                Function onPressed = () => Application.router.navigateTo(
                  context, 'pickResponse',
                  transition: TransitionType.fadeIn);
                return _buildButton(document['imageUrl'], onPressed,
                  'What happens next?', 'Tell the next part of the story.');
              }
            }
            // NOT YOUR TURN
            // SET DIFFICULTY
            if(_turn['turnPhase'] == 'difficulty') {
              return RatingButton(_turn, _activeAction, _focusAction);
            }

            DateTime now = DateTime.now();
            DateTime threeHoursAgo = DateTime(now.year, now.month, now.day, now.hour - 3);
            if(_turn['dts'].isBefore(threeHoursAgo)) {
              if(_turn['playerImageUrl'] != null && _turn['playerName'] != null) {
                return _buildButton(_turn['playerImageUrl'], () => _handleSkipTurn(snapshot.data.reference, _turn['playerId']),
                  'Skip turn...', _turn['playerName'] + ' hasnt played in 3 hours.');
              } else {
                return _buildButton(document['imageUrl'], () => _handleSkipTurn(snapshot.data.reference, _turn['playerId']),
                  'Skip turn...', 'Player inactive for over three hours.');
              }
            }

            // WAITING ON FRIEND
            if(_turn['turnPhase'] == 'respond'){
              return _buildButton(_turn['playerImageUrl'], null,
                'Waiting on...', 'Your friend ' + _turn['playerName'] + ' to finish their turn.');
            } else {
              if(_turn['playerImageUrl'] != null && _turn['playerName'] != null) {
                return _buildButton(_turn['playerImageUrl'], null,
                  'Waiting on...', _turn['playerName'] + ' to take the next action.');
              } else {
                return _buildButton(document['imageUrl'], null,
                  'Waiting on...', 'The next player to start their turn.');
              }
            }
					} else {
            if(globals.userState['requests'] == null || globals.userState['requests']?.contains(globals.gameState['code']) != true){
              //request not sent
              return _buildButton(
                document['imageUrl'],
                _handleJoinButtonPressed,
                'Request to Join...',
                'so you can adventure with this party!');
            } else {
              return _buildButton(document['imageUrl'], null,
              'Request Sent...', 'Waiting on approval from the game creator.');
            }
					}
				});
		} else {
			return Expanded(child: Container());
		}
	}

  Widget _buildIconButton(IconData iconData){
    return RaisedButton(
      elevation: 4.0,
      highlightElevation: 50.0,
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      // onPressed: null,
      onPressed: _focusInput,
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
      child: Container(
        margin: EdgeInsets.only(left: 4.0),
        child: Icon(
            iconData,
            color: Colors.white,
            size: 30.0,
          ))
    );
  }

	Widget _buildTextComposer() {
		return 
      Container(
        padding: EdgeInsets.only(left: 10.0),
        height: 70.0, 
        child: 
        _activeAction == 'chat' ?
        RaisedButton(
          elevation: 4.0,
          highlightElevation: 50.0,
          // padding: EdgeInsets.all(0.0),
          // onPressed: null,
          onPressed: () => print('button press bs'),
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
          child: 
            globals.gameState['players']?.contains(globals.userState['userId']) == false ?
            Text("You must join this game to chat.", style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w400)) :
          Row(children: <Widget>[
						Expanded(
							child: Container(
                height: 60.0,
                child: TextField(
								style: TextStyle(color: Colors.white, fontSize: 20.0, fontFamily: 'LondrinaSolid'),
								maxLines: null,
                cursorColor: Colors.white,
                cursorWidth: 3.0,
                autofocus: true,
								keyboardType: TextInputType.multiline,
								controller: _textController,
								onSubmitted: _handleTextSubmitted,
								decoration: InputDecoration(
									contentPadding: const EdgeInsets.only(top: 0.0, left: 10.0, right: 0.0),
									hintText: "Send a message",
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
									hintStyle: TextStyle(color: Colors.white)),
							))),
              Container(
                width: 30.0,
                margin: EdgeInsets.only(left: 4.0),
                padding: EdgeInsets.all(0.0),
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 30.0,
                  ),
                  onPressed: () =>
                    _handleTextSubmitted(_textController.text))),
					]))
          : _buildIconButton(Icons.chat));
	}

	Widget _buildButton(String buttonImage, Function onPressed, String title, String subtitle) {
		return _activeAction == 'act' ?
		Container(height: 70.0, child: Row(
      children: <Widget>[
        Expanded(child: 
          RaisedButton(
            elevation: 4.0,
            // highlightElevation: 50.0,
            padding: EdgeInsets.only(left: 10.0),
            // onPressed: null,
            onPressed: onPressed,
            color: Theme.of(context).buttonColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
            child: Row(children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(.3),
                backgroundImage: buttonImage.contains('http') ? CachedNetworkImageProvider(buttonImage) : AssetImage(buttonImage)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: TextStyle(fontSize: 22.0, color: Colors.white, fontWeight: FontWeight.w800)),
                      Text(subtitle, style: TextStyle(color: Colors.white, letterSpacing: 0.5, fontSize: 14.0))
                    ])))
            ],
          )),
        ),
    ])) :
    // Small Image button
    Container(height: 70.0, child: RaisedButton(
      elevation: 4.0,
      highlightElevation: 50.0,
      padding: EdgeInsets.all(0.0),
      // onPressed: null,
      onPressed: _focusAction,
      color: Theme.of(context).buttonColor,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(40.0)),
      child: Container(
        // width: 60.0,
        // height: 60.0,
        // margin: EdgeInsets.only(left: 4.0),
        child: CircleAvatar(
          radius: 20.0,
            backgroundColor: Colors.white.withOpacity(.3),
            backgroundImage: buttonImage.contains('http') ? CachedNetworkImageProvider(buttonImage) : AssetImage(buttonImage)),
      )));
	}

	void _handleTextSubmitted(String text) {
		var gameId = globals.gameState['id'];
		_textController.clear();
		if (text.length > 0) {
			final DocumentReference document =
				Firestore.instance.collection('Games/$gameId/Logs').document();
			document.setData(<String, dynamic>{
				'text': text,
				'dts': DateTime.now(),
				'profileUrl': globals.userState['profilePic'],
				'userName': globals.userState['name'],
				'userId': globals.userState['userId']
			}).then((onValue) => widget.textSubmittedCallback());
		}
	}


  void _focusInput(){
    // controller.forward();
    setState(() {
      _actionButtonFlex = 1;
      _inputFlex = 5;      
      _activeAction = 'chat';
    });
  }


  void _focusAction(){
    setState(() {
      _actionButtonFlex = 5;
      _inputFlex = 1;   
      _activeAction = 'act';
    });
  }


  void _handleSkipTurn(DocumentReference docRef, String playerId){
    docRef.get().then((gameResult) {
      String nextPlayerId, nextPlayerName, nextPlayerImageUrl;
      List<dynamic> sortedPlayerIds = gameResult['players'].keys.toList()..sort();
      int playerIndex = sortedPlayerIds.indexOf(playerId);
      if(playerIndex < sortedPlayerIds.length-1){
        nextPlayerId = sortedPlayerIds[playerIndex+1];
      } else {
        nextPlayerId = sortedPlayerIds[0];
      }
      nextPlayerName = gameResult['characters'][nextPlayerId] != null ? gameResult['characters'][nextPlayerId]['characterName'] : null;
      nextPlayerImageUrl = gameResult['characters'][nextPlayerId] != null ? gameResult['characters'][nextPlayerId]['imageUrl'] : null;
      var turns = [gameResult['turn'], {
        'playerId': nextPlayerId,
        'dts': DateTime.now(), 
        'turnPhase': 'act',
        'playerImageUrl': nextPlayerImageUrl,
        'playerName': nextPlayerName}
      ];
      var combinedTurns = turns.reduce((map1, map2) => map1..addAll(map2));
      docRef.updateData(<String, dynamic>{
        'turn': combinedTurns
      });

      FirebaseDatabase.instance.reference().child('push').push().set(<String, dynamic>{
        'title': "It's your turn!",
        'message': "Your friends are waiting on you to continue the story!",
        'friendId': nextPlayerId,
        'gameId': globals.gameState['id'],
        'genre': globals.gameState['genre'],
        'name': globals.gameState['name'],
        'gameTitle': globals.gameState['title'],
        'code': globals.gameState['code'],
        'players': globals.gameState['players'],
        'creator': globals.gameState['creator']
      });

    });
  }


	void _handleJoinButtonPressed() {
    var userRef = Firestore.instance.collection('Users').document(globals.userState['userId']);
		userRef.get().then((snapshot) {
			Map userRequests = snapshot.data['requests'] == null
				? new Map()
				: snapshot.data['requests'];
			userRequests[globals.gameState['code']] = true;
			userRef.updateData(<String, dynamic>{
				'requests': userRequests,
			});
      globals.userState['requests'] = userRequests.toString();
      // setState(() {
      //   // just trigger a new build
      //   _showOverlay = false;
      // });
    });
    FirebaseDatabase.instance.reference().child('push').push().set(<String, dynamic>{
      'title': "New request to join the party!",
      'message': globals.userState['name'] + " would like to join " + globals.gameState['title'] + '.',
      'friendId': globals.gameState['creator'],
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
