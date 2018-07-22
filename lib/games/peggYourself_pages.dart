import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:gratzi_game/globals.dart' as globals;
// import 'dart:math';

class PeggYourselfPages extends StatefulWidget {
  @override
  createState() => PeggYourselfPagesState();
}

class PeggYourselfPagesState extends State<PeggYourselfPages> {
  final PageController _pageController = PageController();
  final TextEditingController _textController = TextEditingController();
  DocumentSnapshot _selectedQuestion;
  // bool _isPublic;

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
              "Pegg Yourself",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            )),
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/background-gradient.png"),
                    fit: BoxFit.fill)),
            child: PageView(
              children: [_buildPickQuestion(), _buildPickAnswer(context)],
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
            )));
  }

  Widget _buildPickQuestion() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('Questions')
            .where('category', isEqualTo: globals.gameState['category'])
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          final int messageCount = snapshot.data.documents.length;
          return ListView.builder(
              itemCount: messageCount,
              itemBuilder: (_, int index) {
                final DocumentSnapshot document =
                    snapshot.data.documents[index];
                return GestureDetector(
                    child: Container(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          document['text'],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w200),
                        )),
                    onTap: () => _selectQuestion(document));
              });
        });
  }

  void _selectQuestion(DocumentSnapshot document) {
    setState(() {
      _selectedQuestion = document;
    });
    _pageController.animateToPage(1,
        duration: Duration(milliseconds: 1000), curve: Curves.elasticOut);
  }

  Widget _buildPickAnswer(BuildContext context) {
    return _selectedQuestion == null
            ? Container()
            : Container(
                child: Column(
                children: <Widget>[
                  Text(_selectedQuestion['text'],
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w200)),
                  Container(
                    height: 50.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                    child: TextField(
                      maxLines: null,
                      keyboardType: TextInputType.text,
                      controller: _textController,
                      style: TextStyle(fontSize: 20.0, color: Colors.black),
                      // onChanged: _handleMessageChanged,
                      // onSubmitted: () => _handleSubmitted(context, _textController.text),
                      decoration: InputDecoration.collapsed(
                          hintText: 'Type your answer.'),
                    ),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                  Container(
                      width: 200.0,
                      child: FlatButton(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          onPressed: () =>
                              _handleSubmitted(context, _textController.text),
                          color: const Color(0xFF00b0ff),
                          child: new Text(
                            "Submit Answer",
                            style: new TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          )))
                ],
              ))

        // TODO: let users pick from their friends answers too.
        // StreamBuilder<QuerySnapshot>(
        //     stream: Firestore.instance
        //         .collection('Answers')
        //         .where('questionId', isEqualTo: _selectedQuestion.documentID)
        //         .where('gameId', isEqualTo: globals.gameState['id'])
        //         .snapshots(),
        //     builder:
        //         (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        //       if (!snapshot.hasData) return const Text('Loading...');
        //       final int messageCount = snapshot.data.documents.length;
        //       return ListView.builder(
        //           itemCount: messageCount,
        //           itemBuilder: (_, int index) {
        //             final DocumentSnapshot document =
        //                 snapshot.data.documents[index];
        //             return GestureDetector(
        //                 child: Container(
        //                     padding: EdgeInsets.all(20.0),
        //                     child: Text(
        //                   document['text'],
        //                   style: TextStyle(
        //                       color: Colors.white,
        //                       fontSize: 20.0,
        //                       fontWeight: FontWeight.w200),
        //                 )),
        //                 onTap: () => _selectQuestion(document));
        //           });
        //     });
        ;
  }

  void _handleSubmitted(BuildContext context, String text) {
    _textController.clear();
    if (text.length > 0) {
      final DocumentReference document =
          Firestore.instance.collection('Answers').document();
      document.setData(<String, dynamic>{
        'gameId': globals.gameState['id'],
        'dts': DateTime.now(),
        'gifUrl': '',
        'question': _selectedQuestion['text'],
        'text': text,
        'userId': globals.userState['userId']
      }).then((onValue) {
        Navigator.pop(context);
        // globals.userState['name'] = text;
        // globals.userState['profilePic'] = _downloadUrl;
      });
    }
  }
}
