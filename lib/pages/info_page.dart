import 'package:flutter/material.dart';
import 'playersInfo_page.dart';
import 'charactersInfo_page.dart';
import 'synopsisInfo_page.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';


class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => new _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with SingleTickerProviderStateMixin {
	TabController _tabController;
  DocumentSnapshot _gameInfo;
  QuerySnapshot _gamePlayers;
  QuerySnapshot _gameReactions;
  String _gameId;
  double _appBarHeight;

  _InfoPageState() {
    _gameId = globals.gameState['id'];
    if(_gameId == '') return; 
    Future.wait([_getGameInfo(), _getGamePlayers(), _getGameReactions()])
    .then((List responses) {
      setState(() {
        _gameInfo = responses[0];
        _gamePlayers = responses[1];
        _gameReactions = responses[2];
      });
    });
  }

  @override
	void initState() {
		super.initState();
		_tabController = TabController(vsync: this, length: 4);
	}

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()), 
      backgroundColor: const Color(0xFF00073F),
      elevation: -1.0,
      title: Text("Game Info", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
    );
    _appBarHeight = appBar.preferredSize.height;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar,
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      "assets/images/background-gradient.png"),
                  fit: BoxFit.fill)),
            child: _gameId == '' ? Container() : _buildTabsDetails()
          ));
  }

  Widget _buildTabsDetails(){
    TabBar tabBar = TabBar(
      controller: _tabController,
      unselectedLabelColor: const Color(0x66FFFFFF),
      labelColor: const Color(0xFFFFFFFF),
      indicatorSize: TabBarIndicatorSize.tab,
      tabs: <Tab>[
        Tab(child: Text('Characters', style: TextStyle(fontSize: 20.0))),
        Tab(child: Text('Players', style: TextStyle(fontSize: 20.0))),
        Tab(child: Text('Synopsis', style: TextStyle(fontSize: 20.0))),
        ]
      );
		return
      Column(
      // direction: Axis.vertical,
      children: <Widget>[
			    tabBar,
          Expanded(child: TabBarView(
            controller: _tabController,
            children: //myTabs.map((Tab tab) {
              <Widget> [
                CharactersInfoPage(_gameInfo),
                PlayersInfoPage(_gameInfo, _gamePlayers, _gameReactions),
                SynopsisInfoPage()
                // Container(child: Padding(padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0), child: Text('Write notes, rules, or events from the story you want to keep track of.', style: TextStyle(color: const Color(0xFFFFFFFF), fontSize: 20.0)))),
              ]
            // }).toList(),
          )),
			]);
		}

    Future<QuerySnapshot> _getGameReactions(){
      var reactions = Firestore.instance.collection('Games/$_gameId/Reactions');
      return reactions.getDocuments();
    }

    Future<DocumentSnapshot> _getGameInfo(){
      var gameInfo = Firestore.instance.collection('Games').document(_gameId);
      return gameInfo.get();
    }

    Future<QuerySnapshot> _getGamePlayers(){
      var players = Firestore.instance.collection('Users').where('games.' + _gameId, isEqualTo: true);
      return players.getDocuments();
    }

}
