import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gratzi_game/globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart';

class ChatView extends StatefulWidget {
  @override
  _ChatViewState createState() => new _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  _ChatViewState() {
    globals.gameState.changes.listen((changes) {
      // print(changes);
      // TODO only call setState once... not for every change of gameState
      setState(() {
        _gameId = globals.gameState['id'];
        _gameType = globals.gameState['type'];
        _gamePlayers = globals.gameState['players'];
      });
    });
  }
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  // CollectionReference get logs => Firestore.instance.collection('Logs');
  String _gameId;
  String _gamePlayers = "";
  String _gameType = 'bubbles_bg';

  @override
  Widget build(BuildContext context) {
    // CollectionReference get logs =>
    return GestureDetector(
            child: Column(children: <Widget>[
              _buildChatLog(),
              globals.gameState['players']?.contains(globals.userState['userId']) == true ? _buildTextComposer() : _buildJoinButton()
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

  Widget _buildChatLog() {
    return Flexible(
        child: StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('Games/$_gameId/Logs')
          .orderBy('dts', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        final int messageCount = snapshot.data.documents.length;
        return new ListView.builder(
          reverse: true,
          itemCount: messageCount,
          itemBuilder: (_, int index) {
            final DocumentSnapshot document = snapshot.data.documents[index];
            DocumentSnapshot nextDocument;
            if (index + 1 < messageCount) {
              nextDocument = snapshot.data.documents[index + 1];
            } else {
              nextDocument = snapshot.data.documents[index];
            }
            var message = new ChatMessage(
                userId: document['userId'],
                userName: document['userName'],
                text: document['text'],
                profileUrl: document['profileUrl'],
                dts: document['dts']);
            if ((message.userName != nextDocument['userName'] &&
                    message.userId != globals.userState['userId'])) { // || index == messageCount - 1
              return Column(children: <Widget>[
                _buildLabel(message.userName),
                ChatMessageListItem(message)
              ]);
            } else {
              return ChatMessageListItem(message);
            }
          },
        );
      },
    ));
  }

  Widget _buildJoinButton() {
    return Container(
        decoration: BoxDecoration(color: Theme.of(context).cardColor),
        child: Row(children: <Widget>[
          Expanded(
              child: GestureDetector(
            child: Container(
                height: 60.0,
                padding: EdgeInsets.symmetric(vertical: 10.0),
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
      Map userRequests = snapshot.data['requests'];
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
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(children: <Widget>[
                Flexible(
                  child: TextField(
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    controller: _textController,
                    onChanged: _handleMessageChanged,
                    onSubmitted: _handleSubmitted,
                    decoration: 
                        InputDecoration.collapsed(hintText: "Send a message", hintStyle: TextStyle(color: Colors.white)),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(left: 4.0),
                    child: 
                    // Theme.of(context).platform == TargetPlatform.iOS
                    //     ? CupertinoButton(
                    //         child: Text("Send"),
                    //         onPressed: _isComposing
                    //             ? () => _handleSubmitted(_textController.text)
                    //             : null,
                    //       )
                    //     : 
                        IconButton(
                            icon: Icon(Icons.send, color: Colors.white, size: 30.0,),
                            onPressed: _isComposing
                                ? () => _handleSubmitted(_textController.text)
                                : null,
                          )),
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

  Widget _buildTitleBox(String text) {
    return Container(
        margin: const EdgeInsets.all(14.0),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            fontSize: 22.0,
          ),
        ));
  }

  void _handleMessageChanged(String text) {
    setState(() {
      _isComposing = text.length > 0;
    });
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    // setState(() {
    //   _isComposing = false;
    // });
    // await _ensureLoggedIn();
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
}

class ChatMessage {
  ChatMessage(
      {this.userId, this.userName, this.text, this.profileUrl, this.dts});
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
              ),
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
              ),
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
  Bubble({this.message, this.time, this.delivered, this.isMe});

  final String message, time;
  final delivered, isMe;

  @override
  Widget build(BuildContext context) {
    final bg =
        isMe ? Colors.white.withOpacity(.2) : Colors.white.withOpacity(.2);
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
                    style: TextStyle(
                      fontSize: 17.0,
                      color: Colors.white
                    )),
              ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Row(
                  children: <Widget>[
                    Text(time,
                        style: TextStyle(
                          color: Colors.white70,
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
//     ListView(
//   reverse: true,
//   children: <Widget>[
//     // IconButton(
//     //   icon: Icon(Icons.explore),
//     //   color: Colors.white,
//     //   onPressed: _scaffoldKey.currentState.openDrawer
//     // ),
//     _buildActionBox(),
//     _buildTurnBox(
//         'Slipp the Dogger',
//         "Gives zero fucks. Great at detecting bullshit.",
//         "assets/images/hipster.jpg"),
//     _buildTextBox("Do you attempt something like look around for another exit? Or do you attack someone?"),
//     _buildTextBox("What do you do?"),
//     _buildTextBox(
//         "You and your friends are on your way to an underground dance party when you get lost. You know you’ve made a mistake when the door of an abandoned factory locks shut behind you, trapping you inside…"),
//     _buildTextBox(
//         "A disgruntled former employee wants to wreak mechanized terror on those who wronged him."),
//     _buildTextBox("In a run-down car factory in Detroit."),
//     _buildTitleBox("Chapter One")
//   ],
// )

// Widget _buildTextBox(String text) {
//   return Container(
//       margin: const EdgeInsets.all(10.0),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: Colors.black,
//           // fontWeight: FontWeight.w800,
//           letterSpacing: 0.5,
//           fontSize: 16.0,
//         ),
//       ));
// }

Widget _buildTurnBox(String title, String subtitle, String image) {
  return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
      color: Colors.white,
      child: Row(children: <Widget>[
        Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
            //  color: Colors.black,
            image: DecorationImage(
              image: AssetImage(image),
              // fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  fontSize: 18.0,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.black,
                  // fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        )
      ]));
}

// Widget _buildActionBox() {
//   return Container(
//       margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
//       color: Colors.white,
//       child: Row(
//         children: <Widget>[
//           Expanded(
//             child: Padding(
//                 padding: const EdgeInsets.all(15.0),
//                 child: FlatButton(
//                     key: null,
//                     onPressed: () => {},
//                     color: const Color(0xFFBA5536),
//                     child: Text(
//                       "Attempt",
//                       style: TextStyle(
//                           fontSize: 16.0,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w800,
//                     ))),
//           ),
//           Expanded(
//               child: Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: FlatButton(
//                 key: null,
//                 onPressed: () => {},
//                 color: const Color(0xFFA43820),
//                 child: Text(
//                   "Attack",
//                   style: TextStyle(
//                       fontSize: 16.0,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w800,
//                 )),
//           )),
//         ],
//       ));
// }
