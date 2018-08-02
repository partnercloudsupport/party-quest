import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gratzi_game/globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart';
import 'application.dart';
// import 'package:sticky_header_list/sticky_header_list.dart';
import 'package:fluro/fluro.dart';

class ChatView extends StatefulWidget {
  @override
  _ChatViewState createState() => new _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  String _gameId;

  _ChatViewState() {
    globals.gameState.changes.listen((changes) {
      // print(changes);
      // TODO only call setState once... not for every change of gameState
      setState(() {
        _gameId = globals.gameState['id'];
      });
    });
  }
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // CollectionReference get logs =>
    return GestureDetector(
        child: Column(children: <Widget>[
          _buildChatLog(),
          _buildActionButton(),
          globals.gameState['players']?.contains(globals.userState['userId']) ==
                  true
              ? _buildTextComposer()
              : _buildReactionComposer()
        ]),
        onVerticalDragDown: (DragDownDetails d) => closeKeyboard(d));
  }

  // TODO: optimize this...
  void closeKeyboard(DragDownDetails d) {
    // if (d.delta.distance > 20) {
    FocusScope.of(context).requestFocus(new FocusNode());
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    // }
  }

  Widget _buildActionButton() {
    var _gameId = globals.gameState['id'];
    if (_gameId != null) {
      return StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance
              .collection('Games')
              .document(_gameId)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) return new Text("Loading");
            var document = snapshot.data;
            if (globals.gameState['players']
                    ?.contains(globals.userState['userId']) ==
                true) {
              if (document['players'].length == 1) {
                return _buildInviteFriendsBox(context, document);
              }
              var turn = document['turn'];
              if (turn == null || turn['peggeeId'] == null) {
                return _buildPeggYourselfBox(context, document);
              }
              if (turn['peggeeId'] == globals.userState['userId']) {
                return _buildWaitingBox(context, document);
              }
              if(turn['guessers'] == null || turn['guessers'][globals.userState['userId']] == null) {
                return _buildPeggFriendBox(context, document);
              }
              if(turn['guessers'][globals.userState['userId']] == true) {
                return _buildWaitingBox(context, document);
              }
            } else {
              return Container();
              // _buildJoinButton();
            }
          });
    } else {
      return Expanded(child: Container());
    }
  }

  Widget _buildReactionComposer() {
    return Container(
        decoration: BoxDecoration(
          color: Color(0x22FFFFFF),
          // boxShadow: <BoxShadow>[
          //   BoxShadow(
          //     color: Colors.black12,
          //     blurRadius: 10.0,
          //     offset: Offset(0.0, -10.0),
          //   ),
          // ],
        ),
        height: 80.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                child: Image.asset('assets/images/1f60d.png')),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                child: Image.asset('assets/images/1f60e.png')),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                child: Image.asset('assets/images/1f92b.png')),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                child: Image.asset('assets/images/1f602.png')),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                child: Image.asset('assets/images/1f612.png')),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                child: Image.asset('assets/images/1f632.png')),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                child: Image.asset('assets/images/1f634.png')),
          ],
        ));
  }

  Widget _buildInviteFriendsBox(
      BuildContext context, DocumentSnapshot document) {
    return Row(children: <Widget>[
      Expanded(
          child: Container(
              height: 70.0,
              decoration: BoxDecoration(
                color: Color(0xFF00b0ff),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    offset: Offset(0.0, -10.0),
                  ),
                ],
              ),
              child: RaisedButton.icon(
                  icon: const Icon(Icons.add, size: 25.0, color: Colors.white),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(0.0)),
                  onPressed: () => Application.router.navigateTo(
                      context, 'inviteFriends?code=' + document['code'],
                      transition: TransitionType.fadeIn),
                  color: const Color(0xFF00B0FF),
                  label: Text("Invite Friends", //+ document['peggeeName'],
                      style: TextStyle(
                        fontSize: 25.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      )))))
    ]);
  }

  Widget _buildChatLog() {
    var _gameId = globals.gameState['id'];
    final now = DateTime.now();
    final monthAgo = new DateTime(now.year, now.month, now.day - 30);
    if (_gameId != null) {
      return Flexible(
          child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('Games/$_gameId/Logs')
                  .where('dts', isGreaterThan: monthAgo)
                  .orderBy('dts', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Text('Loading...');
                List<Widget> rows = [];
                snapshot.data.documents.forEach((document) {
                  rows.add(_buildMessage(document));
                });
                return ListView(reverse: true, children: rows);
              }));
    } else {
      return Expanded(child: Container());
    }
  }

  Widget _buildMessage(DocumentSnapshot document) {
    var message = new ChatMessage(
        type: document['type'],
        userId: document['userId'],
        userName: document['userName'],
        text: document['text'],
        profileUrl: document['profileUrl'],
        dts: document['dts']);
    if ((message.userName != null &&
        message.userId != globals.userState['userId'])) {
      return Column(children: <Widget>[
        _buildLabel(message.userName),
        ChatMessageListItem(message)
      ]);
    } else {
      return ChatMessageListItem(message);
    }
  }

  Widget _buildJoinButton() {
    return Container(
        decoration: BoxDecoration(color: Theme.of(context).cardColor),
        child: Row(children: <Widget>[
          Expanded(
              child: GestureDetector(
            child: Container(
                height: 70.0,
                padding: EdgeInsets.only(top: 15.0),
                decoration: BoxDecoration(
                  color: Color(0xFF00b0ff),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10.0,
                      offset: Offset(0.0, -10.0),
                    ),
                  ],
                ),
                child: Text(
                  "Request to Join",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                )),
            onTap: _handleJoinButtonPressed,
          ))
        ]));
  }

  void _handleJoinButtonPressed() {
    var userRef = Firestore.instance
        .collection('Users')
        .document(globals.userState['userId']);
    userRef.get().then((snapshot) {
      Map userRequests = snapshot.data['requests'] == null
          ? new Map()
          : snapshot.data['requests'];
      userRequests[globals.gameState['code']] = true;
      userRef.updateData(<String, dynamic>{
        'requests': userRequests,
      });
    });
  }

  Widget _buildTextComposer() {
    return Container(
        decoration: BoxDecoration(color: Colors.white),
        child: IconTheme(
            data: IconThemeData(color: Theme.of(context).accentColor),
            child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: Row(children: <Widget>[
                  Flexible(
                    child: TextField(
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: _textController,
                      onSubmitted: _handleSubmitted,
                      decoration: InputDecoration.collapsed(
                          hintText: "Send a message",
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
                    //     ?
                    BoxDecoration(
                  color: const Color(0xFF4C6296),
                  // border: Border(top: BorderSide(color: Colors.grey[200]))
                ))
            // : null),
            ));
  }

  void _handleSubmitted(String text) {
    var _gameId = globals.gameState['id'];
    _textController.clear();
    if (text.length > 0) {
      final DocumentReference document =
          Firestore.instance.collection('Games/$_gameId/Logs').document();
      document.setData(<String, dynamic>{
        'text': text,
        'dts': DateTime.now(),
        'profileUrl': globals.userState['profilePic'],
        'userName': globals.userState['name'],
        'userId': globals.userState['userId']
      });
    }
  }

  Widget _buildLabel(String text) {
    return Row(
        // margin: const EdgeInsets.all(10.0),
        children: <Widget>[
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(right: 15.0, top: 10.0),
                  child: Text(
                    text,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 0.5,
                      fontSize: 12.0,
                    ),
                  )))
        ]);
  }

  Widget _buildWaitingBox(BuildContext context, DocumentSnapshot document) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        color: const Color(0xFF00B0FF),
        child: Row(children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Text(
                  "Waiting on...",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    fontSize: 22.0,
                  ),
                ),
                Text(
                  "your friends to pegg " + document['turn']['peggeeName'] + ".",
                  style: TextStyle(
                    color: Colors.white,
                    // fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    fontSize: 14.0,
                  ),
                ),
                //TODO: NUDGE BUTTON
                // Padding(
                //     padding: EdgeInsets.all(10.0),
                //     child: FlatButton(
                //         key: null,
                //         onPressed: () => Application.router.navigateTo(context,
                //             'peggFriend?answerId=' + document['answerId'],
                //             transition: TransitionType.fadeIn),
                //         color: const Color(0xFF00B0FF),
                //         child: Text("Pegg " + document['peggeeName'],
                //             style: TextStyle(
                //               fontSize: 16.0,
                //               color: Colors.white,
                //               fontWeight: FontWeight.w800,
                //             )))),
              ],
            ),
          ),
          Container(
            width: 70.0,
            height: 70.0,
            decoration: BoxDecoration(
              //  color: Colors.black,
              image: DecorationImage(
                image: NetworkImage(document['turn']['peggeeProfileUrl']),
                // fit: BoxFit.cover,
              ),
            ),
          ),
        ]));
  }

  Widget _buildPeggFriendBox(BuildContext context, DocumentSnapshot document) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        color: const Color(0xFF00B0FF),
        child: Row(children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Text(
                  "Your Turn!",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    fontSize: 18.0,
                  ),
                ),
                Text(
                  "Guess which answer " + document['turn']['peggeeName'] + " picked.",
                  style: TextStyle(
                    color: Colors.white,
                    // fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    fontSize: 12.0,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                        key: null,
                        onPressed: () => Application.router.navigateTo(context,
                            'peggFriend?answerId=' + document['turn']['answerId'],
                            transition: TransitionType.fadeIn),
                        color: const Color(0x99FFFFFF),
                        child: Text("Pegg " + document['turn']['peggeeName'],
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                            )))),
              ],
            ),
          ),
          Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              //  color: Colors.black,
              image: DecorationImage(
                image: NetworkImage(document['turn']['peggeeProfileUrl']),
                // fit: BoxFit.cover,
              ),
            ),
          ),
        ]));
  }

  Widget _buildPeggYourselfBox(
      BuildContext context, DocumentSnapshot document) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        color: const Color(0xFF00B0FF),
        child: Row(children: <Widget>[
          Container(
            width: 100.0,
            height: 100.0,
            // child: CircleAvatar(
            //       backgroundImage: NetworkImage(globals.userState['profilePic']))
            decoration: BoxDecoration(
              //  color: Colors.black,
              image: DecorationImage(
                image: NetworkImage(globals.userState['profilePic']),
                // fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Text(
                  "Your Turn!",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    fontSize: 18.0,
                  ),
                ),
                Text(
                  "Pick a question and answer it...",
                  style: TextStyle(
                    color: Colors.white,
                    // fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    fontSize: 12.0,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                        key: null,
                        onPressed: () => Application.router.navigateTo(
                            context, 'peggYourself',
                            transition: TransitionType.fadeIn),
                        color: const Color(0x99FFFFFF),
                        child: Text("Pegg Yourself",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                            ))))
              ],
            ),
          )
        ]));
  }
}

