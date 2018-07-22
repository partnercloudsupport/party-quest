import 'package:flutter/material.dart';
import 'application.dart';
import 'package:fluro/fluro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:observable/observable.dart';
import 'package:gratzi_game/globals.dart' as globals;
import 'package:cached_network_image/cached_network_image.dart';

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
              fontSize: 12.0,
            )));
  }

  List<Widget> _buildMainMenu(BuildContext context) {
    return [
      ListTile(
          title: Text("Create Game", style: TextStyle(color: Colors.white)),
          leading: Icon(Icons.create, color: Colors.white),
          onTap: () => _openCreateGame()),
      ListTile(
          title: Text("Join Game", style: TextStyle(color: Colors.white)),
          leading: Icon(Icons.contacts, color: Colors.white),
          onTap: () => _openJoinGame()),
      // ListTile(
      //     title: Text("Top Charts"),
      //     leading: Icon(Icons.show_chart),
      //     onTap: () => Application.router.navigateTo(context, 'joinGame',
      //         transition: TransitionType.fadeIn))
    ];
  }

  void _openCreateGame(){
    Navigator.pop(context);
    Application.router.navigateTo(context, 'createGame',
              transition: TransitionType.fadeIn);
  }

  void _openJoinGame(){
    Navigator.pop(context);
    Application.router.navigateTo(context, 'joinGame',
              transition: TransitionType.fadeIn);
  }

  List<Widget> _buildUserAccount(BuildContext context) {
    return [
      Container(
          margin: EdgeInsets.only(bottom: 20.0),
          child: GestureDetector(
              child: Column(children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 40.0, bottom: 10.0),
                  child: Container(
                      width: 150.0,
                      height: 150.0,
                      // child: CachedNetworkImage(
                      //     placeholder: CircularProgressIndicator(),
                      //     imageUrl: currentUser.profilePic,
                      //     height: 150.0,
                      //     width: 150.0,
                      //     fit: BoxFit.contain,
                      //     ),
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.cover,
                              image:
                                  new NetworkImage(currentUser.profilePic)))),
                ),
                Text(currentUser.name,
                    style: new TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      fontSize: 24.0,
                    ))
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
            labelListTiles.add(new ListTile(
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
              onTap: () => _openGame(game, context),
            ));
          });
          return Column(children: labelListTiles);
        });
  }
}

void _openGame(DocumentSnapshot game, BuildContext context) {
  globals.gameState['id'] = game.documentID;
  globals.gameState['category'] = game['category'];
  globals.gameState['name'] = game['name'];
  globals.gameState['title'] = game['title'];
  globals.gameState['isPublic'] = 'false';
  globals.gameState['code'] = game['code'];
  globals.gameState['creator'] = game['creator'];
  globals.gameState['players'] = game['players'].toString();
  Navigator.pop(context);
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
