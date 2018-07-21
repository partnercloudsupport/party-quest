import 'package:flutter/material.dart';
import 'package:gratzi_game/globals.dart' as globals;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class UserProfilePage extends StatefulWidget {
  @override
  UserProfileState createState() => new UserProfileState();
}

class UserProfileState extends State<UserProfilePage> {
  String _downloadUrl; // = "https://i.imgur.com/BoN9kdC.png";
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // controller?.dispose();
    super.dispose();
  }

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
        title: new Text("Edit Profile",
            style: new TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              fontSize: 22.0,
            )),
      ),
      body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/background-gradient.png"),
                  fit: BoxFit.fill)),
          child: Center(
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
                            image: new NetworkImage(_downloadUrl == null ? globals.userState['profilePic'] : _downloadUrl))))),
            // Text("More text"),
            Container(
              height: 50.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
              child: TextField(
                maxLines: null,
                keyboardType: TextInputType.text,
                controller: _textController,
                style: TextStyle(fontSize: 20.0, color: Colors.black),
                // onChanged: _handleMessageChanged,
                onSubmitted: _handleSubmitted,
                decoration:
                    InputDecoration.collapsed(hintText: globals.userState['name']),
              ),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(8.0)),
            ),
            FlatButton(
                onPressed: () => _handleSubmitted(_textController.text),
                color: const Color(0xFF00b0ff),
                child: new Text(
                  "Submit",
                  style: new TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ))
          ]))),
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

  // Widget _buildCameraView() {
  //   return Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Text(
  //         globals.userState['name'],
  //         style: const TextStyle(
  //           color: Colors.black,
  //           fontSize: 20.0,
  //           fontWeight: FontWeight.w700,
  //         ),
  //       ));
  // }
}
