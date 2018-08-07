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
  // final TextEditingController _textController = TextEditingController();
  DocumentSnapshot _selectedQuestion;
  // VideoPlayerController _controller;
  // bool _isPlaying = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _controller = VideoPlayerController.network(
  //     'http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_20mb.mp4',
  //   )
  //     ..addListener(() {
  //       final bool isPlaying = _controller.value.isPlaying;
  //       if (isPlaying != _isPlaying) {
  //         setState(() {
  //           _isPlaying = isPlaying;
  //         });
  //       }
  //     })
  //     ..initialize().then((_) {
  //       // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
  //       setState(() {});
  //     });
  // }

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
            child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 150.0,
                      height: 150.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(100.0)),
                        //  color: Colors.black,
                        image: DecorationImage(
                          image: NetworkImage(globals.userState['profilePic']),
                          // fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(_selectedQuestion['text'],
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w800))),
                    _buildPredefinedAnswers()
                  ],
                )));
  }

  Widget _buildPredefinedAnswers() {
    Map answers = _selectedQuestion.data['answers'];
    List<Widget> answerListTiles = [];
    answers.forEach((key, value) {
      answerListTiles.add(Row(children: <Widget>[
        Expanded(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: RaisedButton(
                    padding: EdgeInsets.all(10.0),
                    onPressed: () => _selectAnswer(context, key, value),
                    color: const Color(0x55FFFFFF),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(5.0)),
                    child: Text(value['text'],
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w200)))))
      ]));
      // child: Text(value['text'], style: TextStyle(color: Colors.white))));
    });
    return Column(children: answerListTiles);
  }

  void _selectAnswer(BuildContext context, String selectedAnswerId, dynamic selectedAnswer) {
    if (selectedAnswer['text'].length > 0) {
      final DocumentReference newAnswer =
          Firestore.instance.collection('Answers').document();
      newAnswer.setData(<String, dynamic>{
        'gameId': globals.gameState['id'],
        'dts': DateTime.now(),
        'question': _selectedQuestion.data,
        'questionId': _selectedQuestion.documentID,
        'correctAnswer': selectedAnswer,
        'userId': globals.userState['userId'],
        'profileUrl': globals.userState['profilePic']
      }).then((onValue) {
        Navigator.pop(context);
        var _gameId = globals.gameState['id'];
        // ADD Question to Chat Logs
        final DocumentReference newChat =
            Firestore.instance.collection('Games/$_gameId/Logs').document();
        newChat.setData(<String, dynamic>{
          'text': _selectedQuestion.data['text'],
          'type': 'question',
          'dts': DateTime.now(),
          'profileUrl': globals.userState['profilePic'],
          'userName': globals.userState['name'],
          'userId': globals.userState['userId']
        });
        // UPDATE Logs.turn
        final DocumentReference turn =
            Firestore.instance.collection('Games').document(_gameId);
        turn.updateData(<String, dynamic>{
          'turn': {
            'question': _selectedQuestion.data['text'],
            'dts': DateTime.now(),
            'answerId': newAnswer.documentID,
            'answerText': selectedAnswer['text'],
            'answerGif': selectedAnswer['gif'],
            'peggeeName': globals.userState['name'],
            'peggeeId': globals.userState['userId'],
            'peggeeProfileUrl': globals.userState['profilePic'],
            'guessers': {}
          }
        });
      });
    }
  }
}

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

// Container(
//   height: 50.0,
//   margin: EdgeInsets.symmetric(horizontal: 20.0),
//   padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
//   child: TextField(
//     maxLines: null,
//     keyboardType: TextInputType.text,
//     controller: _textController,
//     style: TextStyle(fontSize: 20.0, color: Colors.black),
//     // onChanged: _handleMessageChanged,
//     // onSubmitted: () => _handleSubmitted(context, _textController.text),
//     decoration:
//         InputDecoration.collapsed(hintText: 'Type your answer.'),
//   ),
//   decoration: BoxDecoration(
//       color: const Color(0xFFFFFFFF),
//       borderRadius: BorderRadius.circular(8.0)),
// ),
// GestureDetector(
//     child: Container(
//   width: 300.0,
//   height: 200.0,
//   margin: EdgeInsets.symmetric(vertical: 20.0),
//   child: FlatButton(
//       padding:
//           EdgeInsets.symmetric(vertical: 50.0, horizontal: 50.0),
//       onPressed: () => _handleGifPickTap(context),
//       // color: const Color(0x55ffffff),
//       child: new Text(
//         "+ Pick a Gif",
//         style: new TextStyle(
//           fontSize: 35.0,
//           color: Colors.white,
//           fontWeight: FontWeight.w800,
//         ),
//       )),
//   decoration: BoxDecoration(
//       color: const Color(0x55FFFFFF),
//       borderRadius: BorderRadius.circular(8.0)),
// )),
// Container(
//     width: 200.0,
//     margin: EdgeInsets.symmetric(vertical: 10.0),
//     child: FlatButton(
//         padding: EdgeInsets.symmetric(vertical: 10.0),
//         onPressed: () =>
//             _handleSubmitted(context, _textController.text),
//         color: const Color(0xFF00b0ff),
//         child: new Text(
//           "Submit Answer",
//           style: new TextStyle(
//             fontSize: 20.0,
//             color: Colors.white,
//             fontWeight: FontWeight.w800,
//           ),
//         ))),
// GestureDetector(
//     child: Center(
//       child: _controller.value.initialized
//           ? AspectRatio(
//               aspectRatio: _controller.value.aspectRatio,
//               child: VideoPlayer(_controller),
//             )
//           : Container(),
//     ),
//     onTap: _controller.value.isPlaying
//         ? _controller.pause
//         : _controller.play),
// Container(
//     padding: EdgeInsets.all(20.0),
//     child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text("Or pick a answer:",
//               style: TextStyle(
//                   color: Colors.white70, fontSize: 14.0))
//         ])),