class ChatMessage {
  ChatMessage(
      {this.type,
      this.userId,
      this.userName,
      this.text,
      this.profileUrl,
      this.dts});
  final String type;
  final String userId;
  final String text;
  final String profileUrl;
  final String userName;
  final DateTime dts;
}

class ChatMessageListItem extends StatelessWidget {
  ChatMessageListItem(this.message);

  final ChatMessage message;

  Widget build(BuildContext context) {
    var chatItem;
    if (message.userId != globals.userState['userId']) {
      chatItem = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Bubble(
                  message: message.text,
                  time: timeAgo(message.dts.toLocal()),
                  delivered: true,
                  isMe: true,
                  type: message.type),
            ],
          )),
          Container(
            margin: const EdgeInsets.only(left: 8.0),
            child:
                CircleAvatar(backgroundImage: NetworkImage(message.profileUrl)),
          ),
        ],
      );
    } else {
      chatItem = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            child:
                CircleAvatar(backgroundImage: NetworkImage(message.profileUrl)),
          ),
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bubble(
                  message: message.text,
                  time: timeAgo(message.dts.toLocal()),
                  delivered: true,
                  isMe: false,
                  type: message.type),
            ],
          )),
        ],
      );
    }
    return Container(
        margin: const EdgeInsets.only(
            left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
        child: chatItem);
  }
}

