import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:party_quest/globals.dart' as globals;
import 'dart:math';
import 'dart:convert';

class CreateGamePages extends StatefulWidget {
	@override
	createState() => CreateGamePagesState();
}

class CreateGamePagesState extends State<CreateGamePages> {
	final PageController _pageController = PageController();
	final TextEditingController _textController = TextEditingController();
	DocumentSnapshot _selectedGenre;
	bool _isPublic;

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
					"Create a Game",
					style:
						TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
				)),
			body: Container(
				decoration: BoxDecoration(
					image: DecorationImage(
						image: AssetImage("assets/images/background-gradient.png"),
						fit: BoxFit.fill)),
				child: PageView(
					children: [_buildCategories(), _buildDetailsForm()],
					physics: NeverScrollableScrollPhysics(),
					controller: _pageController,
				)));
	}

	Widget _buildDetailsForm() {
		return _selectedGenre == null
			? Container()
			: Center(
				child: ListView(children: <Widget>[
				Padding(padding: EdgeInsets.all(10.0)),
				GestureDetector(
					child: Container(
						margin: EdgeInsets.symmetric(vertical: 6.0),
						alignment: FractionalOffset.center,
						child: _selectedGenre['imageUrl'] != null
							? CachedNetworkImage(
								placeholder: CircularProgressIndicator(),
								imageUrl: _selectedGenre['imageUrl'],
								height: 100.0,
								width: 100.0,
								)
							: Container(),
					),
					onTap: _previousPage),
				Center(
					// margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
					child: Text(
					_selectedGenre['name'],
					style: TextStyle(
						fontSize: 22.0,
						color: Colors.white,
						fontWeight: FontWeight.w800),
				)),
				Container(
					height: 60.0,
					margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
					padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
					child: TextField(
						maxLines: null,
						autofocus: false,
						maxLength: 20,
						style: TextStyle(fontSize: 20.0, color: Colors.white, fontFamily: 'LondrinaSolid'),
						keyboardType: TextInputType.text,
						controller: _textController,
						// onChanged: _handleMessageChanged,
						onSubmitted: _handleSubmitted,
						decoration: InputDecoration.collapsed(
							hintText: "Give your game a title...",
							hintStyle: TextStyle(fontSize: 20.0, color: Colors.white)),
					),
					decoration: BoxDecoration(
						color: const Color(0x33FFFFFF),
						borderRadius: BorderRadius.circular(8.0)),
				),
				Container(
					margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
					child: Row(children: <Widget>[
					Expanded(
						child: Text(
						'Private',
						textAlign: TextAlign.right,
						style: TextStyle(color: Colors.white),
					)),
					Switch(
						value: false,
						inactiveTrackColor: Colors.white70,
						onChanged: _toggleIsPublic,
					),
					Expanded(
						child: Text('Public', style: TextStyle(color: Colors.white)))
				])),
				Container(
					margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
					child: RaisedButton(
							padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
								color: const Color(0xFF00b0ff),
								shape: new RoundedRectangleBorder(
									borderRadius:
										new BorderRadius.circular(
											10.0)),
								onPressed: () => _handleSubmitted(_textController.text),
								child: new Text(
									"Let's Play!",
									style: new TextStyle(
										fontSize: 18.0,
										color: Colors.white,
										fontWeight: FontWeight.w800,
									),)))
						]));
	}

	void _toggleIsPublic(bool isPublic) {
		_isPublic = isPublic;
	}

	void _handleSubmitted(String text) {
		_textController.clear();
		var userId = globals.userState['userId'];
		var code = _generateRandomCode(5);
		//CREATE Game
		final DocumentReference game =
			Firestore.instance.collection('Games').document();
		game.setData(<String, dynamic>{
			'genre': _selectedGenre.documentID,
			'name': _selectedGenre['name'],
			'title': text,
			'imageUrl': _selectedGenre['imageUrl'],
			'code': code,
			'creator': userId,
			'players': {userId: true},
			'isPublic': _isPublic,
			'dts': DateTime.now(),
			'turn': {'dts': DateTime.now()}
		});

    Navigator.pop(context);
		//UPDATE User.games
		var userRef = Firestore.instance
			.collection('Users')
			.document(globals.userState['userId']);
		userRef.get().then((snapshot) {
			Map userGames =
				snapshot.data['games'] == null ? new Map() : snapshot.data['games'];
			userGames[game.documentID] = true;
			userRef.updateData(<String, dynamic>{
				'games': userGames,
			}).then((value) {
				globals.gameState['id'] = game.documentID;
				globals.gameState['genre'] = _selectedGenre.documentID;
				globals.gameState['name'] = _selectedGenre['name'];
				globals.gameState['title'] = text;
				// globals.gameState['isPublic'] = _isPublic;
				globals.gameState['code'] = code;
				globals.gameState['creator'] = userId;
				globals.gameState['players'] = json.encode({userId: true});

        //CREATE Intro story line
        final DocumentReference newChatAnswer =
            Firestore.instance.collection('Games/' + game.documentID + '/Logs').document();
        newChatAnswer.setData(<String, dynamic>{
          'text': _selectedGenre['introStoryline'],
          'type': 'narration',
          'title': _selectedGenre['name'],
          'titleImageUrl': _selectedGenre['imageUrl'],
          'dts': DateTime.now(),
          'userId': globals.userState['userId'],
          'profileUrl': globals.userState['profilePic'],
          'userName': globals.userState['name'],
        });
        final DocumentReference newReactionsCollection =
            Firestore.instance.collection('Games/' + game.documentID + '/Reactions').document(globals.userState['userId']);
        newReactionsCollection.setData(<String, dynamic>{'love': 1});
			});
		});
	}

	/// Generates a random string of [length] with characters
	/// between ascii 65 to 90 (uppercase letters).
	String _generateRandomCode(int length) {
		return new String.fromCharCodes(
			new List.generate(length, (index) => randomBetween(65, 90)));
	}

	/// Generates a random integer where [from] <= [to].
	int randomBetween(int from, int to) {
		if (from > to) throw new Exception('$from cannot be > $to');
		var rand = new Random();
		return ((to - from) * rand.nextDouble()).toInt() + from;
	}

	Widget _buildCategories() {
		// temp robot icon: http://www.iconarchive.com/show/avatars-icons-by-diversity-avatars/robot-02-icon.html
		// can not use for commercial use
		return StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance
				.collection('Genres')
				.orderBy('order')
				.snapshots(),
			builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
				if (!snapshot.hasData) return const Text('Loading...');
				final int messageCount = snapshot.data.documents.length;
				return ListView.builder(
					itemCount: messageCount,
					itemBuilder: (_, int index) {
						final DocumentSnapshot document = snapshot.data.documents[index];
						return GestureDetector(
							child: Container(
								margin: const EdgeInsets.symmetric(
									vertical: 16.0, horizontal: 24.0),
								child: Stack(
									children: <Widget>[
										Container(
											height: 124.0,
											width: 300.0,
											margin: EdgeInsets.only(left: 46.0),
											padding: EdgeInsets.only(
												top: 20.0, left: 65.0, right: 20.0),
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
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: <Widget>[
													Text(
														document['name'] != null
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
											child: Stack(children: <Widget>[
												CachedNetworkImage(
													placeholder: CircularProgressIndicator(),
													imageUrl: document['imageUrl'],
													height: 92.0,
													width: 102.0,
												),
												document['type'] == 'paid'
													? Positioned(
														top: 30.0,
														child: RaisedButton(
															padding: EdgeInsets.all(2.0),
															shape: new RoundedRectangleBorder(
																borderRadius:
																	new BorderRadius.circular(
																		10.0)),
															onPressed: () => _nextPage(document),
															color: const Color(0xFF48B5FB),
															child: Text(
																"Coming Soon",
																style: TextStyle(
																	fontSize: 20.0,
																	color: Colors.black,
																	fontWeight: FontWeight.w800,
																))))
													: Container(width: 0.0)
												// Text(
												// '\$1.99',
												// textAlign: TextAlign.left,
												// style: TextStyle(
												// color: Colors.white70,
												// fontWeight: FontWeight.w100,
												// fontSize: 16.0)) : Container(width: 0.0)
											])),
										// WIP: cant figure this out... circle not positioning correctly.
										// Positioned(
										// left: 100.0,
										// top: 0.0,
										// child: Container(
										// // margin: EdgeInsets.symmetric(vertical: 16.0),
										// // alignment: FractionalOffset.centerLeft,
										// height: 124.0,
										// // margin: EdgeInsets.symmetric(vertical: 16.0),
										// // alignment: FractionalOffset.centerLeft,
										// decoration: BoxDecoration(
										// color: Color(0xFFFFFFFF),
										// shape: BoxShape.circle,
										// // borderRadius: BorderRadius.circular(8.0)
										// ))),
									],
								)),
							onTap: () => _nextPage(document),
						);
					},
				);
			},
		);
	}

	void _previousPage() {
		_pageController.animateToPage(0,
			duration: Duration(milliseconds: 1000), curve: Curves.elasticOut);
	}

	void _nextPage(DocumentSnapshot document) {
		if (document['type'] == 'free') {
			setState(() {
				_selectedGenre = document;
			});
			_pageController.animateToPage(1,
				duration: Duration(milliseconds: 1000), curve: Curves.elasticOut);
		}
	}
}
