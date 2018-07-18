import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:gratzi_game/globals.dart' as globals;
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'dart:async';

class CreateGamePages extends StatefulWidget {
  @override
  createState() => CreateGamePagesState();
}

class CreateGamePagesState extends State<CreateGamePages> {
  // final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: _buildPages(),
    );
  }

  List<Widget> _buildPages() {
    return [
      Scaffold(
          appBar: new AppBar(
              backgroundColor: const Color(0xFF00073F),
              elevation: -1.0,
              title: new Text(
                "Pick a Category",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              )),
          // backgroundColor: Colors.black,
          body: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image:
                          AssetImage("assets/images/background-gradient.png"),
                      fit: BoxFit.fill)),
              child: _buildCategories())),
    ];
  }

  Widget _buildCategories() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('Categories').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        final int messageCount = snapshot.data.documents.length;
        return ListView.builder(
          itemCount: messageCount,
          itemBuilder: (_, int index) {
            final DocumentSnapshot document = snapshot.data.documents[index];
            return new Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 24.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                        height: 124.0,
                        width: 300.0,
                        margin: EdgeInsets.only(left: 46.0),
                        padding: EdgeInsets.only(top: 20.0, left: 65.0, right: 20.0),
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
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                          Text(document['name'] != null
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
                      child: Image(
                        image: NetworkImage(document['imageUrl']),
                        height: 92.0,
                        width: 92.0,
                      ),
                    ),
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
                ));
          },
        );
      },
    );
  }
}
