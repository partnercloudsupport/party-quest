import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:pegg_party/globals.dart' as globals;
// import 'dart:math';

class PickQuestionPage extends StatelessWidget {
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
					"Pick a Question",
					style:
						TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
				)),
			body: Container(
				decoration: BoxDecoration(
					image: DecorationImage(
						image: AssetImage("assets/images/background-gradient.png"),
						fit: BoxFit.fill)),
				child: _buildPickQuestion()));
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
						var question = document['text'].replaceAllMapped(
							new RegExp(r'\[([^|]+)\|([^\]]+)]'),
							(Match m) => '${m[1]}');
						return GestureDetector(
							child: Container(
								padding: EdgeInsets.all(20.0),
								child: Text(
									question,
									style: TextStyle(
										color: Colors.white,
										fontSize: 20.0,
										fontWeight: FontWeight.w200),
								)),
							onTap: () => _selectQuestion(context, document));
					});
			});
		}

	void _selectQuestion(BuildContext context, DocumentSnapshot document) {
		Navigator.pop(context);
		var _gameId = globals.gameState['id'];
		// ADD Question to Chat Logs
		final DocumentReference newChat =
			Firestore.instance.collection('Games/$_gameId/Logs').document();
		newChat.setData(<String, dynamic>{
			'text': document.data['text'],
			'type': 'question',
			'dts': DateTime.now(),
			'profileUrl': globals.userState['profilePic'],
			'userName': globals.userState['name'],
			'userId': globals.userState['userId']
		});
	}
}
