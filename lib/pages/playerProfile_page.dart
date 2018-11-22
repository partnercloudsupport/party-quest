import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async_loader/async_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlayerProfilePage extends StatefulWidget {
  final String playerId;
  PlayerProfilePage(this.playerId);
  
	@override
	_PlayerProfilePageState createState() => new _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage> {
  final GlobalKey<AsyncLoaderState> userLoaderState = new GlobalKey<AsyncLoaderState>();

	@override
	void initState() {
		super.initState();
	}

  @override
	Widget build(BuildContext context) {
    return AsyncLoader(
      key: userLoaderState,
      initState: () async => await getUser(),
      renderLoad: () => Center(child: CircularProgressIndicator()),
      renderError: ([error]) => getNoConnectionWidget(),
      renderSuccess: ({data}) => getProfileView(data));
  }

  Future getUser() async {
    return Firestore.instance
      .collection('Users')
      .document(widget.playerId)
      .get();
  }

  Widget getProfileView(DocumentSnapshot item){
    Map userData = item.data;
    return Scaffold(
			appBar: new AppBar(
				automaticallyImplyLeading: false,
				leading: new IconButton(
					icon: new Icon(Icons.close, color: Colors.white),
					onPressed: () => Navigator.pop(context)),
				backgroundColor: Theme.of(context).primaryColor,
				elevation: -1.0,
				// title: new Text(
				// 	"What do you do?",
				// 	style:
				// 		TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 30.0, letterSpacing: 1.5))
        ),
			body: Container(
				decoration: BoxDecoration(
					image: DecorationImage(
						image: AssetImage("assets/images/background-cosmos.png"),
						fit: BoxFit.fill)),
				child:
        Column(children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 40.0, bottom: 10.0),
            child: Container(width: 150.0, height: 150.0,
                decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 3.0), shape: BoxShape.circle,
                  image: DecorationImage(fit: BoxFit.cover,
                    image: userData['profilePic'].contains('http') ? CachedNetworkImageProvider(userData['profilePic']) : AssetImage(userData['profilePic'])))),
          ),
          Text(userData['name'],
            style: new TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              fontSize: 28.0,
            )),
            _buildReactionsRow(userData['reactions']),
            _buildIntro(userData['intro']),
        ])));
  }

  Widget _buildIntro(String intro) {
    return intro != null ? Padding(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), child: Text(intro,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        fontSize: 20.0,
      )))
      : Container();
  }

  Widget _buildReactionsRow(Map playerReactions){
		List<Widget> reactionsListTiles = [];
    if(playerReactions != null) {
      for(var key in playerReactions.keys){
        reactionsListTiles.add(Container(child: Image.asset('assets/images/reaction-' + key + '.png'), height: 35.0));
        reactionsListTiles.add(Padding(padding: EdgeInsets.only(right: 10.0, left: 0.0, top: 19.0), 
          child: Text("${playerReactions[key]}", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 15.0))));
      }
    }
    return Row(
      // mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[ Padding(padding: EdgeInsets.only(top: 15.0, bottom: 5.0), child: Row(children: reactionsListTiles))]);
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
          onPressed: () => userLoaderState.currentState.reloadState())
      ],
    );
  }
}