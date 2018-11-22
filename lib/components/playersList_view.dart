import 'package:flutter/material.dart';
import 'dart:async';
import '../application.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async_loader/async_loader.dart';
import 'package:fluro/fluro.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:cached_network_image/cached_network_image.dart';

class PlayersListView extends StatefulWidget {
  
	@override
	_PlayersListViewState createState() => new _PlayersListViewState();
}

class _PlayersListViewState extends State<PlayersListView> {
  final GlobalKey<AsyncLoaderState> playersLoaderState = new GlobalKey<AsyncLoaderState>();

	@override
	void initState() {
		super.initState();
	}

  @override
	Widget build(BuildContext context) {
    return AsyncLoader(
      key: playersLoaderState,
      initState: () async => await getPlayers(),
      renderLoad: () => Center(child: CircularProgressIndicator()),
      renderError: ([error]) => getNoConnectionWidget(),
      renderSuccess: ({data}) => getListView(data));
  }

  Future getPlayers() async {
    if(globals.playersList != null) return globals.playersList;
    return Firestore.instance
      .collection('Users')
      .getDocuments();
  }

  Widget getListView(QuerySnapshot items){
    globals.playersList = items;
    return Scrollbar(
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView.builder(
          itemCount: items.documents.length,
          itemBuilder: (context, index) =>
          _buildPlayerListItem(items.documents[index])
    )));
  }

  Widget _buildPlayerListItem(player) {
    if(player['profilePic'] == null || player['games'] == null || (player['games'] != null && player['games'].length == 0)) return Container();
    return GestureDetector(
      child: ListTile(
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
            _buildReactionsRow(player['reactions']) ]),
      onTap: () => _handlePlayerSelected(context, player)));
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

  Future<Null> _handleRefresh() async {
    globals.playersList = null;
    playersLoaderState.currentState.reloadState();
    return null;
  }

  Widget getNoConnectionWidget(){
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 60.0,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/no-wifi.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Text("No Internet Connection"),
        FlatButton(
          color: Theme.of(context).buttonColor,
          child: Text("Retry", style: TextStyle(color: Colors.white),),
          onPressed: () => playersLoaderState.currentState.reloadState())
      ],
    );
  }

	void _handlePlayerSelected(BuildContext context, DocumentSnapshot player) {
    Application.router.navigateTo(context, 'openPlayer?userId=' + player.documentID, transition: TransitionType.fadeIn);
	}

}