import 'package:flutter/material.dart';
import 'package:pegg_party/globals.dart' as globals;
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
	String _downloadUrl, _profilePic;
	final TextEditingController _textController = TextEditingController();

	@override
	void initState() {
		super.initState();
		_profilePic = globals.userState['loginStatus'] == 'loggedIn' ? globals.userState['profilePic'] : "https://firebasestorage.googleapis.com/v0/b/party-quest-dev.appspot.com/o/profile-placeholder.png?alt=media&token=35a5323c-0b10-4332-a8c2-355d26e950a8";
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
								_buildDoneButton()])),
		);
	}


		Widget _buildProfilePic(){
			return Column(children: <Widget>[ Container(
				width: 190.0,
				height: 190.0,
					margin: const EdgeInsets.only(top: 0.0, bottom: 10.0),
				decoration: BoxDecoration(
					shape: BoxShape.circle,
					image: DecorationImage(
						fit: BoxFit.cover,
						image: CachedNetworkImageProvider(
							_downloadUrl == null
								? _profilePic
								: _downloadUrl))))]);
		}

			Widget _buildNameField(){
				return Container(
			height: 50.0,
			margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
			padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
			child: TextField(
				maxLines: null,
				keyboardType: TextInputType.text,
				controller: _textController,
				style: TextStyle(fontSize: 20.0, color: Colors.white),
				// onChanged: _handleMessageChanged,
				onSubmitted: _handleSubmitted,
				decoration: InputDecoration.collapsed(
					hintStyle: TextStyle(fontSize: 20.0, color: Colors.white),
					hintText: globals.userState['name'] == ''
						? "Enter your name."
						: globals.userState['name']),
			),
			decoration: BoxDecoration(
				color: const Color(0x33FFFFFF),
				borderRadius: BorderRadius.circular(40.0)),
		);
			}

		Widget _buildDoneButton(){
			return Padding(padding: EdgeInsets.symmetric(horizontal: 40.0), child: RaisedButton(
			onPressed: () => _handleSubmitted(_textController.text),
			color: const Color(0xFF00b0ff),
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
				color: const Color(0xFF00b0ff),
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
							color: const Color(0xFF00b0ff),
							shape: RoundedRectangleBorder(
								borderRadius: new BorderRadius.circular(40.0)),
									icon: Icon(Icons.camera_alt, color: Colors.white),
							label: Text(
								"Take",
								style: TextStyle(
									fontSize: 20.0,
									color: Colors.white,
									fontWeight: FontWeight.w800,
								)))
								))
							]);
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
		var userId = globals.userState['userId'];
		var ref = FirebaseStorage.instance.ref().child('profilePics/$userId.jpg');
		var uploadTask = ref.putFile(imageFile);
		var downloadUrl = (await uploadTask.future).downloadUrl;
		setState(() {
			_downloadUrl = downloadUrl.toString();
		});

			}
	}

	void _handleSubmitted(String text) {
		_textController.clear();
		if (text.length > 0) {
			final DocumentReference userRef = Firestore.instance
				.collection('Users')
				.document(globals.userState['userId']);
			userRef.get().then((userResult) {
				if(userResult.data != null){
				userResult.data['name'] = text;
					if (_downloadUrl.length > 0)
						userResult.data['profilePic'] = _downloadUrl;
					userRef.updateData(userResult.data).then((onValue) {
						globals.userState['name'] = text;
						if (_downloadUrl.length > 0)
							globals.userState['profilePic'] = _downloadUrl;
								Navigator.pop(context);

					});
				} else {
					userRef.setData(<String, dynamic>{
					'name': text,
					'profilePic': _downloadUrl
				}).then((onValue) {
					globals.userState['name'] = text;
					if (_downloadUrl.length > 0)
						globals.userState['profilePic'] = _downloadUrl;
							});
					}
						Navigator.pop(context);


			});
		}
	}
}
