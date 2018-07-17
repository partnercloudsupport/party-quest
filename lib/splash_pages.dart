// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gratzi_game/globals.dart' as globals;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class SplashPages extends StatefulWidget {
  @override
  createState() => SplashPagesState();
}

class SplashPagesState extends State<SplashPages> {
  String _downloadUrl = "https://i.imgur.com/BoN9kdC.png";
  final TextEditingController _textController = TextEditingController();

  List<Widget> _buildPages() {
    return [
      Scaffold(
          backgroundColor: Colors.black,
          body: Center(
              child: Text("Gratzi Game",
                  style: new TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    fontSize: 52.0,
                  )))),
      Scaffold(
          backgroundColor: Colors.white,
          body: Center(
              child: Column(children: <Widget>[
            Padding(padding: EdgeInsets.all(10.0)),
            GestureDetector(
                onTap: _uploadImage,
                child: Container(
                    width: 190.0,
                    height: 190.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(_downloadUrl))))),
            // Text("More text"),
            Padding(
                padding: EdgeInsets.all(40.0),
                child: TextField(
                  maxLines: null,
                  keyboardType: TextInputType.text,
                  controller: _textController,
                  // onChanged: _handleMessageChanged,
                  onSubmitted: _handleSubmitted,
                  decoration:
                      InputDecoration.collapsed(hintText: "Enter your name"),
                )),
            FlatButton(
                onPressed: () => _handleSubmitted(_textController.text),
                color: const Color(0xFFBA5536),
                child: new Text(
                  "Submit",
                  style: new TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ))
          ])))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: _buildPages(),
    );
  }

  Future<Null> _uploadImage() async {
    var imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 300.0, maxWidth: 300.0);
    var userId = globals.userState['userId'];
    var ref = FirebaseStorage.instance.ref().child('$userId.jpg');
    var uploadTask = ref.put(imageFile);
    var downloadUrl = (await uploadTask.future).downloadUrl;
    setState(() {
      _downloadUrl = downloadUrl.toString();
    });
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    if (text.length > 0) {
      final DocumentReference document = Firestore.instance
          .collection('Users')
          .document(globals.userState['userId']);
      document.setData(<String, dynamic>{
        'name': text,
        'dts': DateTime.now(),
        'profilePic': _downloadUrl
        // 'userId': globals.userState['userId']
      }).then((onValue) {
        globals.userState['name'] = text;
        globals.userState['profilePic'] = _downloadUrl;
      });
    }
  }
}
