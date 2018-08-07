// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gratzi_game/globals.dart' as globals;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

class SplashPages extends StatefulWidget {
  @override
  createState() => SplashPagesState();
}

class SplashPagesState extends State<SplashPages> {
  String _downloadUrl =
      "https://firebasestorage.googleapis.com/v0/b/party-quest-dev.appspot.com/o/profilePics%2FPeggIcon.png?alt=media&token=10e49180-d93d-4faa-a3fc-b9872690ec00";
  final TextEditingController _textController = TextEditingController();

  List<Widget> _buildPages() {
    return [_buildLandingPage(context), _buildProfilePage(context)];
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: _buildPages(),
    );
  }

  Widget _buildLandingPage(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage("assets/images/splash_bg.png"),
              fit: BoxFit.cover,
            )),
            child: Container()
            // Center(
            //     child: Text("Gratzi Game",
            //         style: new TextStyle(
            //           color: Colors.white,
            //           fontWeight: FontWeight.w800,
            //           letterSpacing: 0.2,
            //           fontSize: 52.0,
            //         )))
                    
                    ));
  }

  Widget _buildProfilePage(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
            padding: EdgeInsets.only(top: 50.0),
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
                              image: new CachedNetworkImageProvider(
                                  _downloadUrl == null
                                      ? globals.userState['profilePic']
                                      : _downloadUrl))))),
              // Text("More text"),
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
                      hintText: "Enter your name",
                      hintStyle:
                          TextStyle(fontSize: 20.0, color: Colors.white)),
                ),
                decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
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
            ]))));
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
