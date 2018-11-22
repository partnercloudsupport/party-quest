import 'package:flutter/material.dart';
import 'dart:async';
import '../application.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async_loader/async_loader.dart';
import 'package:fluro/fluro.dart';
import '../components/inbox_listItem.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:cached_network_image/cached_network_image.dart';

class UserProfileView extends StatefulWidget {
  
	@override
	_UserProfileViewState createState() => new _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  final GlobalKey<AsyncLoaderState> userLoaderState = new GlobalKey<AsyncLoaderState>();
  bool _isRefreshing = false;

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
    if(!_isRefreshing) return globals.currentUser;
    return Firestore.instance
      .collection('Users')
      .document(globals.currentUser.documentID)
      .get();
  }

  Widget getProfileView(DocumentSnapshot items){
    globals.currentUser = items;
    Map userData = globals.currentUser.data;
    return Scrollbar(
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: 
        ListView(children: <Widget>[
          GestureDetector(
            child: Column(children: <Widget>[
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
            ]),
              onTap: () => Application.router.navigateTo(context, 'userProfile',
              transition: TransitionType.fadeIn)),
            // TODO: GOLD!!!!!!
            // Padding(
            //   padding: EdgeInsets.only(left: 20.0, top: 10.0), 
            //   child: Container(
            //     width: 100.0,
            //     decoration: BoxDecoration(
            //       image: DecorationImage(
            //         image: AssetImage("assets/images/coins-icon.png"),
            //         fit: BoxFit.contain)),
            //     child: Padding(padding: EdgeInsets.only(right: 50.0),  child: Text('20',
            //       textAlign: TextAlign.center,
            //       style: new TextStyle(
            //         color: const Color(0xFFFDCF39),
            //         fontWeight: FontWeight.w400,
            //         letterSpacing: 0.5,
            //         fontSize: 20.0,
            //       ))))),
            
            _buildRequests()
        ])));
  }

  Widget _buildRequests(){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
        .collection('Users/${globals.currentUser.documentID}/Inbox')
        .orderBy('dts', descending: true)
        .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...', style: TextStyle(color: Colors.white));
        List<Widget> labelListTiles = [];
        labelListTiles.add(
          Row(children: <Widget>[
            Expanded(child: Container(alignment: Alignment.centerLeft, height: 60.0, decoration: BoxDecoration(color: Theme.of(context).accentColor), 
            child: Padding(padding: EdgeInsets.only(left: 20.0), child: Text('Requests', style: TextStyle(color: Colors.white, fontSize: 20.0)))))
          ]));
        snapshot.data.documents.forEach((inboxItem) {
          labelListTiles.add(InboxItem(inboxItem));
        });
        if(snapshot.data.documents.length == 0){
          labelListTiles.add(Padding(padding: EdgeInsets.all(10.0), child: Text('No pending requests.', style: TextStyle(color: Colors.white))));
        }
        return Column(children: labelListTiles);
      });
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

  Future<Null> _handleRefresh() async {
    _isRefreshing = true;
    userLoaderState.currentState.reloadState();
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
          onPressed: () => userLoaderState.currentState.reloadState())
      ],
    );
  }

	// void _handlePlayerSelected(BuildContext context, DocumentSnapshot player) {
  //   Application.router.navigateTo(context, 'openPlayer?userId=' + player.documentID, transition: TransitionType.fadeIn);
	// }

}