import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pegg_party/globals.dart' as globals;
import 'dart:math';
import 'dart:convert';

class CreateGamePages extends StatefulWidget {
  @override
  createState() => CreateGamePagesState();
}

class CreateGamePagesState extends State<CreateGamePages> {
  final PageController _pageController = PageController();
  final TextEditingController _textController = TextEditingController();
  DocumentSnapshot _selectedCategory;
  bool _isPublic;

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
              "Create a Game",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            )),
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/background-gradient.png"),
                    fit: BoxFit.fill)),
            child: PageView(
              children: [_buildCategories(), _buildDetailsForm()],
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
            )));
  }

  Widget _buildDetailsForm() {
    return _selectedCategory == null
        ? Container()
        : Center(
            child: Column(children: <Widget>[
            Padding(padding: EdgeInsets.all(10.0)),
            GestureDetector(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 6.0),
                  alignment: FractionalOffset.center,
                  child: _selectedCategory['imageUrl'] != null
                      ? CachedNetworkImage(
                          placeholder: CircularProgressIndicator(),
                          imageUrl: _selectedCategory['imageUrl'],
                          height: 100.0,
                          width: 100.0,
                        )
                      : Container(),
                ),
                onTap: _previousPage),
            Text(
              _selectedCategory['name'],
              style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w800),
            ),
            Container(
              height: 50.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
              child: TextField(
                maxLines: null,
                autofocus: true,
                maxLength: 20,
                style: TextStyle(fontSize: 20.0, color: Colors.white),
                keyboardType: TextInputType.text,
                controller: _textController,
                // onChanged: _handleMessageChanged,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration.collapsed(
                    hintText: "Give your game a title...",
                    hintStyle: TextStyle(fontSize: 20.0, color: Colors.white)),
              ),
              decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(8.0)),
            ),
            Container(
                child: Row(children: <Widget>[
              Expanded(
                  child: Text(
                'Private',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.white),
              )),
              Switch(
                value: false,
                inactiveTrackColor: Colors.white70,
                onChanged: _toggleIsPublic,
              ),
              Expanded(
                  child: Text('Public', style: TextStyle(color: Colors.white)))
            ])),
            Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: new FlatButton(
                    key: null,
                    onPressed: () => _handleSubmitted(_textController.text),
                    color: const Color(0xFF00b0ff),
                    child: new Text(
                      "Let's Play!",
                      style: new TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    )))
          ]));
  }

  void _toggleIsPublic(bool isPublic) {
    _isPublic = isPublic;
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    var userId = globals.userState['userId'];
    var code = _generateRandomCode(5);
    //CREATE Game
    final DocumentReference game =
        Firestore.instance.collection('Games').document();
    game.setData(<String, dynamic>{
      'category': _selectedCategory.documentID,
      'name': _selectedCategory['name'],
      'title': text,
      'imageUrl': _selectedCategory['imageUrl'],
      'code': code,
      'creator': userId,
      'players': {userId: true},
      'isPublic': _isPublic,
      'dts': DateTime.now(),
      'turn': {'dts': DateTime.now()}
    });

    //UPDATE User.games
    var userRef = Firestore.instance
        .collection('Users')
        .document(globals.userState['userId']);
    userRef.get().then((snapshot) {
      Map userGames =
          snapshot.data['games'] == null ? new Map() : snapshot.data['games'];
      userGames[game.documentID] = true;
      userRef.updateData(<String, dynamic>{
        'games': userGames,
      }).then((value) {
        globals.gameState['id'] = game.documentID;
        globals.gameState['category'] = _selectedCategory.documentID;
        globals.gameState['name'] = _selectedCategory['name'];
        globals.gameState['title'] = text;
        // globals.gameState['isPublic'] = _isPublic;
        Navigator.pop(context);
        globals.gameState['code'] = code;
        globals.gameState['creator'] = userId;
        globals.gameState['players'] = json.encode({userId: true});
      });
    });
  }

  /// Generates a random string of [length] with characters
  /// between ascii 65 to 90 (uppercase letters).
  String _generateRandomCode(int length) {
    return new String.fromCharCodes(
        new List.generate(length, (index) => randomBetween(65, 90)));
  }

  /// Generates a random integer where [from] <= [to].
  int randomBetween(int from, int to) {
    if (from > to) throw new Exception('$from cannot be > $to');
    var rand = new Random();
    return ((to - from) * rand.nextDouble()).toInt() + from;
  }

  Widget _buildCategories() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('Categories')
          .orderBy('type')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        final int messageCount = snapshot.data.documents.length;
        return ListView.builder(
          itemCount: messageCount,
          itemBuilder: (_, int index) {
            final DocumentSnapshot document = snapshot.data.documents[index];
            return GestureDetector(
              child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0),
                  child: Stack(
                    children: <Widget>[
                      Container(
                          height: 124.0,
                          width: 300.0,
                          margin: EdgeInsets.only(left: 46.0),
                          padding: EdgeInsets.only(
                              top: 20.0, left: 65.0, right: 20.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF333366),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10.0,
                                offset: Offset(0.0, 10.0),
                              ),
                            ],
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    document['name'] != null
                                        ? document['name']
                                        : 'no name.',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 24.0)),
                                Text(
                                    document['description'] != null
                                        ? document['description']
                                        : 'no description.',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w100,
                                        fontSize: 16.0)),
                              ])),
                      Container(
                          margin: EdgeInsets.symmetric(vertical: 16.0),
                          alignment: FractionalOffset.centerLeft,
                          child: Stack(children: <Widget>[
                            CachedNetworkImage(
                              placeholder: CircularProgressIndicator(),
                              imageUrl: document['imageUrl'],
                              height: 92.0,
                              width: 92.0,
                            ),
                            document['type'] == 'paid'
                                ? Positioned(
                                    top: 30.0,
                                    child: RaisedButton(
                                        padding: EdgeInsets.all(2.0),
                                        shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(
                                                    10.0)),
                                        onPressed: () => _nextPage(document),
                                        color: const Color(0xFF48B5FB),
                                        child: Text(
                                            "\$1.99",
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w800,
                                            ))))
                                : Container(width: 0.0)
                            // Text(
                            //           '\$1.99',
                            //           textAlign: TextAlign.left,
                            //           style: TextStyle(
                            //               color: Colors.white70,
                            //               fontWeight: FontWeight.w100,
                            //               fontSize: 16.0)) : Container(width: 0.0)
                          ])),
                      // WIP: cant figure this out... circle not positioning correctly.
                      // Positioned(
                      //     left: 100.0,
                      //     top: 0.0,
                      //     child: Container(
                      //         // margin: EdgeInsets.symmetric(vertical: 16.0),
                      //         // alignment: FractionalOffset.centerLeft,
                      //         height: 124.0,
                      //         // margin: EdgeInsets.symmetric(vertical: 16.0),
                      //         // alignment: FractionalOffset.centerLeft,
                      //         decoration: BoxDecoration(
                      //           color: Color(0xFFFFFFFF),
                      //           shape: BoxShape.circle,
                      //           // borderRadius: BorderRadius.circular(8.0)
                      //         ))),
                    ],
                  )),
              onTap: () => _nextPage(document),
            );
          },
        );
      },
    );
  }

  void _previousPage() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 1000), curve: Curves.elasticOut);
  }

  void _nextPage(DocumentSnapshot document) {
    if (document['type'] == 'free') {
      setState(() {
        _selectedCategory = document;
      });
      _pageController.animateToPage(1,
          duration: Duration(milliseconds: 1000), curve: Curves.elasticOut);
    }
  }
}
