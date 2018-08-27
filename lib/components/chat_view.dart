import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pegg_party/globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart';
import '../application.dart';
import 'package:fluro/fluro.dart';
import 'video_player.dart';

class ChatView extends StatefulWidget {
  @override
  _ChatViewState createState() => new _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
  }

  String _gameId;
  bool _showGifOverlay = false;
  String _activeGifUrl;

  _ChatViewState() {
    globals.gameState.changes.listen((changes) {
      // print(changes);
      // TODO only call setState once... not for every change of gameState
      setState(() {
        _gameId = globals.gameState['id'];
        _showGifOverlay = false;
      });
    });
  }
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // CollectionReference get logs =>
    return GestureDetector(
        child: Stack(children: <Widget>[
          Column(children: <Widget>[
            _buildChatLog(),
            _buildActionButton(),
            globals.gameState['players']
                        ?.contains(globals.userState['userId']) ==
                    true
                ? _buildTextComposer()
                : _buildReactionComposer()
          ]),
          _showGifOverlay == true ? _buildGifOverlay() : Container()
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

  Widget _buildGifOverlay() {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    return GestureDetector(
        child: Center(
          child: Container(
              width: queryData.size.width,
              height: queryData.size.height,
              child: PeggVideoPlayer(_activeGifUrl),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.black.withOpacity(.4),
              )),
        ),
        onTap: _closeOverlay);
  }

  void _closeOverlay() {
    setState(() {
      _showGifOverlay = false;
    });
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
                Function inviteFriends = () => Application.router.navigateTo(
                    context, 'inviteFriends?code=' + document['code'],
                    transition: TransitionType.fadeIn);
                return _buildButton(document['imageUrl'], inviteFriends,
                    'Invite friends...', 'to get this Pegg Party started!');
              }
              var turn = document['turn'];
              if (turn == null || turn['peggeeId'] == null) {
                Function onPressed = () => Application.router.navigateTo(
                    context, 'peggYourself',
                    transition: TransitionType.fadeIn);
                return _buildButton(globals.userState['profilePic'], onPressed,
                    'Pegg Yourself', 'Pick a question and answer it.');
              }
              if (turn['peggeeId'] == globals.userState['userId']) {
                return _buildButton(globals.userState['profilePic'], null,
                    'Waiting on...', 'your friends to Pegg you.');
              }
              if (turn['guessers'] == null ||
                  turn['guessers'][globals.userState['userId']] == null) {
                Function onPressed = () => Application.router.navigateTo(
                    context, 'peggFriend?answerId=' + turn['answerId'],
                    transition: TransitionType.fadeIn);
                return _buildButton(
                    turn['peggeeProfileUrl'],
                    onPressed,
                    'Pegg ' + turn['peggeeName'],
                    "Guess which answer they picked.");
              }
              if (turn['guessers'][globals.userState['userId']] == true) {
                return _buildButton(turn['peggeeProfileUrl'], null,
                    'Waiting on...', 'friends to Pegg ' + turn['peggeeName']);
              }
            } else {
              return Container();
              // return _buildButton(
              //     document['imageUrl'],
              //     _handleJoinButtonPressed,
              //     'Request to Join...',
              //     'so you can pegg each other and chat!');
            }
          });
    } else {
      return Expanded(child: Container());
    }
  }

  Widget _buildReactionComposer() {
    return Container(
        decoration: BoxDecoration(
          color: Color(0xFF4C6296),
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
            // Padding(
            //     padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            //     child: Image.asset('assets/images/1f92b.png')),
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

  Widget _buildChatLog() {
    var _gameId = globals.gameState['id'];
    final now = DateTime.now();
    final monthAgo = new DateTime(now.year, now.month, now.day - 30);
    if (_gameId != null) {
      return Expanded(
          child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('Games/$_gameId/Logs')
                  .where('dts', isGreaterThan: monthAgo)
                  .orderBy('dts', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Text('Loading...');
                final int messageCount = snapshot.data.documents.length;
                return new ListView.builder(
                    reverse: true,
                    itemCount: messageCount,
                    itemBuilder: (_, int index) {
                      final DocumentSnapshot document =
                          snapshot.data.documents[index];
                      DocumentSnapshot nextDocument;
                      if (index + 1 < messageCount) {
                        nextDocument = snapshot.data.documents[index + 1];
                      } else {
                        nextDocument = snapshot.data.documents[index];
                      }
                      var message = new ChatMessage(
                          type: document['type'],
                          userId: document['userId'],
                          userName: document['userName'],
                          text: document['text'].replaceAllMapped(
                              new RegExp(r'\[([^|]+)\|([^\]]+)]'),
                              (Match m) => '${m[1]}'),
                          profileUrl: document['profileUrl'],
                          dts: document['dts']);
                      if (message.userName != null &&
                          message.userId != globals.userState['userId'] &&
                          message.userName != nextDocument['userName']) {
                        return Column(children: <Widget>[
                          _buildLabel(message.userName),
                          GestureDetector(
                              child: ChatMessageListItem(message),
                              onTap: () => _onTapBubble(document['gif'])),
                          // document['gif'] != null
                          //     ? PeggVideoPlayer(document['gif'])
                          //     : Container()
                        ]);
                      } else {
                        return Column(children: <Widget>[
                          GestureDetector(
                              child: ChatMessageListItem(message),
                              onTap: () => _onTapBubble(document['gif'])),
                          // document['gif'] != null
                          //     ? PeggVideoPlayer(document['gif'])
                          //     : Container()
                        ]);
                      }
                    });
              }));
    } else {
      return Expanded(child: Container());
    }
  }

  void _onTapBubble(String gifUrl) {
    if (gifUrl != null) {
      setState(() {
        _showGifOverlay = true;
        _activeGifUrl = gifUrl;
      });
    }
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
                child: Row(children: <Widget>[
                  Flexible(
                    child: TextField(
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: _textController,
                      onSubmitted: _handleSubmitted,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(20.0),
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
                        border: Border(
                            top: BorderSide(color: const Color(0xFF4C6296)))))
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

  Widget _buildButton(
      String buttonImage, Function onPressed, String title, String subtitle) {
    // BuildContext context, DocumentSnapshot document) {
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
                            onPressed: onPressed,
                            color: const Color(0xFF00b0ff),
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(40.0)),
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                    backgroundImage: NetworkImage(buttonImage)),
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
                                                  fontSize: 12.0,
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
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: Offset(0.0, 7.0),
                    color: Colors.black.withOpacity(.2))
              ],
            ),
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
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: Offset(0.0, 7.0),
                    color: Colors.black.withOpacity(.2))
              ],
            ),
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
    var bg = Colors.white.withOpacity(.2);
    if (type == 'question') {
      bg = const Color(0xFFFFFFFF);
    } else if (type == 'win') {
      bg = const Color(0xBB9DEB0F);
    } else if (type == 'fail') {
      bg = const Color(0xBBFF694F);
    } else if (type == 'answer') {
      bg = const Color(0xFF9DEB0F);
    }
    final fontColor = type == 'question' ||
            type == 'answer' ||
            type == 'win' ||
            type == 'fail'
        ? Colors.black
        : Colors.white;
    final align = isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    // final icon = delivered ? Icons.done_all : Icons.done;
    final radius = isMe
        ? BorderRadius.only(
            topLeft: Radius.circular(20.0),
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          )
        : BorderRadius.only(
            topRight: Radius.circular(20.0),
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          );
    return Column(
      crossAxisAlignment: align,
      children: <Widget>[
        Container(
          foregroundDecoration: type == 'guess'
              ? BoxDecoration(color: Colors.black, borderRadius: radius)
              : null,
          margin: const EdgeInsets.all(3.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  blurRadius: 10.0,
                  spreadRadius: 1.0,
                  offset: Offset(0.0, 10.0),
                  color: Colors.black.withOpacity(.2))
            ],
            color: bg,
            borderRadius: radius,
          ),
          child: Stack(
            children: <Widget>[
              type != null
                  ? Positioned(
                      top: 0.0,
                      right: isMe == true ? 0.0 : null,
                      left: isMe != true ? 0.0 : null,
                      child: Text(type,
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black,
                              fontWeight: FontWeight.w600)),
                    )
                  : Container(width: 0.0),
              Padding(
                padding: type != null
                    ? EdgeInsets.symmetric(vertical: 18.0)
                    : EdgeInsets.only(bottom: 18.0),
                child: Text(message,
                    style: TextStyle(fontSize: 17.0, color: fontColor),
                    textAlign: isMe == true ? TextAlign.right : TextAlign.left),
              ),
              Positioned(
                bottom: 0.0,
                right: isMe == true ? 0.0 : null,
                left: isMe != true ? 0.0 : null,
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

// Widget _buildPeggFriendBox(BuildContext context, DocumentSnapshot document) {
//   return Container(
//       decoration: BoxDecoration(color: const Color(0xFF4C6296)),
//       child: Container(
//           // margin: const EdgeInsets.only(
//           //     bottom: 10.0, left: 10.0, right: 10.0, top: 10.0),
//           // decoration: BoxDecoration(
//           //     color: const Color(0x22FFFFFF),
//           //     borderRadius: BorderRadius.all(Radius.circular(50.0))),
//           // foregroundDecoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.all(Radius.circular(50.0))),
//           padding: EdgeInsets.all(10.0),
//           child: Row(children: <Widget>[
//             Expanded(
//               child: Column(
//                 children: <Widget>[
//                   // Text(
//                   //   "Your Turn!",
//                   //   textAlign: TextAlign.left,
//                   //   style: TextStyle(
//                   //     color: Colors.white,
//                   //     fontWeight: FontWeight.w800,
//                   //     letterSpacing: 0.5,
//                   //     fontSize: 18.0,
//                   //   ),
//                   // ),
//                   Padding(
//                       padding: EdgeInsets.all(5.0),
//                       child: RaisedButton(
//                           padding: EdgeInsets.all(10.0),
//                           // padding: EdgeInsets.symmetric(
//                           //     horizontal: 60.0, vertical: 20.0),
//                           onPressed: () => Application.router.navigateTo(
//                               context,
//                               'peggFriend?answerId=' +
//                                   document['turn']['answerId'],
//                               transition: TransitionType.fadeIn),
//                           color: const Color(0xFF00b0ff),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: new BorderRadius.circular(40.0)),
//                           child: Row(
//                             children: <Widget>[
//                               CircleAvatar(
//                                   backgroundImage: NetworkImage(
//                                       document['turn']['peggeeProfileUrl'])),
//                               Expanded(
//                                   child: Padding(
//                                       padding: EdgeInsets.only(left: 10.0),
//                                       child: Text(
//                                           "Pegg " +
//                                               document['turn']['peggeeName'],
//                                           style: TextStyle(
//                                             fontSize: 22.0,
//                                             color: Colors.white,
//                                             fontWeight: FontWeight.w800,
//                                           ))))
//                             ],
//                           ))),
//                   // Text(
//                   //   "Guess which answer " +
//                   //       document['turn']['peggeeName'] +
//                   //       " picked.",
//                   //   style: TextStyle(
//                   //     color: Colors.white,
//                   //     // fontWeight: FontWeight.w800,
//                   //     letterSpacing: 0.5,
//                   //     fontSize: 12.0,
//                   //   ),
//                   // )
//                 ],
//               ),
//             ),
//             // Container(
//             //   width: 100.0,
//             //   height: 100.0,
//             //   decoration: BoxDecoration(
//             //     //  color: Colors.black,
//             //     image: DecorationImage(
//             //       image: NetworkImage(document['turn']['peggeeProfileUrl']),
//             //       // fit: BoxFit.cover,
//             //     ),
//             //   ),
//             // ),
//           ])));
// }

// Widget _buildPeggeeWaitingBox(
//     BuildContext context, DocumentSnapshot document) {
//   return Container(
//       decoration: BoxDecoration(color: const Color(0xFF4C6296)),
//       child: Container(
//           margin: const EdgeInsets.only(
//               bottom: 10.0, left: 10.0, right: 10.0, top: 10.0),
//           decoration: BoxDecoration(
//               color: const Color(0x22FFFFFF),
//               borderRadius: BorderRadius.all(Radius.circular(50.0))),
//           // foregroundDecoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.all(Radius.circular(50.0))),
//           padding: EdgeInsets.all(10.0),
//           child: Row(children: <Widget>[
//             Container(
//               width: 70.0,
//               height: 70.0,
//               decoration: BoxDecoration(
//                 //  color: Colors.black,
//                 borderRadius: BorderRadius.all(Radius.circular(50.0)),
//                 image: DecorationImage(
//                   image: NetworkImage(document['turn']['peggeeProfileUrl']),
//                   // fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Column(
//                 children: <Widget>[
//                   Text(
//                     "Waiting on...",
//                     textAlign: TextAlign.left,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 0.5,
//                       fontSize: 22.0,
//                     ),
//                   ),
//                   Text(
//                     "your friends to pegg you.",
//                     style: TextStyle(
//                       color: Colors.white,
//                       // fontWeight: FontWeight.w800,
//                       letterSpacing: 0.5,
//                       fontSize: 14.0,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ])));
// }

// Widget _buildPeggerWaitingBox(
//     BuildContext context, DocumentSnapshot document) {
//   return Container(
//       margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
//       color: const Color(0xFF00B0FF),
//       child: Row(children: <Widget>[
//         Expanded(
//           child: Column(
//             children: <Widget>[
//               Text(
//                 "Waiting on...",
//                 textAlign: TextAlign.left,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: 0.5,
//                   fontSize: 22.0,
//                 ),
//               ),
//               Text(
//                 "your friends to pegg " +
//                     document['turn']['peggeeName'] +
//                     ".",
//                 style: TextStyle(
//                   color: Colors.white,
//                   // fontWeight: FontWeight.w800,
//                   letterSpacing: 0.5,
//                   fontSize: 14.0,
//                 ),
//               ),
//               //TODO: NUDGE BUTTON
//               // Padding(
//               //     padding: EdgeInsets.all(10.0),
//               //     child: FlatButton(
//               //         key: null,
//               //         onPressed: () => Application.router.navigateTo(context,
//               //             'peggFriend?answerId=' + document['answerId'],
//               //             transition: TransitionType.fadeIn),
//               //         color: const Color(0xFF00B0FF),
//               //         child: Text("Pegg " + document['peggeeName'],
//               //             style: TextStyle(
//               //               fontSize: 16.0,
//               //               color: Colors.white,
//               //               fontWeight: FontWeight.w800,
//               //             )))),
//             ],
//           ),
//         ),
//         Container(
//           width: 70.0,
//           height: 70.0,
//           decoration: BoxDecoration(
//             //  color: Colors.black,
//             image: DecorationImage(
//               image: NetworkImage(document['turn']['peggeeProfileUrl']),
//               // fit: BoxFit.cover,
//             ),
//           ),
//         ),
//       ]));
// }

// Widget _buildInviteFriendsBox(
//     BuildContext context, DocumentSnapshot document) {
//   return Row(children: <Widget>[
//     Expanded(
//         child: Container(
//             height: 70.0,
//             decoration: BoxDecoration(
//               color: Color(0xFF00b0ff),
//               boxShadow: <BoxShadow>[
//                 BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 10.0,
//                   offset: Offset(0.0, -10.0),
//                 ),
//               ],
//             ),
//             child: RaisedButton.icon(
//                 icon: const Icon(Icons.add, size: 25.0, color: Colors.white),
//                 shape: new RoundedRectangleBorder(
//                     borderRadius: new BorderRadius.circular(0.0)),
//                 onPressed: () => Application.router.navigateTo(
//                     context, 'inviteFriends?code=' + document['code'],
//                     transition: TransitionType.fadeIn),
//                 color: const Color(0xFF00B0FF),
//                 label: Text("Invite Friends", //+ document['peggeeName'],
//                     style: TextStyle(
//                       fontSize: 25.0,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w800,
//                     )))))
//   ]);
// }

// Widget _buildJoinButton() {
//   return Container(
//       child: Row(children: <Widget>[
//     Expanded(
//         child: GestureDetector(
//       child: Container(
//           height: 60.0,
//           margin: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
//           padding: EdgeInsets.only(top: 15.0),
//           decoration: BoxDecoration(
//               color: const Color(0xFF00B0FF),
//               borderRadius: BorderRadius.all(Radius.circular(50.0))),
//           child: Text(
//             "Request to Join",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//                 fontSize: 22.0,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white),
//           )),
//       onTap: _handleJoinButtonPressed,
//     ))
//   ]));
// }
