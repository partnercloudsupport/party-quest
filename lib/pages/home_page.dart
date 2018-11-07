import 'package:flutter/material.dart';
import '../application.dart';
import '../components/fancyFab.dart';
import 'package:fluro/fluro.dart';
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
		// globals.gameState.changes.listen((changes) {
		// 	setState(() {
		// 		_title = globals.gameState['title'];
		// 	});
		// });
	}
	// String _title;
	final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _filter = 'topGames';

	@override
	Widget build(BuildContext context) {
		return DefaultTabController(
        length: 3,
        child: Scaffold(
			key: _scaffoldKey,
			// backgroundColor: Colors.white,
			// drawer: AccountDrawer(), // left side
			appBar: AppBar(
				// toolbarOpacity: 0.0,
        title: Row(children: <Widget>[
          Expanded(child: Text('Party', style: TextStyle(color: Colors.white, fontSize: 30.0), textAlign: TextAlign.right,)),
          Container(width: 40.0, child: Image.asset('assets/images/20D20.png')),
          Expanded(child: Text('Quest', style: TextStyle(color: Colors.white, fontSize: 30.0)))
        ]),
        bottom: TabBar(
            labelPadding: EdgeInsets.all(0.0),
            labelColor: Colors.white,
            indicatorColor: Colors.white,
              tabs: [
                Tab(child: Text('Players', style: TextStyle(fontSize: 20.0),)), //icon: Icon(Icons.people, color: Colors.white)),
                Tab(child: Text('Games', style: TextStyle(fontSize: 20.0),)), //icon: Icon(Icons.bubble_chart, color: Colors.white)),
                Tab(child: Text('Profile', style: TextStyle(fontSize: 20.0),)), //icon: Icon(Icons.person, color: Colors.white)),
              ],
            ),
				// leading: IconButton(
				// 	icon: Icon(Icons.account_circle, color: Colors.white),
				// 	onPressed: () => _scaffoldKey.currentState.openDrawer()),
				backgroundColor: Theme.of(context).primaryColor,
				// title: Text(_title == null ? 'Public Games' : _title,
				// 	style:
				// 		TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 25.0, letterSpacing: 1.5)),
				// elevation: 0.0,
				// actions: <Widget>[
				// 	IconButton(
				// 		icon: Icon(
				// 			Icons.info_outline,
				// 			color: Colors.white,
				// 		),
				// 		tooltip: 'Info about this Game.',
				// 		onPressed: _openInfoView)
				// ],
			),
			// bottomNavigationBar: _buildBottomBar(),
      body: Container(
				decoration: BoxDecoration(
					image: DecorationImage(
					// image: AssetImage("assets/images/$_gameType.jpg"),
					image: AssetImage("assets/images/background-purple.png"),
					fit: BoxFit.cover,
					// colorFilter: ColorFilter.mode(
					// Colors.black.withOpacity(0.9), BlendMode.dstATop)
				)
        ),
				child: TabBarView(
            children: [
              _buildPlayersList(),
              _buildGamesList(),
              _buildProfile()
            ],
          ))));   
	}

  Widget _buildProfile(){
    Map currentUser = globals.userState;
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
          child: Column(children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 40.0, bottom: 10.0),
              child: Container(width: 150.0, height: 150.0,
                  decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 3.0), shape: BoxShape.circle,
                    image: DecorationImage(fit: BoxFit.cover,
                      image: currentUser['profilePic'].contains('http') ? CachedNetworkImageProvider(currentUser['profilePic']) : AssetImage(currentUser['profilePic'])))),
            ),
            Text(currentUser['name'],
              style: new TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                fontSize: 28.0,
              )),
            // TODO: GOLD!!!!!!
            // Padding(
            //   padding: EdgeInsets.only(left: 20.0, top: 10.0), 
            //   child: Container(
            //     decoration: BoxDecoration(
            //       image: DecorationImage(
            //         image: AssetImage("assets/images/coins-icon.png"),
            //         fit: BoxFit.contain)),
            //     child: Padding(padding: EdgeInsets.only(right: 50.0),  child: Text('20',
            //       style: new TextStyle(
            //         color: const Color(0xFFFDCF39),
            //         fontWeight: FontWeight.w400,
            //         letterSpacing: 0.5,
            //         fontSize: 20.0,
            //       )))))
          ]),
          onTap: () => Application.router.navigateTo(context, 'userProfile',
              transition: TransitionType.fadeIn)));
  }

	Widget _buildPlayersList() {
		return Stack(children: <Widget>[
      ListView(children: <Widget> [StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance
				.collection('Users')
				.snapshots(),
			builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
				if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(0.0), child: Text('Loading...', style: TextStyle(color: Colors.white)));
        List<Widget> playerListTiles = [];				
        snapshot.data.documents.forEach((player) {
          if(player['profilePic'] == null || player['games'] == null || (player['games'] != null && player['games'].length == 0)) return;
          playerListTiles.add(ListTile(
            // isThreeLine: true,
            leading:  CircleAvatar(
              radius: 25.0, 
              backgroundColor: Colors.white.withOpacity(.3),
              backgroundImage: player['profilePic'].contains('http') ? CachedNetworkImageProvider(player['profilePic']) : AssetImage("${player['profilePic']}")),
            title: Text(player['name'], style: TextStyle(color: Colors.white, fontSize: 20.0)),
            subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[ 
                    Text("Games: " + player['games'].length.toString(),
                      style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.w400)),
                    _buildReactionsRow(player['reactions']) ])
            // Text("Games: ${player['games'].length.toString()}", style: TextStyle(color: Colors.white70))
            ));
        });
        return Column(children: playerListTiles);
      })])]);
  }

  Widget _buildReactionsRow(Map playerReactions){
		List<Widget> reactionsListTiles = [];
    if(playerReactions != null) {
      for(var key in playerReactions.keys){
        reactionsListTiles.add(Container(child: Image.asset('assets/images/reaction-' + key + '.png'), height: 20.0));
        reactionsListTiles.add(Padding(padding: EdgeInsets.only(right: 10.0, left: 0.0, top: 9.0), child: Text("${playerReactions[key]}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 10.0))));
      }
    }
    return Padding(padding: EdgeInsets.only(top: 5.0), child: Row(children: reactionsListTiles));
  }

	Widget _buildGamesList() {
    String whereClause = _filter == 'myGames' ? 'players.' + globals.userState['userId'] : 'isPublic';
		return Stack(children: <Widget>[
      ListView(children: <Widget> [StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance
				.collection('Games')
				.where(whereClause, isEqualTo: true)
        // .orderBy('totalReactions', descending: true)
				.snapshots(),
			builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
				if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(10.0), child: Text('Loading...', style: TextStyle(color: Colors.white)));
				List<Widget> labelListTiles = [Container(height: 40.0)];
				snapshot.data.documents.forEach((game) {
					if (true) { //game['players'][globals.userState['userId']] == null
						labelListTiles.add(GestureDetector(
							child: ListTile(
                isThreeLine: true,
								leading: CircleAvatar(
                  radius: 30.0,
                  backgroundColor: Colors.white.withOpacity(0.0),
                  backgroundImage: game['imageUrl'].contains('http') ? CachedNetworkImageProvider(game['imageUrl']) : AssetImage(game['imageUrl']))
                // CachedNetworkImage(
								// 	placeholder: CircularProgressIndicator(),
								// 	imageUrl: game['imageUrl'],
								// 	height: 45.0,
								// 	width: 45.0)
                  ,
								title: Text(game['title'],
									style: TextStyle(
                    fontSize: 18.0,
										color: Colors.white, fontWeight: FontWeight.w800)),
								subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Players: " + game['players'].length.toString(),
                      style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.w400)),
                    _buildReactionsRow(game['reactions']) ]),
							),
							onTap: () => _handleGameSelected(context, game)
            ));
					}
				});
				return Column(children: labelListTiles);
			},
		)]),
      Row(children: <Widget>[
        Expanded(child: Padding(padding: EdgeInsets.only(left: 0.0, right: 0.0), child: RaisedButton(
          elevation: 4.0,
          highlightElevation: 0.0,
          padding: EdgeInsets.all(10.0),
          // onPressed: null,
          onPressed: (){
            setState(() {
              _filter = 'topGames';
            });
          },
          color: _filter == 'topGames' ? Theme.of(context).accentColor : Theme.of(context).accentColor.withOpacity(0.3),
          textColor: _filter == 'topGames' ? Colors.white : Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(0.0)),
          child: Text('Top Games', style: TextStyle(fontSize: 18.0))
        ))),
        Expanded(child: Padding(padding: EdgeInsets.only(left: 0.0, right: 0.0), child: RaisedButton(
          elevation: 4.0,
          highlightElevation: 50.0,
          padding: EdgeInsets.all(10.0),
          // onPressed: null,
          onPressed: (){
            setState(() {
              _filter = 'myGames';
            });
          },
          textColor: _filter == 'myGames' ? Colors.white : Colors.white70,
          color: _filter == 'myGames' ? Theme.of(context).accentColor : Theme.of(context).accentColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(0.0)),
          child: Text('My Games', style: TextStyle(fontSize: 18.0))
        )))
      ]),
			Align(
		alignment: Alignment.bottomRight, child: Container(
			margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
			child: 
      // Container(
      // child: 
      // FloatingActionButton(
      //     backgroundColor: Color(0xFF7336AE),
      //     heroTag: 'Create',
      //     onPressed: () => Application.router
      //       .navigateTo(context, 'createGame', transition: TransitionType.fadeIn),
      //     tooltip: 'Create Game',
      //     child: Icon(Icons.add),
      //   ),
      // )
      FancyFab()
      // BottomNavigationBar(
      //   fixedColor: Colors.white,
      //   onTap: null, // new
      //   currentIndex: 0, // new
      //   items: [
      //     new BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       title: Text('Public Games'),
      //     ),
      //     new BottomNavigationBarItem(
      //       icon: Icon(Icons.mail),
      //       title: Text('My Games'),
      //     )
      //   ],
      // ),
      // Row(children: <Widget>[
      //   Expanded(child: RaisedButton(
      //   padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      //     color: const Color(0xFF6CE4E5),
      //     shape: RoundedRectangleBorder(
      //       borderRadius:
      //         BorderRadius.circular(
      //           0.0)),
      //     onPressed: () => Application.router
      //       .navigateTo(context, 'createGame', transition: TransitionType.fadeIn),
      //     child: Text(
      //       "Create Game",
      //       style: TextStyle(
      //         fontSize: 22.0,
      //         color: Colors.white,
      //         fontWeight: FontWeight.w800,
      //       )))),
      //   Expanded(child: RaisedButton(
      //   padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      //     color: const Color(0xFFD7263D),
      //     shape: RoundedRectangleBorder(
      //       borderRadius:
      //         BorderRadius.circular(
      //           0.0)),
      //     onPressed: () => Application.router
      //       .navigateTo(context, 'joinGame', transition: TransitionType.fadeIn),
      //     child: Text(
      //       "Join Game",
      //       style: TextStyle(
      //         fontSize: 22.0,
      //         color: Colors.white,
      //         fontWeight: FontWeight.w800,
      //       )))),  
      //   ])

      ))]);
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
    Application.router.navigateTo(context, 'openGame?gameId=' + game.documentID, transition: TransitionType.fadeIn);
		// Navigator.pop(context);
	}
}
