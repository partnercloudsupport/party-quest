import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatView extends StatefulWidget {
  static String tag = 'info-page';
  @override
  _ChatViewState createState() => new _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  CollectionReference get logs => Firestore.instance.collection('Logs');

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: StreamBuilder<QuerySnapshot>(
      stream: logs.orderBy('dts', descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        final int messageCount = snapshot.data.documents.length;
        return new ListView.builder(
          reverse: true,
          itemCount: messageCount,
          itemBuilder: (_, int index) {
            final DocumentSnapshot document = snapshot.data.documents[index];
            var message = new ChatMessage(
                userName: document['userName'],
                text: document['text'],
                profileUrl: document['profileUrl']);
            return ChatMessageListItem(message);
          },
        );
      },
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
            // fontFamily: 'Roboto',
            letterSpacing: 0.5,
            fontSize: 22.0,
          ),
        ));
  }

  Widget _buildTextBox(String text) {
    return Container(
        margin: const EdgeInsets.all(10.0),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            // fontWeight: FontWeight.w800,
            // fontFamily: 'Roboto',
            letterSpacing: 0.5,
            fontSize: 16.0,
          ),
        ));
  }

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
                    // fontFamily: 'Roboto',
                    letterSpacing: 0.5,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          )
        ]));
  }

  Widget _buildActionBox() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: FlatButton(
                      key: null,
                      onPressed: () => {},
                      color: const Color(0xFFBA5536),
                      child: Text(
                        "Attempt",
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontFamily: "Roboto"),
                      ))),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: FlatButton(
                  key: null,
                  onPressed: () => {},
                  color: const Color(0xFFA43820),
                  child: Text(
                    "Attack",
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontFamily: "Roboto"),
                  )),
            )),
          ],
        ));
  }
}

class ChatMessage {
  ChatMessage({this.userName, this.text, this.profileUrl});
  final String text;
  final String profileUrl;
  final String userName;
}

class ChatMessageListItem extends StatelessWidget {
  ChatMessageListItem(this.message);

  final ChatMessage message;

  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child:
                CircleAvatar(backgroundImage: NetworkImage(message.profileUrl)),
          ),
          Flexible(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.userName,
                  style: Theme.of(context).textTheme.subhead),
              Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(message.text, maxLines: null)),
            ],
          )),
        ],
      ),
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
