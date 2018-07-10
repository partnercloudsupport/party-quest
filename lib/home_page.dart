import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'application.dart';
import 'package:fluro/fluro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  static String tag = 'home-page';

  @override
  createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  CollectionReference get logs => Firestore.instance.collection('Logs');

  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: 'hero',
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            drawer: SettingsDrawer(), // left side
            // endDrawer: CharactersDrawer(), // right side
            appBar: AppBar(
              title: Text('City Quest'),
              elevation: -1.0,
              // leading: IconButton(
              //     icon: Icon(Icons.explore),
              //     onPressed: _scaffoldKey.currentState.openDrawer
              //     ),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.info_outline),
                    tooltip: 'Info about this Quest.',
                    onPressed: _openInfoView)
              ],
            ),
            body: Column(children: <Widget>[
              _buildChatView(),
              Divider(height: 1.0),
              _buildTextComposer()
            ])));
  }

  void _openInfoView() {
    Application.router
        .navigateTo(context, 'info', transition: TransitionType.inFromBottom);
  }

  Widget _buildChatView() {
    return Flexible(
        child: StreamBuilder<QuerySnapshot>(
      stream: logs.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        final int messageCount = snapshot.data.documents.length;
        return new ListView.builder(
          itemCount: messageCount,
          itemBuilder: (_, int index) {
            final DocumentSnapshot document = snapshot.data.documents[index];
            return new ListTile(
              title: new Text(document['message'] ?? '<No message retrieved>'),
              // subtitle: new Text('Message ${index + 1} of $messageCount'),
            );
          },
        );
      },
    )
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

        );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _handleSubmitted,
                decoration:
                    InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? CupertinoButton(
                        child: Text("Send"),
                        onPressed: _isComposing
                            ? () => _handleSubmitted(_textController.text)
                            : null,
                      )
                    : IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _isComposing
                            ? () => _handleSubmitted(_textController.text)
                            : null,
                      )),
          ]),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[200])))
              : null),
    );
  }

  Future<Null> _handleSubmitted(String text) async {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    // await _ensureLoggedIn();

    final DocumentReference document = logs.document();
    document.setData(<String, dynamic>{
      'message': text,
    });
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
                    // fontFamily: 'Roboto',
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

class SettingsDrawer extends StatefulWidget {
  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  User currentUser = User(
      'Augustin Bralley',
      'augman@gmail.com',
      'https://image.freepik.com/iconen-gratis/cartoon-gebouwen_318-41281.jpg',
      'https://img00.deviantart.net/35f0/i/2015/018/2/6/low_poly_landscape__the_river_cut_by_bv_designs-d8eib00.jpg');
  // Quest otherQuest = Quest(
  //     'Fantasy Quest',
  //     'PUYH',
  //     'Cindy, Billy, John',
  //     'https://st.depositphotos.com/2527057/3101/v/450/depositphotos_31012119-stock-illustration-dragon-head-on-white.jpg',
  //     'https://img00.deviantart.net/35f0/i/2015/018/2/6/low_poly_landscape__the_river_cut_by_bv_designs-d8eib00.jpg');

  // void switchAccounts() {
  //   Quest questBackup = currentQuest;
  //   this.setState(() {
  //     currentQuest = otherQuest;
  //     otherQuest = questBackup;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountEmail: Text(currentUser.email),
            accountName: Text(
              currentUser.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontFamily: 'Roboto',
                letterSpacing: 0.5,
                fontSize: 20.0,
              ),
            ),
            currentAccountPicture: GestureDetector(
              child: CircleAvatar(
                backgroundImage: NetworkImage(currentUser.profilePic),
              ),
              onTap: () => print("This is your current account."),
            ),
            onDetailsPressed: () => Navigator.pop(context),
            // otherAccountsPictures: <Widget>[
            //   GestureDetector(
            //     child: CircleAvatar(
            //       backgroundImage: NetworkImage(otherQuest.icon),
            //     ),
            //     onTap: () => switchAccounts(),
            //   ),
            // ],
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(currentUser.background),
                    fit: BoxFit.fill)),
          ),
          ListTile(
              title: Text("My Quests"),
              leading: Icon(Icons.explore),
              onTap: () {
                // Navigator.of(context).pop();
                Application.router.navigateTo(context, 'info',
                    transition: TransitionType.fadeIn);
              }),
          ListTile(
              title: Text("Create Quest"),
              leading: Icon(Icons.create),
              onTap: () {
                Application.router.navigateTo(context, 'newQuest',
                    transition: TransitionType.fadeIn);
              }),
          ListTile(
              title: Text("Join Quest"),
              leading: Icon(Icons.contacts),
              onTap: () {
                Application.router.navigateTo(context, 'joinQuest',
                    transition: TransitionType.fadeIn);
              }),
          Divider(),
          ListTile(
            title: Text("Settings"),
            leading: Icon(Icons.settings),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class Quest {
  final String name;
  final String roomCode;
  final String playerNames;
  final String icon;
  final String background;

  Quest(this.name, this.roomCode, this.playerNames, this.icon, this.background);

  Quest.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        roomCode = json['roomCode'],
        playerNames = json['playerNames'],
        icon = json['icon'],
        background = json['background'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'roomCode': roomCode,
        'playerNames': playerNames,
        'icon': icon,
        'background': background
      };
}

class User {
  final String name;
  final String email;
  final String profilePic;
  final String background;

  User(this.name, this.email, this.profilePic, this.background);

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'],
        profilePic = json['profilePic'],
        background = json['background'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'profilePic': profilePic,
        'background': background
      };
}
