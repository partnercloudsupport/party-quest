import 'package:flutter/material.dart';
import 'dart:async';
import '../application.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async_loader/async_loader.dart';
import '../components/fancyFab.dart';
import 'package:fluro/fluro.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class GamesListView extends StatefulWidget {
	@override
	_GamesListViewState createState() => _GamesListViewState();
}

class _GamesListViewState extends State<GamesListView> {
  final GlobalKey<AsyncLoaderState> gamesLoaderState = GlobalKey<AsyncLoaderState>();
  bool _isRefreshing = false;

	@override
	void initState() {
		super.initState();
	}

  @override
	Widget build(BuildContext context) {
    return Stack(children: <Widget>[ 
      Column(children: <Widget>[
        // _buildTabs(), 
        Expanded(child: AsyncLoader(
          key: gamesLoaderState,
          initState: () async => await getGames(),
          renderLoad: () => Center(child: CircularProgressIndicator()),
          renderError: ([error]){ 
            getNoConnectionWidget();},
          renderSuccess: ({data}) {
            globals.myGames = data[0];
            globals.topGames = data[1];
            return getListView();
          })),
        
      ]),
      Align(alignment: Alignment.bottomRight, child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: FancyFab()))
      ]);
  }

  // Widget _buildTabs(){
  //   return Container(height: 40.0, child: Row(children: <Widget>[
  //     Expanded(child: Padding(padding: EdgeInsets.only(left: 0.0, right: 0.0), child: RaisedButton(
  //       // elevation: 0.0,
  //       // highlightElevation: 0.0,
  //       padding: EdgeInsets.all(10.0),
  //       // onPressed: null,
  //       onPressed: (){
  //         setState(() {
  //           _filter = 'topGames';
  //           gamesLoaderState.currentState.reloadState();
  //         });
  //       },
  //       color: _filter == 'topGames' ? Theme.of(context).accentColor : Theme.of(context).accentColor.withOpacity(0.3),
  //       textColor: _filter == 'topGames' ? Colors.white : Colors.white70,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(0.0)),
  //       child: Text('Top Games', style: TextStyle(fontSize: 18.0))
  //     ))),
  //     Expanded(child: Padding(padding: EdgeInsets.only(left: 0.0, right: 0.0), child: RaisedButton(
  //       elevation: 4.0,
  //       highlightElevation: 50.0,
  //       padding: EdgeInsets.all(10.0),
  //       // onPressed: null,
  //       onPressed: (){
  //         setState(() {
  //           _filter = 'myGames';
  //           gamesLoaderState.currentState.reloadState();
  //         });
  //       },
  //       textColor: _filter == 'myGames' ? Colors.white : Colors.white70,
  //       color: _filter == 'myGames' ? Theme.of(context).accentColor : Theme.of(context).accentColor.withOpacity(0.3),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(0.0)),
  //       child: Text('My Games', style: TextStyle(fontSize: 18.0))
  //     )))
  //   ]));
  // }

  Future getGames() async {
    return Future.wait([getMyGames(), getTopGames()]);
  }

  Future getMyGames() async {
    if(globals.myGames != null) return globals.myGames;
    return Firestore.instance
      .collection('Games')
      .where('players.' + globals.currentUser.documentID, isEqualTo: true)
      // .orderBy('totalReactions', descending: true)
      .getDocuments();
  }

  Future getTopGames() async {
    if(globals.topGames != null) return globals.topGames;
    return Firestore.instance
      .collection('Games')
      .where('isPublic', isEqualTo: true)
      // .orderBy('totalReactions', descending: true)
      .getDocuments();
  }

  Widget getListView(){
    return Scrollbar(
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
            slivers: _buildSlivers(globals.myGames.documents, globals.topGames.documents),
          )
    ));
  }

  List<Widget> _buildSlivers(List myGames, List topGames){
    List<Widget> slivers = List<Widget>();
    slivers.add(_buildSliversSection('My games', myGames));
    slivers.add(_buildSliversSection('Top games', topGames));
    return slivers;
  }

  Widget _buildSliversSection(String headerText, List items){
    return SliverStickyHeader(
      header: _buildHeader(headerText),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => _buildGameListItem(items[i]),
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Container(
      height: 60.0,
      color: Theme.of(context).accentColor,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildGameListItem(game) {
    return GestureDetector(
      child: ListTile(
        isThreeLine: true,
        leading: CircleAvatar(
          radius: 30.0,
          backgroundColor: Colors.white.withOpacity(0.0),
          backgroundImage: game['imageUrl'].contains('http') ? CachedNetworkImageProvider(game['imageUrl']) : AssetImage(game['imageUrl']))
          ,
          trailing: game['turn']['playerId'] == globals.currentUser.documentID ? _buildNotificationDot() : null,
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
    );
  }

  Widget _buildNotificationDot(){
    return Container(width: 15.0, height: 15.0,
      decoration: BoxDecoration(
        color: Theme.of(context).errorColor,
        // border: Border.all(color: Theme.of(context).errorColor, width: 3.0), 
        shape: BoxShape.circle));
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
    globals.myGames = null;
    globals.topGames = null;
    gamesLoaderState.currentState.reloadState();
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
          onPressed: () => gamesLoaderState.currentState.reloadState())
      ],
    );
  }


	void _handleGameSelected(BuildContext context, DocumentSnapshot game) {
		globals.currentGame = game;
		// globals.currentGame.data['players'] = json.encode(game['players']);
    Application.router.navigateTo(context, 'openGame?gameId=' + game.documentID, transition: TransitionType.fadeIn);
		// Navigator.pop(context);
	}

}