class Bubble extends StatelessWidget {
  Bubble({this.message, this.time, this.delivered, this.isMe, this.type});

  final String message, time, type;
  final delivered, isMe;

  @override
  Widget build(BuildContext context) {
    final bg = type == 'question' || type == 'guess'
        ? Colors.white.withOpacity(.9)
        : Colors.white.withOpacity(.2);
    final fontColor =
        type == 'question' || type == 'guess' ? Colors.black : Colors.white;
    final align = isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    // final icon = delivered ? Icons.done_all : Icons.done;
    final radius = isMe
        ? BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          )
        : BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          );
    return Column(
      crossAxisAlignment: align,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(3.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  blurRadius: .5,
                  spreadRadius: 1.0,
                  color: Colors.black.withOpacity(.12))
            ],
            color: bg,
            borderRadius: radius,
          ),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 18.0),
                child: Text(message,
                    style: TextStyle(fontSize: 17.0, color: fontColor)),
              ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Row(
                  children: <Widget>[
                    Text(time,
                        style: TextStyle(
                          color: fontColor.withOpacity(.8),
                          fontSize: 10.0,
                        )),
                    SizedBox(width: 3.0),
                    // Icon(
                    //   icon,
                    //   size: 12.0,
                    //   color: Colors.black38,
                    // )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
