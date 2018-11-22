import 'package:flutter/material.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

class UserProfilePage extends StatefulWidget {
	@override
	UserProfileState createState() => new UserProfileState();
}

class UserProfileState extends State<UserProfilePage> {
	String _downloadUrl, _profilePic, _userName, _userIntro;
	final TextEditingController _nameController = TextEditingController();
	final TextEditingController _introController = TextEditingController();
  bool _buttonEnabled = false;

	@override
	void initState() {
		super.initState();
		_profilePic = globals.currentUser.data['profilePic'];
    _userName = globals.currentUser.data['name'];
    _userIntro = globals.currentUser.data['intro'];
    if(globals.currentUser.data['name'] != '') _nameController.text = globals.currentUser.data['name'];
    if(globals.currentUser.data['intro'] != '') _introController.text = globals.currentUser.data['intro'];
  }

	@override
	void dispose() {
		_nameController.dispose();
		_introController.dispose();
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
				title: new Text("Who are you?",
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
				child: ListView(children: <Widget>[
					Padding(padding: EdgeInsets.all(10.0)),
					_buildProfilePic(),
					_buildPhotoButtons(),
					_buildNameField(),
          _buildIntroField(),
					_buildDoneButton()])),
		);
	}


  Widget _buildProfilePic(){
    var profileUrl = _downloadUrl == null ? _profilePic : _downloadUrl;
    return Column(children: <Widget>[ Container(
      width: 190.0,
      height: 190.0,
        margin: const EdgeInsets.only(top: 0.0, bottom: 10.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: profileUrl.contains('http') ? CachedNetworkImageProvider(profileUrl) : AssetImage(profileUrl)
      )))]);
  }

  Widget _buildNameField(){
    return Container(height: 50.0,
      margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
      child: TextField(
        maxLines: null,
        keyboardType: TextInputType.text,
        controller: _nameController,
        style: TextStyle(fontSize: 20.0, color: Colors.white, fontFamily: 'LondrinaSolid'),
        // onChanged: _handleMessageChanged,
        onChanged: _handleTextFieldChange,
        // onSubmitted: _handleSubmitted,
        decoration: InputDecoration.collapsed(
          hintStyle: TextStyle(fontSize: 20.0, color: const Color(0x99FFFFFF)),
          hintText: globals.currentUser.data['name'] == ''
            ? "Enter your name."
            : globals.currentUser.data['name']),
      ),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(25.0)),
    );
  }


  Widget _buildIntroField(){
    return Container(height: 150.0,
      margin: EdgeInsets.only(bottom: 20.0, right: 20.0, left: 20.0),
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      child: TextField(
        maxLines: 5,
        maxLength: 200,
        keyboardType: TextInputType.text,
        controller: _introController,
        style: TextStyle(fontSize: 20.0, color: Colors.white, fontFamily: 'LondrinaSolid'),
        // onChanged: _handleMessageChanged,
        onChanged: _handleTextFieldChange,
        // onSubmitted: _handleSubmitted,
        decoration: InputDecoration.collapsed(
          hintStyle: TextStyle(fontSize: 20.0, color: const Color(0x99FFFFFF)),
          hintText: globals.currentUser.data['intro'] == null
            ? "Tell us something about you."
            : globals.currentUser.data['intro']),
      ),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(25.0)),
    );
  }

  Widget _buildDoneButton(){
    return Padding(padding: EdgeInsets.symmetric(horizontal: 40.0), child: RaisedButton(
    onPressed: _buttonEnabled ? _handleSubmitted : null,
    color: Theme.of(context).buttonColor,
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(40.0)),
    child: Text(
      "Done",
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.white,
        fontWeight: FontWeight.w800
        ),
    )));
  }

  Widget _buildPhotoButtons(){
    return Row(children: <Widget>[ Expanded(child: Padding(padding: EdgeInsets.only(left: 20.0, right: 10.0, top: 10.0),
      child: RaisedButton.icon(
      onPressed: () => _uploadImage('pick'),
      color: Theme.of(context).buttonColor,
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(40.0)),
          icon: Icon(Icons.photo_album, color: Colors.white),
          label: Text(
        "Choose",
        style: TextStyle(
          fontSize: 20.0,
          color: Colors.white,
          fontWeight: FontWeight.w800
        ))
          ))),
          Expanded(child: Padding(padding: EdgeInsets.only(right: 20.0, left: 10.0, top: 10.0), child: RaisedButton.icon(
            elevation: 4.0,
            highlightElevation: 50.0,
            // padding: EdgeInsets.all(10.0),
            // onPressed: null,
            onPressed: () => _uploadImage('take'),
            color: Theme.of(context).buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(40.0)),
                icon: Icon(Icons.camera_alt, color: Colors.white),
            label: Text(
              "Take",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.w800,
        )))))]);
  }

	Future<Null> _uploadImage(String type) async {
		var imageFile;
		if(type == 'take'){
		  imageFile = await ImagePicker.pickImage(
		    source: ImageSource.camera, maxHeight: 300.0, maxWidth: 300.0);
		} else {
			imageFile = await ImagePicker.pickImage(
		    source: ImageSource.gallery, maxHeight: 300.0, maxWidth: 300.0);
			}
		if(imageFile != null){
      var userId = globals.currentUser.documentID;
      var ref = FirebaseStorage.instance.ref().child('profilePics/$userId.jpg');
      var uploadTask = ref.putFile(imageFile);
      var downloadUrl = (await uploadTask.future).downloadUrl;
      setState(() {
        _downloadUrl = downloadUrl.toString();
      });
		}
	}

  void _handleTextFieldChange(String text){
    if(_nameController.text != _userName || _introController.text != _userIntro){
      setState((){
        _buttonEnabled = true;
      });
    } else {
      setState((){
        _buttonEnabled = false;
      });
    }
  }

	void _handleSubmitted() {
    globals.currentUser.data['name'] = _nameController.text;
    globals.currentUser.data['intro'] = _introController.text;
    if (_downloadUrl != null) globals.currentUser.data['profilePic'] = _downloadUrl;
    globals.currentUser.reference.updateData(globals.currentUser.data);
    Navigator.pop(context);
	}
}
