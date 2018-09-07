import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:party_quest/globals.dart' as globals;
// import 'dart:math';

class PickCharacterPage extends StatelessWidget {
	final PageController _pageController = PageController();
	List _characters;

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
					"Pick a Character",
					style:
						TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
				)),
			body: Container(
				decoration: BoxDecoration(
					image: DecorationImage(
						image: AssetImage("assets/images/background-gradient.png"),
						fit: BoxFit.fill)),
				child: Stack(children: <Widget>[_buildPickCharacter(), _buildSelectButton(context)])));
	}
	Widget _buildSelectButton(BuildContext context) {
		return Align(
		alignment: Alignment.bottomCenter, child: Container(
			margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
			child: Padding(
				padding: const EdgeInsets.only(bottom: 50.0),
				child: RaisedButton(
					padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
						color: const Color(0xFF00b0ff),
						shape: new RoundedRectangleBorder(
							borderRadius:
								new BorderRadius.circular(
									10.0)),
						onPressed: () => _selectCharacter(context),
						child: new Text(
							"This one!",
							style: new TextStyle(
								fontSize: 18.0,
								color: Colors.white,
								fontWeight: FontWeight.w800,
							),)))));

		}
	Widget _buildPickCharacter() {
		return StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance
				.collection('Characters')
				.where('genre', isEqualTo: globals.gameState['genre'])
				.snapshots(),
			builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
				if (!snapshot.hasData) return const Text('Loading...');
				final int messageCount = snapshot.data.documents.length;
					_characters = snapshot.data.documents;
				return PageView.builder(
					controller: _pageController,
					scrollDirection: Axis.horizontal,
						pageSnapping: true,
					itemCount: messageCount,
					itemBuilder: (_, int index) {
						return _buildCharacterWidget(context, snapshot.data.documents[index]);
					});
			});
		}

		Widget _buildCharacterWidget(BuildContext context, DocumentSnapshot document) {
			return Container(
				padding: EdgeInsets.all(30.0),
				child: Column(children: <Widget>[ 
					CachedNetworkImage(
					placeholder: CircularProgressIndicator(),
					imageUrl: document['imageUrl'],
					height: 200.0,
					width: 200.0), 
						Text(
					document['name'],
					style: TextStyle(
						color: Colors.white,
						fontSize: 22.0,
						fontWeight: FontWeight.w100)),
				Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Text(
					document['description'],
					style: TextStyle(
						color: Colors.white,
							height: 1.3,
						fontSize: 16.0,
						fontWeight: FontWeight.w200))),
				Row(mainAxisSize: MainAxisSize.min,
					mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
						_buildSkillBoxWidget('Dex', document['dexterity']),
						_buildSkillBoxWidget('Str', document['strength']),
						_buildSkillBoxWidget('Int', document['intelligence']),
						_buildSkillBoxWidget('Cha', document['charisma'])
						]),

							]));
		}

		Widget _buildSkillBoxWidget(String dimension, int value) {
			return Expanded(child: Padding(padding: EdgeInsets.all(10.0), 
				child: Container(
					decoration: BoxDecoration(
					border: Border.all(color: Colors.white)
				),
				child: Padding(padding: EdgeInsets.all(10.0), 
					child: Column( children: <Widget>[Text(value.toString(), style: TextStyle(color: Colors.white, fontSize: 20.0),), Text(dimension, style: TextStyle(color: Colors.white))])))));
		}

	void _selectCharacter(BuildContext context) {
		Navigator.pop(context);
		var _gameId = globals.gameState['id'];
			DocumentSnapshot _selectedCharacter = _characters[_pageController.page.round()];
		// ADD Character to Chat Logs
		final DocumentReference newChat =
			Firestore.instance.collection('Games/$_gameId/Logs').document();
		newChat.setData(<String, dynamic>{
			'text': _selectedCharacter['description'],
      'title': _selectedCharacter['name'],
			'type': 'characterAction',
			'dts': DateTime.now(),
			'profileUrl': _selectedCharacter['imageUrl'],
			'userId': globals.userState['userId']
		});
			// UPDATE Logs.turn
			final DocumentReference gameRef =
				Firestore.instance.collection('Games').document(_gameId);
					gameRef.get().then((gameResult) {
            var characters = gameResult['characters'] == null ? {} : gameResult['characters'];
            characters[globals.userState['userId']] = {
              'characterId': _selectedCharacter.documentID,
			        'characterName': _selectedCharacter['name'],
              'skills': {
                'dexterity': _selectedCharacter['dexterity'],
                'strength': _selectedCharacter['strength'],
                'charisma': _selectedCharacter['charisma'],
                'intelligence': _selectedCharacter['intelligence']
              },
              'imageUrl': _selectedCharacter['imageUrl']
            };
						gameRef.updateData(<String, dynamic>{
							'characters': characters
						});
					});
	}
}
