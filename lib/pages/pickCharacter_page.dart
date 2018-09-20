import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/characterAnimation.dart';
import 'package:party_quest/globals.dart' as globals;
// import 'dart:math';

class PickCharacterPage extends StatefulWidget {
	@override
	createState() => PickCharacterState();
}

class PickCharacterState extends State<PickCharacterPage> {
	PageController _characterController = PageController();
	PageController _pageController = PageController();
	TextEditingController _textControllerName = TextEditingController();
	TextEditingController _textControllerIntro = TextEditingController();
  DocumentSnapshot _selectedCharacter;
	List _characters;
  bool _buttonEnabled = false;

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
				child: PageView(
					children: [_buildClassSelectorPage(context), _buildCharacterDetailsPage(context)],
					physics: NeverScrollableScrollPhysics(),
					controller: _pageController,
				)));
	}

  Widget _buildCharacterDetailsPage(BuildContext context){
    return ListView(children: <Widget>[
      _selectedCharacter == null ? Container(width: 10.0) : Image(height: 100.0,
						image: AssetImage("assets/images/" + _selectedCharacter.documentID + ".png")),
      Container(
					height: 60.0,
					margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
					padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
					child: TextField(
						maxLines: null,
						autofocus: false,
						maxLength: 15,
						style: TextStyle(fontSize: 20.0, color: Colors.white, fontFamily: 'LondrinaSolid'),
						keyboardType: TextInputType.text,
						controller: _textControllerName,
						onChanged: _handleTextChange,
						// onSubmitted: _handleSubmitted,
						decoration: InputDecoration.collapsed(
							hintText: "Give your character a name...",
							hintStyle: TextStyle(fontSize: 20.0, color: const Color(0x99FFFFFF))),
					),
					decoration: BoxDecoration(
						color: const Color(0x33FFFFFF),
						borderRadius: BorderRadius.circular(8.0)),
				),
      Container(
				height: 100.0,
				margin: EdgeInsets.symmetric(horizontal: 20.0),
				padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
				child: TextField(
					maxLines: null,
					keyboardType: TextInputType.text,
					controller: _textControllerIntro,
          onChanged: _handleTextChange,
					style: TextStyle(color: Colors.white, fontSize: 18.0, fontFamily: 'LondrinaSolid'),
					decoration:
						InputDecoration.collapsed(hintText: 'Introduce your character (in 3rd person)...', hintStyle: TextStyle(color: const Color(0x99FFFFFF))),
				),
				decoration: BoxDecoration(
					color: const Color(0x33FFFFFF),
					borderRadius: BorderRadius.circular(8.0)),
			),
      _buildSubmitButton(context)
    ],);
  }

  Widget _buildSubmitButton(BuildContext context){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
            color: const Color(0xFF00b0ff),
            shape: new RoundedRectangleBorder(
              borderRadius:
                new BorderRadius.circular(
                  10.0)),
            onPressed: _buttonEnabled ? () => _handleCharacterSubmit(context) : null,
            child: new Text(
              "Join the party!",
              style: new TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              )))));
      }

  void _handleTextChange(String text){
    if(_textControllerName.text.length > 0 && _textControllerIntro.text.length > 0){
      // enable submit button
      setState((){
        _buttonEnabled = true;
      });
    } else {
      setState((){
        _buttonEnabled = false;
      });
    }
  }

  Widget _buildClassSelectorPage(BuildContext context){
    return Stack(children: <Widget>[_buildPickCharacter(), _buildSelectButton(context)]);
  }

	Widget _buildSelectButton(BuildContext context) {
		return Align(
		alignment: Alignment.bottomCenter, child: Container(
			margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
			child: Padding(
				padding: const EdgeInsets.only(bottom: 5.0),
				child: RaisedButton(
					padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
						color: const Color(0xFF00b0ff),
						shape: new RoundedRectangleBorder(
							borderRadius:
								new BorderRadius.circular(
									10.0)),
						onPressed: () => _selectCharacter(),
						child: new Text(
							"I pick this one.",
							style: new TextStyle(
								fontSize: 20.0,
								color: Colors.white,
								fontWeight: FontWeight.w800,
							),)))));

		}

  void _selectCharacter(){
    _pageController.animateToPage(1, duration: Duration(milliseconds: 1000), curve: Curves.elasticOut);
   setState(() {
      _selectedCharacter = _characters[_characterController.page.round()];
    }); 
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
					controller: _characterController,
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
				padding: EdgeInsets.symmetric(horizontal: 20.0),
				child: Column(children: <Widget>[ 
				Container(height: 350.0, child: CharacterAnimation(document['characterFileName'], document['spriteX'], document['spriteY'], document['spriteCount'])), 
				Text(
					document['name'],
          // textAlign: TextAlign.right,
					style: TextStyle(
						color: Colors.white,
						fontSize: 24.0,
						fontWeight: FontWeight.w800)),
				Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Text(
					document['description'],
					style: TextStyle(
						color: Colors.white,
							height: 1.3,
						fontSize: 20.0,
						fontWeight: FontWeight.w400))),
				Row(mainAxisSize: MainAxisSize.min,
					mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
						_buildSkillBoxWidget('Dexterity', document['dexterity']),
						_buildSkillBoxWidget('Strength', document['strength']),
						_buildSkillBoxWidget('Intelligence', document['intelligence']),
						_buildSkillBoxWidget('Charisma', document['charisma'])
						]),

							]));
		}

		Widget _buildSkillBoxWidget(String dimension, int value) {
			return Expanded(
				child: Container(
				child: Padding(padding: EdgeInsets.all(0.0), 
					child: Column( children: <Widget>[
            Text((value > 0 ? '+' : '') + value.toString(), style: TextStyle(color: Colors.white, fontSize: 30.0)), 
            Text(dimension, style: TextStyle(color: Colors.white)
          )]
        ))));
		}

	void _handleCharacterSubmit(BuildContext context) {
		Navigator.pop(context);
		var _gameId = globals.gameState['id'];
    // ADD Narration to Chat Logs
		final DocumentReference newNarration = Firestore.instance.collection('Games/$_gameId/Logs').document();
		newNarration.setData(<String, dynamic>{
			'text': 'A ' + _selectedCharacter['name'] + ' joins the party.' + '\\n' + _textControllerIntro.text, // + _selectedCharacter['description']
			'type': 'narration',
			'dts': DateTime.now(),
			'userId': globals.userState['userId'],
      'titleImageUrl': _selectedCharacter['imageUrl'],
      'title': _textControllerName.text,
			'userName': globals.userState['name']
		});
		// ADD Character to Chat Logs
		// final DocumentReference newChat = Firestore.instance.collection('Games/$_gameId/Logs').document();
		// newChat.setData(<String, dynamic>{
		// 	'text': _textControllerIntro.text,
    //   'title': _textControllerName.text,
		// 	'type': 'characterAction',
		// 	'dts': DateTime.now(),
		// 	'profileUrl': _selectedCharacter['imageUrl'],
		// 	'userId': globals.userState['userId']
		// });
    // UPDATE Logs.turn
    final DocumentReference gameRef =
      Firestore.instance.collection('Games').document(_gameId);
        gameRef.get().then((gameResult) {
          var characters = gameResult['characters'] == null ? {} : gameResult['characters'];
          characters[globals.userState['userId']] = {
            'characterId': _selectedCharacter.documentID,
            'characterName': _textControllerName.text,
            'HP': 20,
            'XP': 0,
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
