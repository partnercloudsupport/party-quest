import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart';
import '../application.dart';
import 'package:fluro/fluro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../components/roll_button.dart';
import '../components/reactions_view.dart';
import '../components/rating_button.dart';
import '../components/chatMessageItem.dart';
import 'package:firebase_database/firebase_database.dart';


class ChatView extends StatefulWidget {
  final String gameId;
  ChatView(this.gameId);
  
	@override
	_ChatViewState createState() => new _ChatViewState();
}

class _ChatViewState extends State<ChatView> {

	@override
	void initState() {
		super.initState();
	}

	bool _showOverlay = false;
  Map _turn, _characters;
  ListView _listView;
  ScrollController _listViewController = ScrollController();
	TapUpDetails _tapUpDetails;
	DocumentSnapshot _tappedBubble;

	_ChatViewState() {
    _showOverlay = false;
	}
	final TextEditingController _textController = TextEditingController();

	@override
	Widget build(BuildContext context) {
		// CollectionReference get logs =>
    WidgetsBinding.instance
    .addPostFrameCallback((_) => jumpToLine());
		return 
    Scaffold(
			// backgroundColor: Colors.white,
			// drawer: AccountDrawer(), // left side
			appBar: AppBar(
        // elevation: 0.0,
        title: Text(globals.gameState['title'], style: TextStyle(color: Colors.white, fontSize: 30.0)),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
					icon: Icon(Icons.close, color: Colors.white),
					onPressed: () => Navigator.pop(context)),
        actions: <Widget>[
					IconButton(
						icon: Icon(
							Icons.info_outline,
							color: Colors.white,
						),
						tooltip: 'Info about this Game.',
						onPressed: _openInfoView)
				],
      ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
            // image: AssetImage("assets/images/$_gameType.jpg"),
            image: AssetImage("assets/images/background-purple.png"),
            fit: BoxFit.cover,
            // colorFilter: ColorFilter.mode(
            // Colors.black.withOpacity(0.9), BlendMode.dstATop)
          )
          ),
          child: Stack(children: <Widget>[
          // Column(children: <Widget>[
            Flex(direction: Axis.vertical, children: <Widget>[_buildChatLog(), Container(height: 150.0)]),
            Align(alignment: Alignment.bottomCenter, child: _buildActionButton()),
            Align(alignment: Alignment.bottomCenter, child: 
            globals.gameState['players']?.contains(globals.userState['userId']) == true
              ? _buildTextComposer()
              : _buildInfoBox('Tap any speech bubble to react to what players are saying.')),
            _showOverlay == true ? _buildOverlay(ReactionsView(_tappedBubble, _tapUpDetails, _onCloseOverlay)) : Container()
        ])
    ));
	}

  Future<void> jumpToLine() async {
    _listViewController.animateTo(300.0, duration: Duration(milliseconds: 1000), curve: Curves.easeIn);
  }

  void _onCloseOverlay(){
    setState(() {
      _showOverlay = false;
    });
  }

	Widget _buildInfoBox(String infoText){
		return Container(
			decoration: BoxDecoration(
				color: Theme.of(context).accentColor,
				// boxShadow: <BoxShadow>[
				// BoxShadow(
				// color: Colors.black12,
				// blurRadius: 10.0,
				// offset: Offset(0.0, -10.0),
				// ),
				// ],
			),
			height: 80.0,
			child: Padding(padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
				child: Text(infoText, style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w400))));
	}

	Widget _buildOverlay(Widget content) {
		MediaQueryData queryData;
		queryData = MediaQuery.of(context);
		return GestureDetector(
			child: Center(
				child: Container(
					width: queryData.size.width,
					height: queryData.size.height,
					child: content,
					decoration: BoxDecoration(
						shape: BoxShape.rectangle,
						color: Colors.black.withOpacity(.4),
					)),
			),
			onTap: _onCloseOverlay);
		}

  void _openInfoView() {
		Application.router
			.navigateTo(context, 'info', transition: TransitionType.native);
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
                  return RatingButton(_turn);
                } else {
                  return _buildButton(_turn['playerImageUrl'], null,
                    'Waiting on...', 'Another player to set the difficulty.');
                }
              }
              // ROLL PHASE
              if(_turn['turnPhase'] == 'roll'){
                return RollButton(_turn, _characters);
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
              return RatingButton(_turn);
            }

            DateTime now = DateTime.now();
            DateTime threeHoursAgo = DateTime(now.year, now.month, now.day, now.hour - 3);
            if(_turn['dts'].isBefore(threeHoursAgo)) {
              if(_turn['playerImageUrl'] != null && _turn['playerName'] != null) {
                return _buildButton(_turn['playerImageUrl'], () => _skipTurn(snapshot.data.reference, _turn['playerId']),
                  'Skip turn...', _turn['playerName'] + ' hasnt played in over three hours.');
              } else {
                return _buildButton(document['imageUrl'], () => _skipTurn(snapshot.data.reference, _turn['playerId']),
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

  void _skipTurn(DocumentReference docRef, String playerId){
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


	Widget _buildChatLog() {
		// var gameId = globals.gameState['id'];
		final now = DateTime.now();
		final monthAgo = new DateTime(now.year, now.month, now.day - 30);
		if (widget.gameId != null) {
			return Expanded(child: GestureDetector(
        onVerticalDragDown: (DragDownDetails d) => closeKeyboard(d),
				child: StreamBuilder<QuerySnapshot>(
					stream: Firestore.instance
						.collection('Games/${widget.gameId}/Logs')
						.where('dts', isGreaterThan: monthAgo)
						.orderBy('dts', descending: false)
						.snapshots(),
					builder: (BuildContext context,
						AsyncSnapshot<QuerySnapshot> snapshot) {
						if (!snapshot.hasData) return const Text('Loading...');
						final int messageCount = snapshot.data.documents.length;
						_listView = ListView.builder(
							reverse: false,
              controller: _listViewController,
							itemCount: messageCount,
							itemBuilder: (_, int index) {
								final DocumentSnapshot document = snapshot.data.documents[index];
                List<Widget> logItems = [];
                DocumentSnapshot nextDocument;
                // Get next document
								if (index + 1 < messageCount) nextDocument = snapshot.data.documents[index + 1];
								else nextDocument = snapshot.data.documents[index];
                // Build label if needed
                if (document['userName'] != null && (index == messageCount-1 || document['userId'] != nextDocument['userId'])){
                  logItems.add(_buildLabel(document['userName'], document['dts']));
                }
                logItems.add(GestureDetector(
                  child: ChatMessageListItem(document),
                  onTapUp: (TapUpDetails details) => _onTapBubble(details, document)));
                return Column(children: logItems);
            });
            return _listView;
					})));
		} else {
			return Expanded(child: Container());
		}
	}

	// TODO: optimize this...
	void closeKeyboard(DragDownDetails d) {
		// if (d.delta.distance > 20) {
		FocusScope.of(context).requestFocus(new FocusNode());
		SystemChannels.textInput.invokeMethod('TextInput.hide');
		// }
	}
  
	void _onTapBubble(TapUpDetails details, DocumentSnapshot document) {
    setState(() {
      _showOverlay = true;
      _tapUpDetails = details;
      _tappedBubble = document;
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
      setState(() {
        // just trigger a new build
        _showOverlay = false;
      });
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

	Widget _buildTextComposer() {
		return 
      // Container(
			// decoration: BoxDecoration(color: Colors.white),
			// child: IconTheme(
			// 	data: IconThemeData(color: Theme.of(context).accentColor),
			// 	child: 
        Container(
					child: Row(children: <Widget>[
						Flexible(
							child: TextField(
								style: TextStyle(color: Colors.white, fontSize: 20.0, fontFamily: 'LondrinaSolid'),
								maxLines: null,
                cursorColor: Colors.white,
                cursorWidth: 3.0,
								keyboardType: TextInputType.multiline,
								controller: _textController,
								onSubmitted: _handleSubmitted,
								decoration: InputDecoration(
									contentPadding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
									hintText: "Send a message",
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
									hintStyle: TextStyle(color: Colors.white)),
							),
						),
						Container(
							margin: EdgeInsets.only(left: 4.0),
							child: IconButton(
								icon: Icon(
									Icons.send,
									color: Colors.white,
									size: 30.0,
								),
								onPressed: () =>
									_handleSubmitted(_textController.text))),
					]),
					decoration:
						// Theme.of(context).platform == TargetPlatform.iOS
						// ?
						BoxDecoration(
							color: const Color(0x00FFFFFF),
							border: Border(top: BorderSide(color:const Color(0x00FFFFFF)))));
				// : null),
				// ));
	}

	void _handleSubmitted(String text) {
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
			});
		}
	}

	Widget _buildLabel(String username, DateTime dts) {
		return Row(
			// margin: const EdgeInsets.all(10.0),
			children: <Widget>[
				Expanded(
					child: Padding(
						padding: username == globals.userState['name'] ? EdgeInsets.only(left: 15.0, top: 10.0) : EdgeInsets.only(right: 15.0, top: 10.0),
						child: Column(crossAxisAlignment: username == globals.userState['name'] ? CrossAxisAlignment.start : CrossAxisAlignment.end, children: <Widget>[Text(
							username,
							textAlign: TextAlign.right,
							style: TextStyle(
								color: Colors.white,
								letterSpacing: 0.5,
								fontSize: 14.0,
							),
						), Text(timeAgo(dts.toLocal()),
							style: TextStyle(
								color: Colors.white.withOpacity(.8),
								fontSize: 12.0,
							))
			])))]);
	}

	Widget _buildButton(
		String buttonImage, Function onPressed, String title, String subtitle) {
		// BuildContext context, DocumentSnapshot document) {
		return Container(
      height: 200.0,
			decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/bottom-clouds.png'), fit: BoxFit.fitHeight)),
      // BoxDecoration(color:Theme.of(context).accentColor),
			child: Container(
				padding: EdgeInsets.only(top: 50.0, left: 10.0, right: 10.0),
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
										onPressed: onPressed,
										color: Theme.of(context).buttonColor,
										shape: RoundedRectangleBorder(
											borderRadius: new BorderRadius.circular(40.0)),
										child: Row(
											children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(.3),
													backgroundImage: buttonImage.contains('http') ? CachedNetworkImageProvider(buttonImage) : AssetImage(buttonImage)),
												Expanded(
													child: Padding(
														padding: EdgeInsets.only(left: 10.0),
														child: Column(
															crossAxisAlignment:
																CrossAxisAlignment.start,
															children: <Widget>[
																Text(title,
																	style: TextStyle(
																		fontSize: 22.0,
																		color: Colors.white,
																		fontWeight: FontWeight.w800,
																	)),
																Text(
																	subtitle,
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
}