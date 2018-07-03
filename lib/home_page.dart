import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  static String tag = 'home-page';

  @override
  createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: 'hero',
        child: new Scaffold(
            key: _scaffoldKey,
            drawer: new SettingsDrawer(), // left side
            // endDrawer: new CharactersDrawer(), // right side
            appBar: new AppBar(
              title: new Text('City Quest'),
              // leading: new IconButton(
              //     icon: new Icon(Icons.explore),
              //     onPressed: _scaffoldKey.currentState.openDrawer
              //     ),
              actions: <Widget>[
                new IconButton(
                    icon: new Icon(Icons.info_outline),
                    tooltip: 'Info about this Quest.',
                    onPressed: _openInfoView)
              ],
            ),
            body: new Column(children: <Widget>[
              _buildChatView(),
              new Divider(height: 1.0),
              _buildTextComposer()
            ])));
  }

  void _openInfoView() {
    Navigator.of(context).pushNamed('info-page');
  }

  Widget _buildChatView() {
    return new Flexible(
        child: new ListView(
      reverse: true,
      children: <Widget>[
        _buildActionBox(),
        _buildTurnBox(
            'Slipp the Dogger',
            "Do you attempt something like look around for another exit? Or do you attack someone?",
            "assets/images/hipster-white.jpg"),
        _buildTextBox("What do you do?"),
        _buildTextBox(
            "You and your friends are on your way to an exclusive underground dance party when you get lost. You know you’ve made a mistake when the door of an abandoned factory locks shut behind you, trapping you inside…"),
        _buildTextBox(
            "A disgruntled former employee wants to wreak mechanized terror on those who wronged him."),
        _buildTextBox("In a run-down car factory in Detroit."),
        _buildTitleBox("Chapter One")
      ],
    ));
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _handleSubmitted,
                decoration:
                    new InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoButton(
                        child: new Text("Send"),
                        onPressed: _isComposing
                            ? () => _handleSubmitted(_textController.text)
                            : null,
                      )
                    : new IconButton(
                        icon: new Icon(Icons.send),
                        onPressed: _isComposing
                            ? () => _handleSubmitted(_textController.text)
                            : null,
                      )),
          ]),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
                  border:
                      new Border(top: new BorderSide(color: Colors.grey[200])))
              : null),
    );
  }

  Future<Null> _handleSubmitted(String text) async {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    // await _ensureLoggedIn();
    // _sendMessage(text: text);
  }

  Widget _buildTitleBox(String text) {
    return new Container(
        margin: const EdgeInsets.all(14.0),
        alignment: Alignment.center,
        child: new Text(
          text,
          style: new TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            // fontFamily: 'Roboto',
            letterSpacing: 0.5,
            fontSize: 22.0,
          ),
        ));
  }

  Widget _buildTextBox(String text) {
    return new Container(
        margin: const EdgeInsets.all(10.0),
        child: new Text(
          text,
          style: new TextStyle(
            color: Colors.black,
            // fontWeight: FontWeight.w800,
            // fontFamily: 'Roboto',
            letterSpacing: 0.5,
            fontSize: 16.0,
          ),
        ));
  }

  Widget _buildTurnBox(String title, String subtitle, String image) {
    return new Container(
        margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        color: Colors.black,
        child: new Row(children: <Widget>[
          new Container(
            width: 100.0,
            height: 100.0,
            decoration: new BoxDecoration(
              //  color: Colors.black,
              image: new DecorationImage(
                image: new AssetImage(image),
                // fit: BoxFit.cover,
              ),
            ),
          ),
          new Expanded(
            child: new Column(
              children: <Widget>[
                new Text(
                  title,
                  textAlign: TextAlign.left,
                  style: new TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    // fontFamily: 'Roboto',
                    letterSpacing: 0.5,
                    fontSize: 18.0,
                  ),
                ),
                new Text(
                  subtitle,
                  style: new TextStyle(
                    color: Colors.white,
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
    return new Container(
        margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        color: Colors.black,
        child: new Row(
          children: <Widget>[
            new Expanded(
              child: new Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: new FlatButton(
                      key: null,
                      onPressed: () => {},
                      color: const Color(0xFFBA5536),
                      child: new Text(
                        "Attempt",
                        style: new TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontFamily: "Roboto"),
                      ))),
            ),
            new Expanded(
                child: new Padding(
              padding: const EdgeInsets.all(15.0),
              child: new FlatButton(
                  key: null,
                  onPressed: () => {},
                  color: const Color(0xFFA43820),
                  child: new Text(
                    "Attack",
                    style: new TextStyle(
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
  _SettingsDrawerState createState() => new _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  Quest currentQuest = new Quest(
      'City Quest',
      'XYTP',
      'Joe, Bob, Sue',
      'https://image.freepik.com/iconen-gratis/cartoon-gebouwen_318-41281.jpg',
      'http://www.3drt.com/3dm/levels/urban_set/37-city-night-lights-dawn-3D-level-cityscape-37.jpg');
  Quest otherQuest = new Quest(
      'Fantasy Quest',
      'PUYH',
      'Cindy, Billy, John',
      'https://st.depositphotos.com/2527057/3101/v/450/depositphotos_31012119-stock-illustration-dragon-head-on-white.jpg',
      'https://img00.deviantart.net/35f0/i/2015/018/2/6/low_poly_landscape__the_river_cut_by_bv_designs-d8eib00.jpg');

  void switchAccounts() {
    Quest questBackup = currentQuest;
    this.setState(() {
      currentQuest = otherQuest;
      otherQuest = questBackup;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: new ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountEmail: new Text(currentQuest.playerNames),
            accountName: new Text(
              currentQuest.name,
              style: new TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontFamily: 'Roboto',
                letterSpacing: 0.5,
                fontSize: 20.0,
              ),
            ),
            currentAccountPicture: new GestureDetector(
              child: new CircleAvatar(
                backgroundImage: new NetworkImage(currentQuest.icon),
              ),
              onTap: () => print("This is your current account."),
            ),
            otherAccountsPictures: <Widget>[
              new GestureDetector(
                child: new CircleAvatar(
                  backgroundImage: new NetworkImage(otherQuest.icon),
                ),
                onTap: () => switchAccounts(),
              ),
            ],
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    image: new NetworkImage(currentQuest.background),
                    fit: BoxFit.fill)),
          ),
          new ListTile(
            title: new Text("New Quest"),
            leading: new Icon(Icons.explore),
            // onTap: () {
            //   Navigator.of(context).pop();
            //   Navigator.of(context).push(new MaterialPageRoute(
            //       builder: (BuildContext context) => new Page("First Page")));
            // }
          ),
          new ListTile(
            title: new Text("Invite Friends"),
            leading: new Icon(Icons.contacts),
            // onTap: () {
            //   Navigator.of(context).pop();
            //   Navigator.of(context).push(new MaterialPageRoute(
            //       builder: (BuildContext context) =>
            //           new Page("Second Page")));
            // }
          ),
          new ListTile(
            title: new Text("Settings"),
            leading: new Icon(Icons.settings),
            // onTap: () {
            //   Navigator.of(context).pop();
            //   Navigator.of(context).push(new MaterialPageRoute(
            //       builder: (BuildContext context) =>
            //           new Page("Second Page")));
            // }
          ),
          new Divider(),
          new ListTile(
            title: new Text("Cancel"),
            leading: new Icon(Icons.cancel),
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
