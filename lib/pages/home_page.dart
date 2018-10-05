import 'package:flutter/material.dart';
import '../application.dart';
import 'package:fluro/fluro.dart';
import '../components/chat_view.dart';
import '../components/account_drawer.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
	@override
	createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
	HomePageState() {
		globals.gameState.changes.listen((changes) {
			setState(() {
				_title = globals.gameState['title'];
			});
		});
	}
	String _title;
	final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			key: _scaffoldKey,
			// backgroundColor: Colors.white,
			drawer: AccountDrawer(), // left side
			appBar: AppBar(
				// toolbarOpacity: 0.0,
				leading: IconButton(
					icon: Icon(Icons.account_circle, color: Colors.white),
					onPressed: () => _scaffoldKey.currentState.openDrawer()),
				backgroundColor: const Color(0xFF00073F),
				title: Text(_title == null ? 'Public Games' : _title,
					style:
						TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 25.0, letterSpacing: 1.5)),
				elevation: -1.0,
				actions: <Widget>[
					IconButton(
						icon: Icon(
							Icons.info_outline,
							color: Colors.white,
						),
						tooltip: 'Info about this Game.',
						onPressed: _openInfoView)
				],
			),
			// bottomNavigationBar: _buildBottomBar(),
			body: Container(
				decoration: BoxDecoration(
					image: DecorationImage(
					// image: AssetImage("assets/images/$_gameType.jpg"),
					image: AssetImage("assets/images/background-cosmos.png"),
					fit: BoxFit.cover,
					// colorFilter: ColorFilter.mode(
					// Colors.black.withOpacity(0.9), BlendMode.dstATop)
				)),
				child: globals.gameState['id'] == ''
					? _buildStartScreen()
					: ChatView()));
	}

	Widget _buildStartScreen() {
		return Stack(children: <Widget>[ ListView(children: <Widget> [StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance
				.collection('Games')
				.where('isPublic', isEqualTo: true)
				.snapshots(),
			builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
				if (!snapshot.hasData) return const Text('Loading...');
				List<Widget> labelListTiles = [];
				snapshot.data.documents.forEach((game) {
					if (true) { //game['players'][globals.userState['userId']] == null
						labelListTiles.add(GestureDetector(
							child: ListTile(
								leading: CachedNetworkImage(
									placeholder: CircularProgressIndicator(),
									imageUrl: game['imageUrl'],
									height: 45.0,
									width: 45.0),
								title: Text(game['title'],
									style: TextStyle(
										color: Colors.white, fontWeight: FontWeight.w800)),
								subtitle: Text(game['name'],
									style: TextStyle(
										color: Colors.white, fontWeight: FontWeight.w100)),
							),
							onTap: () => _handleGameSelected(context, game)));
					}
				});
				return Column(children: labelListTiles);
			},
		)]),
			Align(
		alignment: Alignment.bottomCenter, child: Container(
			margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
			child: Padding(
				padding: const EdgeInsets.only(bottom: 50.0),
				child: RaisedButton(
					padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
						color: const Color(0xFF00b0ff),
						shape: RoundedRectangleBorder(
							borderRadius:
								BorderRadius.circular(
									10.0)),
						onPressed: () => Application.router
							.navigateTo(context, 'createGame', transition: TransitionType.fadeIn),
						child: Text(
							"Create a Game",
							style: TextStyle(
								fontSize: 20.0,
								color: Colors.white,
								fontWeight: FontWeight.w800,
							),)))))
					]);
	}

	void _handleGameSelected(BuildContext context, DocumentSnapshot game) {
		globals.gameState['id'] = game.documentID;
		globals.gameState['type'] = game['type'];
		globals.gameState['name'] = game['name'];
		globals.gameState['title'] = game['title'];
		globals.gameState['genre'] = game['genre'];
		globals.gameState['code'] = game['code'];
		globals.gameState['creator'] = game['creator'];
		globals.gameState['players'] = json.encode(game['players']);
		// Navigator.pop(context);
	}

	void _openInfoView() {
		Application.router
			.navigateTo(context, 'info', transition: TransitionType.native);
	}
}
