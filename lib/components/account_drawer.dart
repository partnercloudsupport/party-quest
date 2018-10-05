import 'package:flutter/material.dart';
import '../application.dart';
import 'package:fluro/fluro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:observable/observable.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';

class AccountDrawer extends StatefulWidget {
  @override
  _AccountDrawerState createState() => _AccountDrawerState();
}

class _AccountDrawerState extends State<AccountDrawer> {
  _AccountDrawerState() {
    globals.userState.changes.listen((changes) {
      setState(() {
        currentUser = User.fromJson(globals.userState);
      });
    });
  }
  User currentUser = User(globals.userState['name'], 'email@gmail.us',
      globals.userState['profilePic']);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children
      ..addAll(_buildUserAccount(context))
      ..addAll(_buildMainMenu(context))
      ..addAll([new Divider(color: Colors.white)])
      ..add(_buildLabel('My Games'))
      ..add(_buildMyGamesWidgets(context));
    return Drawer(
      child: Container(
          // decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //     begin: Alignment.topLeft,
          //     end: Alignment.bottomRight, // 10% of the width, so there are ten blinds.
          //     colors: [
          //       // const Color(0xFFFFFFFF),
          //       Colors.white,
          //       Colors.black,
          //       // const Color(0xd3e9eb00)
          //     ], // white to black
          //     tileMode: TileMode.clamp, // repeats the gradient over the canvas
          //   ),
          // ),
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assets/images/background-gradient.png"),
            fit: BoxFit.fill,
            // colorFilter: ColorFilter.mode(
            //     Colors.black.withOpacity(0.9), BlendMode.dstATop)
          )),
          child: ListView(padding: EdgeInsets.zero, children: children)),
    );
  }

  Widget _buildLabel(String labelName) {
    return ListTile(
        title: Text(labelName,
            style: new TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w100,
              // letterSpacing: 0.5,
              fontSize: 16.0,
            )));
  }

  List<Widget> _buildMainMenu(BuildContext context) {
    return [
      ListTile(
          title: Text("Create Game",
              style: TextStyle(color: Colors.white, fontSize: 18.0)),
          leading: Icon(Icons.brush, color: Colors.white, size: 30.0),
          onTap: () => _openCreateGame()),
      ListTile(
          title: Text("Join Game",
              style: TextStyle(color: Colors.white, fontSize: 18.0)),
          leading: Icon(Icons.group_add, color: Colors.white, size: 30.0),
          onTap: () => _openJoinGame()),      
      ListTile(
          title: Text("Public Games",
              style: TextStyle(color: Colors.white, fontSize: 18.0)),
          leading: Icon(Icons.bubble_chart, color: Colors.white, size: 30.0),
          onTap: () => _openPublicGames()),
      // ListTile(
      //     title: Text("Top Charts"),
      //     leading: Icon(Icons.show_chart),
      //     onTap: () => Application.router.navigateTo(context, 'joinGame',
      //         transition: TransitionType.fadeIn))
    ];
  }

  void _openCreateGame() {
    Navigator.pop(context);
    Application.router
        .navigateTo(context, 'createGame', transition: TransitionType.fadeIn);
  }

  void _openPublicGames() {
    globals.gameState['id'] = '';
    globals.gameState['title'] = 'Public Games';
    Navigator.pop(context);
  }

  void _openJoinGame() {
    Navigator.pop(context);
    Application.router
        .navigateTo(context, 'joinGame', transition: TransitionType.fadeIn);
  }

  List<Widget> _buildUserAccount(BuildContext context) {
    return [
      Container(
          margin: EdgeInsets.only(bottom: 20.0),
          child: GestureDetector(
              child: Column(children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 40.0, bottom: 10.0),
                  child: Container(width: 150.0, height: 150.0,
                      decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 3.0), shape: BoxShape.circle,
                        image: DecorationImage(fit: BoxFit.cover,
						              image: currentUser.profilePic.contains('http') ? CachedNetworkImageProvider(currentUser.profilePic) : AssetImage(currentUser.profilePic)))),
                ),
                Text(currentUser.name,
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
                  transition: TransitionType.fadeIn))),
    ];
  }

  // List<Widget> _buildUserAccounts(BuildContext context) {
  //   return [
  //     UserAccountsDrawerHeader(
  //       accountEmail: new Text("10 Games, 543 points",
  //           style: new TextStyle(
  //             color: Colors.white,
  //             // fontWeight: FontWeight.w800,
  //             letterSpacing: 0.2,
  //             // fontSize: 22.0,
  //           )),
  //       accountName: Text(
  //         currentUser.name,
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontWeight: FontWeight.w800,
  //           letterSpacing: 0.5,
  //           fontSize: 20.0,
  //         ),
  //       ),
  //       currentAccountPicture: GestureDetector(
  //         child: CircleAvatar(
  //           backgroundImage: NetworkImage(currentUser.profilePic),
  //         ),
  //         onTap: () => Application.router.navigateTo(context, 'userProfile',
  //             transition: TransitionType.fadeIn),
  //       ),
  //       onDetailsPressed: () => Application.router.navigateTo(
  //           context, 'userProfile',
  //           transition: TransitionType.fadeIn),
  //       decoration: BoxDecoration(
  //           image: DecorationImage(
  //               image: AssetImage('assets/images/bubbles_bg.jpg'),
  //               fit: BoxFit.fill)),
  //     )
  //   ];
  // }

  // WIP, just grab the list once:
  // Future<Widget> _buildMyGamesWidgets(BuildContext context) async {
  //   QuerySnapshot querySnapshot = await Firestore.instance
  //       .collection('Games')
  //       .where('creator', isEqualTo: globals.userState['userId'])
  //       .getDocuments();
  //   List<Widget> labelListTiles = [];
  //   querySnapshot.documents.forEach((game) {
  //     labelListTiles.add(new ListTile(
  //       title: Text(game['code']),
  //       subtitle: Text(game['type']),
  //       onTap: () => _openGame(game.documentID, game['type'], context),
  //     ));
  //   });
  //   return Column(children: labelListTiles);

  Widget _buildMyGamesWidgets(BuildContext context) {
    // When performing a rules check on a query, Cloud Firestore Security Rules will check to ensure that the user has access to all results before executing the query.
    // If a query could return results a user doesn't have access to, the entire query fails and Firestore returns an error.
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('Games')
            .where('players.' + globals.userState['userId'], isEqualTo: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          List<Widget> labelListTiles = [];
          // final int messageCount = snapshot.data.documents.length;
          snapshot.data.documents.forEach((game) {
            String characterNames = '';
            if(game['characters'] != null){
              for(var key in game['characters'].keys){
                if(game['characters'][key]['inactive'] != true)
                  characterNames += game['characters'][key]['characterName'] + ', ';
              }
            }
            labelListTiles.add(new ListTile(
              leading: CachedNetworkImage(
                  placeholder: CircularProgressIndicator(),
                  imageUrl: game['imageUrl'],
                  height: 45.0,
                  width: 45.0),
              title: Text(game['title'],
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17.0)),
              subtitle: Text(characterNames,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w100)),
              // trailing: RaisedButton(
              //     color: const Color(0xFF00b0ff),
              //     shape: new RoundedRectangleBorder(
              //       borderRadius:
              //         new BorderRadius.circular(
              //           10.0)),
              //     onPressed: () => _handleInviteButtonTap(context, game["code"]),
              //     child: new Text(
              //       "Invite",
              //       style: new TextStyle(
              //         fontSize: 18.0,
              //         color: Colors.white,
              //         fontWeight: FontWeight.w800,
              //       ),)),
              onTap: () => _openGame(game, context),
            ));
          });
          return Column(children: labelListTiles);
        });
  }
}

// void _handleInviteButtonTap(BuildContext context, String code){
//   Application.router.navigateTo(
// 			context, 'inviteFriends?code=' + code,
// 			transition: TransitionType.fadeIn);
// }

void _openGame(DocumentSnapshot game, BuildContext context) {
  Navigator.pop(context);
  globals.gameState['id'] = game.documentID;
  globals.gameState['genre'] = game['genre'];
  globals.gameState['name'] = game['name'];
  globals.gameState['title'] = game['title'];
  globals.gameState['code'] = game['code'];
  globals.gameState['creator'] = game['creator'];
  globals.gameState['players'] = json.encode(game['players']);
}

class User {
  final String name;
  final String email;
  final String profilePic;

  User(this.name, this.email, this.profilePic);

  User.fromJson(ObservableMap json)
      : name = json['name'],
        email = json['email'],
        profilePic = json['profilePic'];

  Map<String, dynamic> toJson() =>
      {'name': name, 'email': email, 'profilePic': profilePic};
}
